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
    public var panGestureRecognizer: UIGestureRecognizer? {
        return gestureHandlers[.pan]?.gestureRecognizer
    }

    /// The underlying gesture recognizer for the "double tap to zoom in" gesture
    public var doubleTapToZoomInGestureRecognizer: UIGestureRecognizer? {
        return gestureHandlers[.tap(numberOfTaps: 2, numberOfTouches: 1)]?.gestureRecognizer
    }

    /// The underlying gesture recognizer for the "double tap to zoom out" gesture
    public var doubleTapToZoomOutGestureRecognizer: UIGestureRecognizer? {
        return gestureHandlers[.tap(numberOfTaps: 2, numberOfTouches: 2)]?.gestureRecognizer
    }

    /// The underlying gesture recognizer for the quickZoom gesture
    public var quickZoomGestureRecognizer: UIGestureRecognizer? {
        return gestureHandlers[.quickZoom]?.gestureRecognizer
    }

    /// The underlying gesture recognizer for the pitch gesture
    public var pitchGestureRecognizer: UIGestureRecognizer? {
        return gestureHandlers[.pitch]?.gestureRecognizer
    }

    /// The underlying gesture recognizer for the rotate gesture
    public var rotationGestureRecognizer: UIGestureRecognizer? {
        return gestureHandlers[.rotate]?.gestureRecognizer
    }

    /// The underlying gesture recognizer for the "pinch to zoom" gesture
    public var pinchGestureRecognizer: UIGestureRecognizer? {
        return gestureHandlers[.pinch]?.gestureRecognizer
    }

    /// The view that all gestures operate on
    private weak var view: UIView?

    /// The camera manager that responds to gestures.
    private let cameraAnimationsManager: CameraAnimationsManagerProtocol

    private let mapboxMap: MapboxMap

    /// Set this delegate to be called back if a gesture begins
    public weak var delegate: GestureManagerDelegate?

    /// A floating-point value that determines the rate of deceleration after the
    /// user lifts their finger.
    public var decelerationRate: CGFloat = UIScrollView.DecelerationRate.normal.rawValue

    internal init(view: UIView, cameraAnimationsManager: CameraAnimationsManagerProtocol, mapboxMap: MapboxMap) {
        self.view = view
        self.cameraAnimationsManager = cameraAnimationsManager
        self.mapboxMap = mapboxMap
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

        if let pinchHandler = gestureHandlers[.pinch], let panHandler = gestureHandlers[.pan] {
            requireGestureToFail(allowedGesture: pinchHandler, failableGesture: panHandler)
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

        return (gestureRecognizer is UIPinchGestureRecognizer
            || gestureRecognizer is UIRotationGestureRecognizer) &&
            (otherGestureRecognizer is UIPinchGestureRecognizer
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

extension GestureManager: GestureHandlerDelegate {
    // MapView has been tapped a certain number of times
    internal func tapped(numberOfTaps: Int, numberOfTouches: Int) {
        // Single tapping twice with one finger will cause the map to zoom in
        if numberOfTaps == 2 && numberOfTouches == 1 {
            _ = cameraAnimationsManager.ease(to: CameraOptions(zoom: mapboxMap.cameraState.zoom + 1.0),
                                   duration: 0.3,
                                   curve: .easeOut,
                                   completion: nil)
        }

        // Double tapping twice with two fingers will cause the map to zoom out
        if numberOfTaps == 2 && numberOfTouches == 2 {
            _ = cameraAnimationsManager.ease(to: CameraOptions(zoom: mapboxMap.cameraState.zoom - 1.0),
                                   duration: 0.3,
                                   curve: .easeOut,
                                   completion: nil)
        }
    }

    internal func panBegan(at point: CGPoint) {
        mapboxMap.dragStart(for: point)
    }

    // MapView has been panned
    internal func panned(from startPoint: CGPoint, to endPoint: CGPoint) {
        let cameraOptions = mapboxMap.dragCameraOptions(from: startPoint, to: endPoint)
        mapboxMap.setCamera(to: cameraOptions)
    }

    // Pan has ended on the MapView with a residual `offset`
    func panEnded(at endPoint: CGPoint, shouldDriftTo driftEndPoint: CGPoint) {
        if endPoint != driftEndPoint {
            let driftCameraOptions = mapboxMap.dragCameraOptions(from: endPoint, to: driftEndPoint)
            _ = cameraAnimationsManager.ease(
                    to: driftCameraOptions,
                    duration: Double(decelerationRate),
                    curve: .easeOut,
                    completion: nil)
        }
        mapboxMap.dragEnd()
    }

    internal func cancelGestureTransitions() {
        cameraAnimationsManager.cancelAnimations()
    }

    internal func gestureBegan(for gestureType: GestureType) {
        cameraAnimationsManager.cancelAnimations()
        delegate?.gestureBegan(for: gestureType)
    }

    internal func scaleForZoom() -> CGFloat {
        return mapboxMap.cameraState.zoom
    }

    internal func pinchChanged(with zoom: CGFloat, anchor: CGPoint, offset: CGSize) {
        mapboxMap.setCamera(to: CameraOptions(anchor: anchor, zoom: zoom))

        let currentCenterCoordinate = mapboxMap.cameraState.center
        let currentCenterScreenPoint = mapboxMap.point(for: currentCenterCoordinate)
        let newCenterScreenPoint = currentCenterScreenPoint.shifted(xOffset: -offset.width,
                                                                    yOffset: -offset.height)
        let newCenterCoordinate = mapboxMap.coordinate(for: newCenterScreenPoint)
        mapboxMap.setCamera(to: CameraOptions(center: newCenterCoordinate))
    }

    internal func pinchEnded(with finalScale: CGFloat, andDrift possibleDrift: Bool, andAnchor anchor: CGPoint) {
        mapboxMap.setCamera(to: CameraOptions(anchor: anchor, zoom: finalScale))
        unrotateIfNeededForGesture(with: .ended)
    }

    internal func quickZoomChanged(with newScale: CGFloat, and anchor: CGPoint) {
        let minZoom = CGFloat(mapboxMap.cameraBounds.minZoom)
        let maxZoom = CGFloat(mapboxMap.cameraBounds.maxZoom)
        let zoom = newScale.clamped(to: minZoom...maxZoom)
        mapboxMap.setCamera(to: CameraOptions(anchor: anchor, zoom: zoom))
    }

    internal func quickZoomEnded() {
        unrotateIfNeededForGesture(with: .ended)
    }
    internal func isRotationAllowed() -> Bool {
        let minZoom = CGFloat(mapboxMap.cameraBounds.minZoom)
        return mapboxMap.cameraState.zoom >= minZoom
    }

    internal func rotationStartAngle() -> CGFloat {
        return CGFloat((mapboxMap.cameraState.bearing * .pi) / 180.0 * -1)
    }

    internal func rotationChanged(with changedAngle: CGFloat, and anchor: CGPoint, and pinchScale: CGFloat) {
        var changedAngleInDegrees = changedAngle * 180.0 / .pi * -1
        changedAngleInDegrees = changedAngleInDegrees.truncatingRemainder(dividingBy: 360.0)

        // Constraining `changedAngleInDegrees` to -30.0 to +30.0 degrees
        if isRotationAllowed() == false && abs(pinchScale) < 10 {
            changedAngleInDegrees = changedAngleInDegrees < -30.0 ? -30.0 : changedAngleInDegrees
            changedAngleInDegrees = changedAngleInDegrees > 30.0 ? 30.0 : changedAngleInDegrees
        }

        mapboxMap.setCamera(
            to: CameraOptions(bearing: CLLocationDirection(changedAngleInDegrees)))
    }

    internal func rotationEnded(with finalAngle: CGFloat, and anchor: CGPoint, with pinchState: UIGestureRecognizer.State) {
        var finalAngleInDegrees = finalAngle * 180.0 / .pi * -1
        finalAngleInDegrees = finalAngleInDegrees.truncatingRemainder(dividingBy: 360.0)
        mapboxMap.setCamera(to: CameraOptions(bearing: CLLocationDirection(finalAngleInDegrees)))
    }

    internal func unrotateIfNeededForGesture(with pinchState: UIGestureRecognizer.State) {
        let currentBearing = mapboxMap.cameraState.bearing

        // Avoid contention with in-progress gestures
        // let toleranceForSnappingToNorth: CGFloat = 7.0
        if currentBearing != 0.0
            && pinchState != .began
            && pinchState != .changed {
            if currentBearing != 0.0 && isRotationAllowed() == false {
                mapboxMap.setCamera(to: CameraOptions(bearing: 0))
            }

            // TODO: Add snapping behavior to "north" if bearing is less than some tolerance
            // else if abs(self.mapView.cameraView.bearing) < toleranceForSnappingToNorth
            //            || abs(self.mapView.cameraView.bearing) > 360.0 - toleranceForSnappingToNorth {
            //    self.transitionBearing(to: 0.0, animated: true)
            //}
        }
    }

    internal func initialPitch() -> CGFloat {
        return mapboxMap.cameraState.pitch
    }

    internal func horizontalPitchTiltTolerance() -> Double {
        return 45.0
    }

    internal func pitchChanged(newPitch: CGFloat) {
        mapboxMap.setCamera(to: CameraOptions(pitch: newPitch))
    }

    internal func pitchEnded() {
    }
}
