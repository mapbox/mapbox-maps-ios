import UIKit

internal final class AnyTouchGestureHandler: GestureHandler {
    private let cameraAnimationsManager: CameraAnimationsManagerProtocol

    internal init(gestureRecognizer: UIGestureRecognizer,
                  cameraAnimationsManager: CameraAnimationsManagerProtocol) {
        self.cameraAnimationsManager = cameraAnimationsManager
        super.init(gestureRecognizer: gestureRecognizer)
        gestureRecognizer.delegate = self
        gestureRecognizer.addTarget(self, action: #selector(handleGesture(_:)))
    }

    @objc private func handleGesture(_ gestureRecognizer: UIGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            cameraAnimationsManager.cancelAnimations()
        default:
            break
        }
    }
}

extension AnyTouchGestureHandler: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
