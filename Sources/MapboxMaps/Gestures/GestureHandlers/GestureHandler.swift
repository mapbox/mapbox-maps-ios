import UIKit

internal protocol GestureHandlerDelegate: AnyObject {
    func gestureBegan(for gestureType: GestureType)

    func gestureEnded(for gestureType: GestureType, willAnimate: Bool)

    func animationEnded(for gestureType: GestureType)
}

internal class GestureHandler: NSObject {
    internal let gestureRecognizer: UIGestureRecognizer

    internal weak var delegate: GestureHandlerDelegate?

    init(gestureRecognizer: UIGestureRecognizer) {
        self.gestureRecognizer = gestureRecognizer
    }

    deinit {
        gestureRecognizer.view?.removeGestureRecognizer(gestureRecognizer)
    }

    private var pinchBeganCallCount = 0

    func balancedNotifyPinchBegan() {
        if pinchBeganCallCount == 0 {
            delegate?.gestureBegan(for: .pinch)
        }
        pinchBeganCallCount += 1
    }

    func balancedNotifyPinchEnded() {
        pinchBeganCallCount -= 1

        guard pinchBeganCallCount == 0 else {
            return
        }

        delegate?.gestureEnded(for: .pinch, willAnimate: false)
    }
}
