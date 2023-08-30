/// `SignalSubject` is used to send events to `Signal` subscribers.
///
/// It doesn't store current values, like `PassthroughSubject` from Combine.
typealias SignalSubject<Payload> = ClosureHandlersStore<Payload, Void>

extension SignalSubject where ReturnType == Void {
    /// Creates SignalSubject from callback-style subscription method.
    ///
    ///  Subscribes to the underlying event only when there are at least one subscriber.
    ///
    /// - Parameters:
    ///   - method: A closure that subscribes to certain event in callback-style.
    static func from(method: @escaping (@escaping Handler) -> Cancelable) -> SignalSubject<Payload> {
        var cancellable: Cancelable?

        let subject = SignalSubject<Payload>()
        subject.onObserved = { [weak subject] observed in
            if observed {
                assert(cancellable == nil)
                cancellable = method { payload in
                    assert(subject != nil)
                    subject?.send(payload)
                }
            } else {
                cancellable?.cancel()
                cancellable = nil
            }
        }
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
    ) -> SignalSubject<Payload> {
        .from(method: { handler in
            method(parameter, handler)
        })
    }
}
