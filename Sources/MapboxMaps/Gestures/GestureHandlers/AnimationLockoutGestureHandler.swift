#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

internal final class AnimationLockoutGestureHandler: GestureHandler {

    private let cameraAnimationsManager: CameraAnimationsManagerProtocol

    internal init(gestureRecognizer: UIGestureRecognizer,
                  cameraAnimationsManager: CameraAnimationsManagerProtocol) {
        gestureRecognizer.cancelsTouchesInView = false
        self.cameraAnimationsManager = cameraAnimationsManager
        super.init(gestureRecognizer: gestureRecognizer)
        gestureRecognizer.addTarget(self, action: #selector(handleGesture(_:)))
    }

    @objc private func handleGesture(_ gestureRecognizer: AnyTouchGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            cameraAnimationsManager.animationsEnabled = false
        case .ended, .cancelled:
            cameraAnimationsManager.animationsEnabled = true
        default:
            break
        }
    }
}
