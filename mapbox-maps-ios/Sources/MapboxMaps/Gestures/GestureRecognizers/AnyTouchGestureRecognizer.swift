import UIKit.UIGestureRecognizerSubclass

internal final class AnyTouchGestureRecognizer: UIGestureRecognizer {

    private let minimumPressDuration: TimeInterval

    private var timer: TimerProtocol?

    private var touches: Set<UITouch> = [] {
        didSet {
            if oldValue.isEmpty, !touches.isEmpty {
                timer = timerProvider.makeScheduledTimer(
                    timeInterval: minimumPressDuration,
                    repeats: false,
                    block: { [weak self] _ in
                        self?.state = .began
                    })
            } else if !oldValue.isEmpty, touches.isEmpty {
                timer?.invalidate()
                timer = nil
                // handling .changed here because even though
                // this class never sets state to .changed,
                // the superclass does so automatically if
                // the touch input changes after .began
                switch state {
                case .began, .changed:
                    state = .ended
                default:
                    state = .failed
                }
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
        self.delaysTouchesEnded = false
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
