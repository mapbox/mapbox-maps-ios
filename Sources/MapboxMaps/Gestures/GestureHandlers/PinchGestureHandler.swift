import UIKit

/// `PinchGestureHandler` updates the map camera in response to a 2-touch
/// gesture that may consist of translation and scaling
internal final class PinchGestureHandler: GestureHandler {
    // The midpoint of the touches in the gesture's view when the gesture began
    private var initialPinchMidpoint: CGPoint?

    // The camera state when the gesture began
    private var initialCameraState: CameraState?

    // Initialize the handler which creates the panGestureRecognizer and adds to the view
    internal init(gestureRecognizer: UIPinchGestureRecognizer,
                  mapboxMap: MapboxMapProtocol,
                  cameraAnimationsManager: CameraAnimationsManagerProtocol) {
        super.init(
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
        gestureRecognizer.addTarget(self, action: #selector(handleGesture(_:)))
    }

    @objc private func handleGesture(_ gestureRecognizer: UIPinchGestureRecognizer) {
        guard let view = gestureRecognizer.view else {
            return
        }

        let pinchCenterPoint = gestureRecognizer.location(in: view)

        switch gestureRecognizer.state {
        case .began:
            initialPinchMidpoint = pinchCenterPoint
            initialCameraState = mapboxMap.cameraState
            cameraAnimationsManager.cancelAnimations()
            delegate?.gestureBegan(for: .pinch)
        case .changed:
            guard gestureRecognizer.numberOfTouches == 2,
                  let initialCameraState = initialCameraState,
                  let initialPinchCenterPoint = initialPinchMidpoint else {
                return
            }
            cameraAnimationsManager.cancelAnimations()

            let zoomIncrement = log2(gestureRecognizer.scale)
            var cameraOptions = CameraOptions()
            cameraOptions.center = initialCameraState.center
            cameraOptions.padding = initialCameraState.padding
            cameraOptions.zoom = initialCameraState.zoom

            mapboxMap.setCamera(to: cameraOptions)

            mapboxMap.dragStart(for: initialPinchCenterPoint)
            let dragOptions = mapboxMap.dragCameraOptions(
                from: initialPinchCenterPoint,
                to: pinchCenterPoint)
            mapboxMap.setCamera(to: dragOptions)
            mapboxMap.dragEnd()

            mapboxMap.setCamera(
                to: CameraOptions(
                    anchor: pinchCenterPoint,
                    zoom: mapboxMap.cameraState.zoom + zoomIncrement))
        case .ended, .cancelled:
            initialPinchMidpoint = nil
            initialCameraState = nil
        default:
            break
        }
    }
}
