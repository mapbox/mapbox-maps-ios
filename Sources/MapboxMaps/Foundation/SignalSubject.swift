/// `SignalSubject` is used to send events to `Signal` subscribers.
///
/// It doesn't store current values, like `PassthroughSubject` from Combine.
internal class SignalSubject<Payload> {
    typealias Handler = Signal<Payload>.Handler
    typealias ObservationHandler = (Bool) -> Void
    private typealias Subscription = ObjectWrapper<Handler>

    /// Use `signal` to subscribe to events.
    let signal: Signal<Payload>

    private let onObserved: ObservationHandler?

    private var subscriptions = [Subscription]() {
        didSet {
            if oldValue.isEmpty && !subscriptions.isEmpty {
                onObserved?(true)
            } else if subscriptions.isEmpty && !oldValue.isEmpty {
                onObserved?(false)
            }
        }
    }

    /// Creates SignalSubject.
    ///
    /// - Parameters:
    ///     onObserved: A callback recieves `true` when the first observer is added, and `false` when last observer is gone.
    init(onObserved: ObservationHandler? = nil) {
        self.onObserved = onObserved

        weak var weakSelf: SignalSubject?
        self.signal = Signal(observeImpl: { handler in
            assert(weakSelf != nil, "Subscription to deallocated subject")
            return weakSelf?.observe(handler: handler) ?? AnyCancelable {}
        })
        weakSelf = self
    }

    /// Sends payload to every subscriber.
    func send(_ payload: Payload) {
        let s = subscriptions
        s.forEach {
            $0.subject(payload)
        }
    }

    private func cancel(subscription: Subscription) {
        subscriptions.removeAll(where: { $0 === subscription })
    }

    private func observe(handler: @escaping Handler) -> AnyCancelable {
        let subscription = Subscription(subject: handler)
        subscriptions.append(subscription)

        // Use of AnyCancelable here allows to have unambigous cancellation behaviour:
        // If you don't store the cancellable, it inevitably cancels the subscription.
        return AnyCancelable {
            self.cancel(subscription: subscription)
        }
    }
}

extension SignalSubject {
    /// Creates SignalSubject from callback-style subscription method.
    ///
    ///  Subscribes to the underlying event only when there are at least one subscriber.
    ///
    /// - Parameters:
    ///   - method: A closure that subscribes to certain event in callback-style.
    static func from(method: @escaping (@escaping Handler) -> Cancelable) -> SignalSubject {
        var cancellable: Cancelable?
        weak var weakSelf: SignalSubject?
        let subject = SignalSubject { observed in
            if observed {
                assert(cancellable == nil)
                cancellable = method { payload in
                    assert(weakSelf != nil)
                    weakSelf?.send(payload)
                }
            } else {
                cancellable?.cancel()
                cancellable = nil
            }
        }
        weakSelf = subject
        return subject
    }

    /// Initializes SignalSubject from callback-style subscription methods, that takes additional parameter (e.g event name).
    ///
    ///  Subscribes to the underlying event only when there are at least one subscriber.
    ///
    /// - Parameters:
    ///   - parameter: Parameter to pass to subsctiption method
    ///   - method: A closure that subscribes to certain event in callback-style.
    static func from<T>(
        parameter: T,
        method: @escaping (T, @escaping Handler) -> Cancelable
    ) -> SignalSubject {
        .from(method: { handler in
            method(parameter, handler)
        })
    }
}
