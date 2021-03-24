import UIKit
import CoreLocation

#if canImport(MapboxMapsFoundation)
import MapboxMapsFoundation
#endif

// swiftlint:disable file_length

public enum GestureType: Hashable {
    /// The pan gesture type
    case pan

    /// The tap gesture type
    case tap(numberOfTaps: Int, numberOfTouches: Int)

    /// The zoom gesture type
    case pinch

    /// The rotate gesture type
    case rotate

    /// The quick zoom gesture type
    case quickZoom

    /// The pitch gesture type
    case pitch

    // Generates a handler for every gesture type
    // swiftlint:disable explicit_acl
    func makeHandler(for view: UIView,
                     delegate: GestureHandlerDelegate,
                     contextProvider: GestureContextProvider,
                     gestureOptions: GestureOptions) -> GestureHandler {
        switch self {
        case .pan:
            return PanGestureHandler(for: view, withDelegate: delegate, panScrollMode: gestureOptions.scrollingMode)
        case .tap(let numberOfTaps, let numberOfTouches):
            return TapGestureHandler(for: view,
                                     numberOfTapsRequired: numberOfTaps,
                                     numberOfTouchesRequired: numberOfTouches,
                                     withDelegate: delegate)
        case .pinch:
            return PinchGestureHandler(for: view, withDelegate: delegate)
        case .rotate:
            return RotateGestureHandler(for: view, withDelegate: delegate, andContextProvider: contextProvider)
        case .quickZoom:
            return QuickZoomGestureHandler(for: view, withDelegate: delegate)
        case .pitch:
            return PitchGestureHandler(for: view, withDelegate: delegate)
        }
    }

    // Provides understanding of equality between gesture types
    public static func == (lhs: GestureType, rhs: GestureType) -> Bool {
        switch (lhs, rhs) {
        // Compares two pan gesture types (always true)
        case (.pan, .pan):
            return true
        // Compares two tap gesture types with potentially different parameterized values
        case (let .tap(lhsNumberOfTaps, lhsNumberOfTouches), let .tap(rhsNumberOfTaps, rhsNumberOfTouches)):
            return lhsNumberOfTaps == rhsNumberOfTaps &&
                   lhsNumberOfTouches == rhsNumberOfTouches
        // Compares two pinch gesture types (always true)
        case (.pinch, .pinch):
            return true
        // Compares two rotate gesture types (always true)
        case (.rotate, .rotate):
            return true
        // Compares two long press gesture types (always true)
        case (.quickZoom, .quickZoom):
            return true
        case (.pitch, .pitch):
            return true
        default:
            return false
        }
    }

}

internal class GestureHandler {

    /// The view that the gesture handler is operating on
    weak var view: UIView?

    /// The underlying gestureRecognizer that this handler is managing
    var gestureRecognizer: UIGestureRecognizer?

    /// The delegate that the gesture handler calls to manipulate the view
    weak var delegate: GestureHandlerDelegate!

    init(for view: UIView, withDelegate delegate: GestureHandlerDelegate) {
        self.view = view
        self.delegate = delegate
    }

    deinit {
        if let validGestureRecognizer = self.gestureRecognizer {
            self.view?.removeGestureRecognizer(validGestureRecognizer)
        }
    }
}

public protocol GestureManagerDelegate: AnyObject {

    /// Informs the delegate that a gesture haas begun. Could be used to cancel camera tracking.
    func gestureBegan(for gestureType: GestureType)
}

internal protocol CameraManagerProtocol: AnyObject {

    var mapView: BaseMapView? { get }

    var mapCameraOptions: MapCameraOptions { get }

    func setCamera(to camera: CameraOptions,
                   animated: Bool,
                   duration: TimeInterval,
                   completion: ((UIViewAnimatingPosition) -> Void)?)

    func cancelTransitions()
}

extension CameraManager: CameraManagerProtocol { }

public final class GestureManager: NSObject {

    /// The `GestureOptions` that are used to set up the required gestures on the map
    private(set) var gestureOptions: GestureOptions

    /// Map of GestureType --> GestureHandler. We mantain a map to allow us to remove gestures arbitrarily.
    private(set) var gestureHandlers: [GestureType: GestureHandler] = [:]

    /// The view that all gestures operate on
    private weak var view: UIView?

    /// The camera manager that responds to gestures.
    internal let cameraManager: CameraManagerProtocol

    public weak var delegate: GestureManagerDelegate?

