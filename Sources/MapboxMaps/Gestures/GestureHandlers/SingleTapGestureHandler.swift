import UIKit

/// `SingleTapGestureHandler` manages a gesture recognizer looking for single tap touch events
internal final class SingleTapGestureHandler: GestureHandler {
    
    internal init(gestureRecognizer: UITapGestureRecognizer,
                  mapboxMap: MapboxMapProtocol,
                  cameraAnimationsManager: CameraAnimationsManagerProtocol) {
        gestureRecognizer.numberOfTapsRequired = 1
        gestureRecognizer.numberOfTouchesRequired = 1
        super.init(
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
        gestureRecognizer.addTarget(self, action: #selector(handleGesture(_:)))
    }
    
    @objc private func handleGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        switch gestureRecognizer.state {
        case .recognized:
            cameraAnimationsManager.cancelAnimations()
            delegate?.gestureBegan(for: .singleTap)
        default:
            break
        }
    }
}
