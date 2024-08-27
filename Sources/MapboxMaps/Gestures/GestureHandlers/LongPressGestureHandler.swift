import UIKit

final class LongPressGestureHandler: GestureHandler, UIGestureRecognizerDelegate {
    private let map: MapboxMapProtocol

    init(gestureRecognizer: UILongPressGestureRecognizer, map: MapboxMapProtocol) {
        self.map = map
        super.init(gestureRecognizer: gestureRecognizer)
        gestureRecognizer.addTarget(self, action: #selector(handleGesture(_:)))
        gestureRecognizer.delegate = self
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        assert(gestureRecognizer == self.gestureRecognizer)

        guard gestureRecognizer.attachedToSameView(as: otherGestureRecognizer) else { return true }

        return otherGestureRecognizer is UILongPressGestureRecognizer
    }

    @objc private func handleGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        assert(gestureRecognizer == self.gestureRecognizer)
        let point = gestureRecognizer.location(in: gestureRecognizer.view).screenCoordinate
        switch gestureRecognizer.state {
        case .began:
            map.dispatch(event: CorePlatformEventInfo(type: .longClick, screenCoordinate: point))
            map.dispatch(event: CorePlatformEventInfo(type: .dragBegin, screenCoordinate: point))

        case .changed:
            map.dispatch(event: CorePlatformEventInfo(type: .drag, screenCoordinate: point))

        case .ended, .cancelled:
            map.dispatch(event: CorePlatformEventInfo(type: .dragEnd, screenCoordinate: point))

        default:
            break
        }
    }
}
