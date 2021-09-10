import UIKit
import CoreLocation

public protocol GestureManagerDelegate: AnyObject {

    /// Informs the delegate that a gesture haas begun. Could be used to cancel camera tracking.
    func gestureBegan(for gestureType: GestureType)
}

public final class GestureManager {

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

    /// Internal delegate for gesture recognizers
    // swiftlint:disable:next weak_delegate
    internal let gestureRecognizerDelegate: GestureRecognizerDelegate

    internal init(view: UIView, cameraAnimationsManager: CameraAnimationsManagerProtocol, mapboxMap: MapboxMap) {
        self.view = view
        self.cameraAnimationsManager = cameraAnimationsManager
        self.mapboxMap = mapboxMap
        self.gestureRecognizerDelegate = GestureRecognizerDelegate()
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
                                                                            cameraAnimationsManager: cameraAnimationsManager,
                                                                            mapboxMap: mapboxMap,
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
            gestureRecognizer.delegate = gestureRecognizerDelegate
        }
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
                    duration: Double(options.decelerationRate),
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

    func pinchChanged(withZoomIncrement zoomIncrement: CGFloat,
                      targetAnchor: CGPoint,
                      initialAnchor: CGPoint,
                      initialCameraState: CameraState) {

        var cameraOptions = CameraOptions()
        cameraOptions.center     = initialCameraState.center
        cameraOptions.padding    = initialCameraState.padding
        cameraOptions.zoom       = initialCameraState.zoom

        mapboxMap.setCamera(to: cameraOptions)

        mapboxMap.dragStart(for: initialAnchor)
        let dragOptions = mapboxMap.dragCameraOptions(from: initialAnchor, to: targetAnchor)
        mapboxMap.setCamera(to: dragOptions)
        mapboxMap.dragEnd()

        mapboxMap.setCamera(to: CameraOptions(anchor: targetAnchor,
                                              zoom: mapboxMap.cameraState.zoom + zoomIncrement))
    }

    internal func pinchEnded() {
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
