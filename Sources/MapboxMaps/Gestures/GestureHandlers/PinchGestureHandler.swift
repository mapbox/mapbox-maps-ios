import UIKit

/// The PinchGestureHandler is responsible for all `pinch` related infrastructure
/// Tells the view to update itself when required
internal class PinchGestureHandler: GestureHandler {
    private var previousScale: CGFloat = 0.0

    // The center point where the pinch gesture began
    private var initialPinchCenterPoint: CGPoint = .zero

    // The camera state when the pinch gesture began
    private var initialCameraState: CameraState!

    // TODO: Inject the deceleration rate as part of a configuration structure
    internal let decelerationRate = UIScrollView.DecelerationRate.normal.rawValue

    // TODO: Inject the minimum zoom as part of a configuration structure
    internal let minZoom: CGFloat = 0.0

    private let mapboxMap: MapboxMapProtocol
    private let cameraAnimationsManager: CameraAnimationsManagerProtocol

    // Initialize the handler which creates the panGestureRecognizer and adds to the view
    internal init(for view: UIView, withDelegate delegate: GestureHandlerDelegate, mapboxMap: MapboxMapProtocol, cameraAnimationsManager: CameraAnimationsManagerProtocol) {
        self.mapboxMap = mapboxMap
        self.cameraAnimationsManager = cameraAnimationsManager
        super.init(for: view, withDelegate: delegate)
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        view.addGestureRecognizer(pinch)
        gestureRecognizer = pinch
    }

    @objc internal func handlePinch(_ pinchGestureRecognizer: UIPinchGestureRecognizer) {

        cameraAnimationsManager.cancelAnimations()
        let pinchCenterPoint = pinchGestureRecognizer.location(in: view)

        if pinchGestureRecognizer.state == .began {

            self.previousScale = 1.0
            delegate.gestureBegan(for: .pinch)

            self.initialCameraState = mapboxMap.cameraState
            self.initialPinchCenterPoint = pinchCenterPoint

            /**
             TODO: Handle a concurrent rotate gesture here.
             Prioritize the correct gesture by comparing the velocity of competing gestures.
             */
        } else if pinchGestureRecognizer.state == .changed {
            if pinchGestureRecognizer.numberOfTouches < 2 {
                return
            }

            let zoomIncrement = log2(pinchGestureRecognizer.scale)
            var cameraOptions = CameraOptions()
            cameraOptions.center = initialCameraState.center
            cameraOptions.padding = initialCameraState.padding
            cameraOptions.zoom = initialCameraState.zoom

            mapboxMap.setCamera(to: cameraOptions)

            mapboxMap.dragStart(for: initialPinchCenterPoint)
            let dragOptions = mapboxMap.dragCameraOptions(from: initialPinchCenterPoint, to: pinchCenterPoint)
            mapboxMap.setCamera(to: dragOptions)
            mapboxMap.dragEnd()

            mapboxMap.setCamera(to: CameraOptions(anchor: pinchCenterPoint,
                                                  zoom: mapboxMap.cameraState.zoom + zoomIncrement))

            previousScale = pinchGestureRecognizer.scale
        }
    }
}
