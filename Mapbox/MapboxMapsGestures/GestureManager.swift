import UIKit
import CoreLocation

#if canImport(MapboxMapsFoundation)
import MapboxMapsFoundation
#endif

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

public protocol GestureManagerDelegate {

    /// Informs the delegate that a gesture haas begun. Could be used to cancel camera tracking.
    func gestureBegan(for gestureType: GestureType) -> Void
}

public class GestureManager: NSObject {

    /// The `GestureOptions` that are used to set up the required gestures on the map
    internal var gestureOptions: GestureOptions!

    /// Map of GestureType --> GestureHandler. We mantain a map to allow us to remove gestures arbitrarily.
    internal var gestureHandlers: [GestureType: GestureHandler] = [:]

    /// The view that all gestures operate on
    internal weak var view: UIView?

    /// The camera manager that responds to gestures.
    private var cameraManager: CameraManager!

    public var delegate: GestureManagerDelegate?

    internal init(for view: UIView, options: GestureOptions, cameraManager: CameraManager) {
        super.init()
        self.view = view
        self.gestureOptions = options
        self.cameraManager = cameraManager
        self.configureGestureHandlers(for: options)
    }

    internal func updateGestureOptions(with newOptions: GestureOptions) {
        self.gestureOptions = newOptions
        self.configureGestureHandlers(for: newOptions)
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
            self.requireGestureToFail(allowedGesture: pitchHandler, failableGesture: panHandler)
        }

        if let doubleTapHandler = gestureHandlers[.tap(numberOfTaps: 2, numberOfTouches: 1)],
           let quickZoomHandler = gestureHandlers[.quickZoom] {
            self.requireGestureToFail(allowedGesture: quickZoomHandler, failableGesture: doubleTapHandler)
        }

        self.registerAsDelegate()
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

                let leftTouchPoint = panGesture.location(ofTouch: 0, in: self.view)
                let rightTouchPoint = panGesture.location(ofTouch: 1, in: self.view)

                guard let touchPointAngle = GestureUtilities.angleBetweenPoints(leftTouchPoint,
                                                                                rightTouchPoint) else { return false }

                let horizontalTiltTolerance = self.horizontalPitchTiltTolerance()

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

        guard let validPinchHandler = self.gestureHandlers[.pinch],
            let validPinchRecognizer = validPinchHandler.gestureRecognizer as? UIPinchGestureRecognizer else {
                return nil
        }

