import UIKit

internal class InterruptDecelerationGestureHandler: GestureHandler {
    private let cameraAnimationsManager: CameraAnimationsManagerProtocol

    init(gestureRecognizer: UIGestureRecognizer,
         cameraAnimationsManager: CameraAnimationsManagerProtocol) {
        self.cameraAnimationsManager = cameraAnimationsManager
        super.init(gestureRecognizer: gestureRecognizer)

        gestureRecognizer.addTarget(self, action: #selector(handleGesture(_:)))
        gestureRecognizer.delegate = self
    }

    @objc private func handleGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.state == .recognized else { return }

        cameraAnimationsManager.cancelAnimations(withOwners: [.cameraAnimationsManager],
                                                 andTypes: [.deceleration])
    }
}

extension InterruptDecelerationGestureHandler: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
