import UIKit.UIGestureRecognizerSubclass

final class AnyTouchGestureRecognizer: UIGestureRecognizer {

    private var touches: Set<UITouch> = [] {
        didSet {
            if oldValue.isEmpty, !touches.isEmpty {
                state = .began
            } else if !oldValue.isEmpty, touches.isEmpty {
                state = .ended
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        self.touches.formUnion(touches)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesEnded(touches, with: event)
        self.touches.subtract(touches)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesCancelled(touches, with: event)
        self.touches.subtract(touches)
    }

    override func reset() {
        super.reset()
        touches = []
    }

    override func canBePrevented(by preventingGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

    override func canPrevent(_ preventedGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