        return validPinchRecognizer.state
    }

    internal func fetchPinchScale() -> CGFloat? {

        guard let validPinchHandler = self.gestureHandlers[.pinch],
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

extension GestureManager: GestureHandlerDelegate {
    // MapView has been tapped a certain number of times
    internal func tapped(numberOfTaps: Int, numberOfTouches: Int) {

        guard let mapView = self.cameraManager.mapView else {
            return
        }

        // Single tapping twice with one finger will cause the map to zoom in
        if numberOfTaps == 2 && numberOfTouches == 1 {
            self.cameraManager.setCamera(zoom: mapView.cameraView.zoom + 1.0)
        }

        // Double tapping twice with two fingers will cause the map to zoom out
        if numberOfTaps == 2 && numberOfTouches == 2 {
            self.cameraManager.setCamera(zoom: mapView.zoom - 1.0)
        }
    }

    // MapView has been panned
    internal func panned(by displacement: CGPoint) {
        self.cameraManager.moveCamera(by: displacement)
    }

    // Pan has ended on the MapView with a residual `offset`
    internal func panEnded(with offset: CGPoint) {
        self.cameraManager.moveCamera(by: offset, animated: true, didFling: true)
    }

    internal func cancelGestureTransitions() {
        self.cameraManager.cancelTransitions()
    }

    internal func gestureBegan(for gestureType: GestureType) {
        self.cameraManager.cancelTransitions()
        self.delegate?.gestureBegan(for: gestureType)
    }

    internal func scaleForZoom() -> CGFloat {
        guard let mapView = cameraManager.mapView else {
            return 0
        }
        return pow(2, mapView.zoom)
    }

    internal func pinchScaleChanged(with newScale: CGFloat, andAnchor anchor: CGPoint) {
        cameraManager.setCamera(anchor: anchor, zoom: log2(newScale))
    }

    internal func pinchEnded(with finalScale: CGFloat, andDrift possibleDrift: Bool, andAnchor anchor: CGPoint) {
        cameraManager.setCamera(anchor: anchor, zoom: log2(finalScale))
        self.unrotateIfNeededForGesture(with: .ended)
    }

    internal func quickZoomChanged(with newScale: CGFloat, and anchor: CGPoint) {
        let zoom = max(newScale, cameraManager.mapCameraOptions.minimumZoomLevel)

        cameraManager.setCamera(anchor: anchor, zoom: zoom)
    }

    internal func quickZoomEnded() {
        self.unrotateIfNeededForGesture(with: .ended)
    }
    internal func isRotationAllowed() -> Bool {
        guard let mapView = cameraManager.mapView else {
            return false
        }

        return mapView.cameraView.zoom >= cameraManager.mapCameraOptions.minimumZoomLevel
    }

    internal func rotationStartAngle() -> CGFloat {
        guard let mapView = cameraManager.mapView else {
            return 0
        }
        return (mapView.cameraView.bearing * .pi) / 180.0 * -1
    }

    internal func rotationChanged(with changedAngle: CGFloat, and anchor: CGPoint, and pinchScale: CGFloat) {

        var changedAngleInDegrees = changedAngle * 180.0 / .pi * -1
        changedAngleInDegrees = changedAngleInDegrees.truncatingRemainder(dividingBy: 360.0)

        // Constraining `changedAngleInDegrees` to -30.0 to +30.0 degrees
        if self.isRotationAllowed() == false && abs(pinchScale) < 10 {
            changedAngleInDegrees = changedAngleInDegrees < -30.0 ? -30.0 : changedAngleInDegrees
            changedAngleInDegrees = changedAngleInDegrees > 30.0 ? 30.0 : changedAngleInDegrees
        }

        self.cameraManager.setCamera(bearing: CLLocationDirection(changedAngleInDegrees))
    }

    internal func rotationEnded(with finalAngle: CGFloat, and anchor: CGPoint, with pinchState: UIGestureRecognizer.State) {
        var finalAngleInDegrees = finalAngle * 180.0 / .pi * -1
        finalAngleInDegrees = finalAngleInDegrees.truncatingRemainder(dividingBy: 360.0)
        self.cameraManager.setCamera(bearing: CLLocationDirection(finalAngleInDegrees))
    }

    internal func unrotateIfNeededForGesture(with pinchState: UIGestureRecognizer.State) {
        guard let mapView = cameraManager.mapView else {
            return
        }

        // Avoid contention with in-progress gestures
        // let toleranceForSnappingToNorth: CGFloat = 7.0
        if mapView.cameraView.bearing != 0.0
            && pinchState != .began
            && pinchState != .changed {
            if mapView.cameraView.bearing != 0.0 && self.isRotationAllowed() == false {
                self.cameraManager.setCamera(bearing: 0.0)
            }

            // TODO: Add snapping behavior to "north" if bearing is less than some tolerance
            // else if abs(self.mapView.cameraView.bearing) < toleranceForSnappingToNorth
            //            || abs(self.mapView.cameraView.bearing) > 360.0 - toleranceForSnappingToNorth {
            //    self.transitionBearing(to: 0.0, animated: true)
            //}
        }
    }

    internal func initialPitch() -> CGFloat {
        guard let mapView = cameraManager.mapView else {
            return 0
        }
        return mapView.cameraView.pitch
    }

    internal func horizontalPitchTiltTolerance() -> Double {
        return 45.0
    }

    internal func pitchChanged(newPitch: CGFloat) {
        self.cameraManager.setCamera(pitch: newPitch)
    }

    internal func pitchEnded() {
    }
}
