import UIKit

/// `SingleTapGestureHandler` manages a gesture recognizer looking for single tap touch events
internal final class SingleTapGestureHandler: GestureHandler {

    private let cameraAnimationsManager: CameraAnimationsManagerProtocol

    internal init(gestureRecognizer: UITapGestureRecognizer,
                  cameraAnimationsManager: CameraAnimationsManagerProtocol) {
        gestureRecognizer.numberOfTapsRequired = 1
        gestureRecognizer.numberOfTouchesRequired = 1
        self.cameraAnimationsManager = cameraAnimationsManager
        super.init(gestureRecognizer: gestureRecognizer)
        gestureRecognizer.addTarget(self, action: #selector(handleGesture(_:)))
    }

    @objc private func handleGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        switch gestureRecognizer.state {
        case .recognized:
            cameraAnimationsManager.cancelAnimations()
            delegate?.gestureBegan(for: .singleTap)
            delegate?.gestureEnded(for: .singleTap, willAnimate: false)
        default:
            break
        }
    }
}
