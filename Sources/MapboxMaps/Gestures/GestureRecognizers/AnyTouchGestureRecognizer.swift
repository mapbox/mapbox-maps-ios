import UIKit.UIGestureRecognizerSubclass

internal final class DiscreteAnyTouchGestureRecognizer: AnyTouchGestureRecognizer {

    override func touchesAdded() {
        state = .recognized
    }

    override func touchesRemoved() {
    }
}

internal final class ContinuousAnyTouchGestureRecognizer: AnyTouchGestureRecognizer {

    override func touchesAdded() {
        state = .began
    }

    override func touchesRemoved() {
        if state == .began {
            state = .ended
        }
    }
}

internal class AnyTouchGestureRecognizer: UIGestureRecognizer {

    private let minimumPressDuration: TimeInterval

    private var timer: TimerProtocol?

    private var touches: Set<UITouch> = [] {
        didSet {
            if oldValue.isEmpty, !touches.isEmpty {
                timer = timerProvider.makeScheduledTimer(
                    timeInterval: minimumPressDuration,
                    repeats: false,
                    block: { [weak self] _ in
                        self?.touchesAdded()
                    })
            } else if !oldValue.isEmpty, touches.isEmpty {
                timer?.invalidate()
                timer = nil
                touchesRemoved()
            }
        }
    }

    private let timerProvider: TimerProviderProtocol

    internal init(minimumPressDuration: TimeInterval,
                  timerProvider: TimerProviderProtocol) {
        self.minimumPressDuration = minimumPressDuration
        self.timerProvider = timerProvider
        super.init(target: nil, action: nil)
        self.cancelsTouchesInView = false
    }

    internal func touchesAdded() {
        fatalError("subclasses must implement")
    }

    internal func touchesRemoved() {
        fatalError("subclasses must implement")
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
