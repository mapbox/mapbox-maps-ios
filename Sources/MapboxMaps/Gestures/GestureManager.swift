import UIKit
import CoreLocation

public protocol GestureManagerDelegate: AnyObject {

    /// Informs the delegate that a gesture haas begun. Could be used to cancel camera tracking.
    func gestureBegan(for gestureType: GestureType)
}

public final class GestureManager: NSObject {

    /// The `GestureOptions` that are used to set up the required gestures on the map
    public var options = GestureOptions() {
        didSet {
            configureGestureHandlers(for: options)
        }
    }

    /// Map of GestureType --> GestureHandler. We mantain a map to allow us to remove gestures arbitrarily.
    private(set) var gestureHandlers: [GestureType: GestureHandler] = [:]

    /// The underlying gesture recognizer for the pan gesture
    public var panGestureRecognizer: UIPanGestureRecognizer? {
        if let handler = gestureHandlers[.pan],
           let recognizer = handler.gestureRecognizer as? UIPanGestureRecognizer {
            return recognizer
        }

        return nil
    }

    /// The underlying gesture recognizer for the "double tap to zoom in" gesture
    public var doubleTapToZoomInGestureRecognizer: UITapGestureRecognizer? {
        if let handler = gestureHandlers[.tap(numberOfTaps: 2, numberOfTouches: 1)],
           let recognizer = handler.gestureRecognizer as? UITapGestureRecognizer {
            return recognizer
        }

        return nil
    }

    /// The underlying gesture recognizer for the "double tap to zoom out" gesture
    public var doubleTapToZoomOutGestureRecognizer: UITapGestureRecognizer? {
        if let handler = gestureHandlers[.tap(numberOfTaps: 2, numberOfTouches: 2)],
           let recognizer = handler.gestureRecognizer as? UITapGestureRecognizer {
            return recognizer
        }

        return nil
    }

    /// The underlying gesture recognizer for the quickZoom gesture
    public var quickZoomGestureRecognizer: UILongPressGestureRecognizer? {

        if let handler = gestureHandlers[.quickZoom],
           let recognizer = handler.gestureRecognizer as? UILongPressGestureRecognizer {
            return recognizer
        }

        return nil
    }

    /// The underlying gesture recognizer for the pitch gesture
    public var pitchGestureRecognizer: UIPanGestureRecognizer? {

        if let handler = gestureHandlers[.pitch],
           let recognizer = handler.gestureRecognizer as? UIPanGestureRecognizer {
            return recognizer
        }

        return nil
    }

    /// The underlying gesture recognizer for the rotate gesture
    public var rotationGestureRecognizer: UIRotationGestureRecognizer? {

        if let handler = gestureHandlers[.rotate],
           let recognizer = handler.gestureRecognizer as? UIRotationGestureRecognizer {
            return recognizer
        }

        return nil
    }

    /// The underlying gesture recognizer for the "pinch to zoom" gesture
    public var pinchGestureRecognizer: UIPinchGestureRecognizer? {

        if let handler = gestureHandlers[.pinch],
           let recognizer = handler.gestureRecognizer as? UIPinchGestureRecognizer {
            return recognizer
        }

        return nil
    }

    /// The view that all gestures operate on
    private weak var view: UIView?

    /// The camera manager that responds to gestures.
    internal let cameraManager: CameraAnimationsManagerProtocol

    /// Set this delegate to be called back if a gesture begins
    public weak var delegate: GestureManagerDelegate?

    /// A floating-point value that determines the rate of deceleration after the
    /// user lifts their finger.
    public var decelerationRate: CGFloat = UIScrollView.DecelerationRate.normal.rawValue

    internal init(for view: UIView, cameraManager: CameraAnimationsManagerProtocol) {
        self.cameraManager = cameraManager
        self.view = view
        super.init()
        configureGestureHandlers(for: options)
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
