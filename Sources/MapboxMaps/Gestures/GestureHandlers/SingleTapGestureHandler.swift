import UIKit

/// `SingleTapGestureHandler` manages a gesture recognizer looking for single tap touch events
final class SingleTapGestureHandler: GestureHandler {
    var onTap: Signal<CGPoint> { onTapSubject.signal }
    private let onTapSubject = SignalSubject<CGPoint>()

    private let cameraAnimationsManager: CameraAnimationsManagerProtocol

    init(
        gestureRecognizer: UITapGestureRecognizer,
        cameraAnimationsManager: CameraAnimationsManagerProtocol
    ) {
        self.cameraAnimationsManager = cameraAnimationsManager
        gestureRecognizer.numberOfTapsRequired = 1
        gestureRecognizer.numberOfTouchesRequired = 1
        super.init(gestureRecognizer: gestureRecognizer)
        gestureRecognizer.addTarget(self, action: #selector(handleGesture(_:)))
        gestureRecognizer.delegate = self
    }

    @objc private func handleGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        switch gestureRecognizer.state {
        case .recognized:
            cameraAnimationsManager.cancelAnimations()
            let point = gestureRecognizer.location(in: gestureRecognizer.view)
            onTapSubject.send(point)
            delegate?.gestureBegan(for: .singleTap)
            delegate?.gestureEnded(for: .singleTap, willAnimate: false)
        default:
            break
        }
    }
}

extension SingleTapGestureHandler: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        assert(self.gestureRecognizer == gestureRecognizer)

        guard gestureRecognizer.attachedToSameView(as: otherGestureRecognizer) else { return true }

        return otherGestureRecognizer is UITapGestureRecognizer
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldReceive touch: UITouch
    ) -> Bool {
        assert(self.gestureRecognizer == gestureRecognizer)

        /// Only handle touches that targeting the map not view annotations.
        guard gestureRecognizer.attachedToSameView(as: touch) else {
            return false
        }

        return true
    }
}