    internal init(for view: UIView, options: GestureOptions, cameraManager: CameraManagerProtocol) {
        self.cameraManager = cameraManager
        gestureOptions = options
        self.view = view
        super.init()
        configureGestureHandlers(for: options)
    }

    internal func updateGestureOptions(with newOptions: GestureOptions) {
        gestureOptions = newOptions
        configureGestureHandlers(for: newOptions)
    }

    // Loops through supported gestures and generate associated handlers that are to be kept alive
    internal func configureGestureHandlers(for options: GestureOptions) {
        guard let view = view else {
            assertionFailure("GestureManager view is nil.")
            return
        }
        var newGestureHandlerMap: [GestureType: GestureHandler] = [:]
        for gestureType in options.supportedGestureTypes() {
            if gestureHandlers[gestureType] == nil {
                newGestureHandlerMap[gestureType] = gestureType.makeHandler(for: view,
                                                                            delegate: self,
                                                                            contextProvider: self,
                                                                            gestureOptions: options)
            } else {
                newGestureHandlerMap[gestureType] = gestureHandlers[gestureType]
            }
        }

        gestureHandlers = newGestureHandlerMap

        if let pitchHandler = gestureHandlers[.pitch], let panHandler = gestureHandlers[.pan] {
            requireGestureToFail(allowedGesture: pitchHandler, failableGesture: panHandler)
        }

        if let doubleTapHandler = gestureHandlers[.tap(numberOfTaps: 2, numberOfTouches: 1)],
           let quickZoomHandler = gestureHandlers[.quickZoom] {
            requireGestureToFail(allowedGesture: quickZoomHandler, failableGesture: doubleTapHandler)
        }

        registerAsDelegate()
    }

    internal func registerAsDelegate() {

        guard let view = view,
              let validGestureRecognizers = view.gestureRecognizers else {
            return
        }

        for gestureRecognizer in validGestureRecognizers {
            gestureRecognizer.delegate = self
        }
    }
}

extension GestureManager: UIGestureRecognizerDelegate {

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {

        // Handle pitch tilt gesture
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            if panGesture.minimumNumberOfTouches == 2 {

                let leftTouchPoint = panGesture.location(ofTouch: 0, in: view)
                let rightTouchPoint = panGesture.location(ofTouch: 1, in: view)

                guard let touchPointAngle = GestureUtilities.angleBetweenPoints(leftTouchPoint,
                                                                                rightTouchPoint) else { return false }

                let horizontalTiltTolerance = horizontalPitchTiltTolerance()

                // If the angle between the pan touchpoints is greater then the
                // tolerance specified, don't start the gesture.
                if fabs(touchPointAngle) > horizontalTiltTolerance {
                    return false
                }
            }
        }

        return true
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        return (gestureRecognizer is UIPanGestureRecognizer
            || gestureRecognizer is UIPinchGestureRecognizer
            || gestureRecognizer is UIRotationGestureRecognizer) &&
            (otherGestureRecognizer is UIPanGestureRecognizer
            || otherGestureRecognizer is UIPinchGestureRecognizer
            || otherGestureRecognizer is UIRotationGestureRecognizer)
    }
}

/**
 Declare protocol with AnyObject so that it can
 be specified as weak.
 */
internal protocol GestureContextProvider: AnyObject {
    func fetchPinchState() -> UIGestureRecognizer.State?
    func fetchPinchScale() -> CGFloat?
    func requireGestureToFail(allowedGesture: GestureHandler, failableGesture: GestureHandler)
}

extension GestureManager: GestureContextProvider {

    internal func fetchPinchState() -> UIGestureRecognizer.State? {

        guard let validPinchHandler = gestureHandlers[.pinch],
            let validPinchRecognizer = validPinchHandler.gestureRecognizer as? UIPinchGestureRecognizer else {
                return nil
        }

        return validPinchRecognizer.state
    }

    internal func fetchPinchScale() -> CGFloat? {

        guard let validPinchHandler = gestureHandlers[.pinch],
            let validPinchRecognizer = validPinchHandler.gestureRecognizer as? UIPinchGestureRecognizer else {
                return nil
        }

        return validPinchRecognizer.scale
    }

    internal func requireGestureToFail(allowedGesture: GestureHandler, failableGesture: GestureHandler) {
        guard let failableGesture = failableGesture.gestureRecognizer else { return }
        allowedGesture.gestureRecognizer?.require(toFail: failableGesture)
    }
}
