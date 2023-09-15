import UIKit

extension Signal {
    /// Creates a signal that:
    /// - Proxies payloads from the source signal unless condition is false.
    /// - When condition is true, the payloads are blocked
    /// - When condition is false, the signal sends the latest blocked payload.
    ///
    /// Note: This is the encapsulated algorithm for blocking camera updates while batch camera update is in progress
    /// used in `MapBasicCoordinator`.
    func blockUpdates(while condition: Signal<Bool>) -> Signal<Payload> {
        return Signal { handler in
            var blocked = false
            var lastBlockedPayload: Payload?

            return AnyCancelable([
                condition.observe { condition in
                    let oldBlocked = blocked
                    blocked = condition
                    if oldBlocked != blocked, !blocked, let payload = lastBlockedPayload {
                        handler(payload)
                        lastBlockedPayload = nil
                    }
                },
                self.observe { payload in
                    if blocked {
                        lastBlockedPayload = payload
                    } else {
                        lastBlockedPayload = nil
                        handler(payload)
                    }
                }
            ])
        }
    }
}

extension Signal where Payload: UIGestureRecognizer {
    /// Creates a Signal that allows to observe the given gesture recognizer.
    /// The resulting signal is not stored anywhere and should be observed or stored immediately on the call site.
    init(gesture recognizer: Payload) {
        self.init { handler in
            let targetActionHandler = TargetActionHandler(recognizer) {
                handler(recognizer)
            }
            return AnyCancelable(targetActionHandler)
        }
    }
}

@objc private final class TargetActionHandler: NSObject, Cancelable {
    private let handle: () -> Void
    private let gesture: UIGestureRecognizer
    init(_ gesture: UIGestureRecognizer, _ handle: @escaping () -> Void) {
        self.gesture = gesture
        self.handle = handle
        super.init()
        gesture.addTarget(self, action: #selector(action))
    }

    @objc func action() {
        handle()
    }

    func cancel() {
        gesture.removeTarget(self, action: nil)
    }
}
