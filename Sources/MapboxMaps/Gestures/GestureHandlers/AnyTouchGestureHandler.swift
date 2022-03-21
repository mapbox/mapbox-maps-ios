import UIKit

internal final class AnyTouchGestureHandler: GestureHandler {

    private let cameraAnimatorsRunner: CameraAnimatorsRunnerProtocol

    internal init(gestureRecognizer: UIGestureRecognizer,
                  cameraAnimatorsRunner: CameraAnimatorsRunnerProtocol) {
        self.cameraAnimatorsRunner = cameraAnimatorsRunner
        super.init(gestureRecognizer: gestureRecognizer)
        gestureRecognizer.addTarget(self, action: #selector(handleGesture(_:)))
    }

    @objc private func handleGesture(_ gestureRecognizer: AnyTouchGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            cameraAnimatorsRunner.animationsEnabled = false
        case .ended, .cancelled:
            cameraAnimatorsRunner.animationsEnabled = true
        default:
            break
        }
    }
}
