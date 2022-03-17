import UIKit

internal final class AnyTouchGestureHandler: GestureHandler {

    private let cameraAnimatorsRunnerEnablable: MutableEnablableProtocol

    internal init(gestureRecognizer: UIGestureRecognizer,
                  cameraAnimatorsRunnerEnablable: MutableEnablableProtocol) {
        self.cameraAnimatorsRunnerEnablable = cameraAnimatorsRunnerEnablable
        super.init(gestureRecognizer: gestureRecognizer)
        gestureRecognizer.addTarget(self, action: #selector(handleGesture(_:)))
    }

    @objc private func handleGesture(_ gestureRecognizer: AnyTouchGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            cameraAnimatorsRunnerEnablable.isEnabled = false
        case .ended, .cancelled:
            cameraAnimatorsRunnerEnablable.isEnabled = true
        default:
            break
        }
    }
}
