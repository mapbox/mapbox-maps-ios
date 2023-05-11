/// Signal is a typed interface for observing arbitrary values over time.
///
/// Signal is stateless, which means it doesn't store any payloads sent to it.
public struct Signal<Payload> {
    /// Handles received payloads.
    public typealias Handler = (Payload) -> Void

    /// A closure that implements observing.
    public typealias ObserveImpl = (@escaping Handler) -> AnyCancelable

    private let observeImpl: ObserveImpl

    /// Adds an observer closure that will be called every time signal is triggered.
    ///
    /// - Parameters:
    ///     - handler: A handler closure.
    /// - Returns: Cancellable object that is used to cancel the subscription. If it is canceled or deinited the subscription will be cancelled immediately.
    public func observe(_ handler: @escaping Handler) -> AnyCancelable {
        self.observeImpl(handler)
    }

    /// Creates a signal.
    ///
    /// - Parameters:
    ///     - observeImpl: A closure that implements observing.
    public init(observeImpl: @escaping ObserveImpl) {
        self.observeImpl = observeImpl
    }
}

extension Signal {
    /// Adds an observer closure that will be triggered only once.
    ///
    /// - Parameters:
    ///     - handler: A handler closure.
    /// - Returns: Cancellable object that is used to cancel the subscription. If it is canceled or deinited the subscription will be cancelled immediately.
    public func observeNext(_ handler: @escaping Handler) -> AnyCancelable {
        takeFirst().observe(handler)
    }
}

extension Signal {
    /// Creates a signal that triggers once, then cancels itself.
    internal func takeFirst() -> Signal {
        return Signal { handler in
            weak var weakToken: AnyCancelable?
            let token = self.observe { payload in
                weakToken?.cancel()
                handler(payload)
            }
            weakToken = token
            return token
        }
    }

    /// Creates a signal that is enabled only when isEnabled value is `true`.
    internal func conditional(_ isEnabled: Ref<Bool>) -> Signal {
        Signal(observeImpl: { handle in
            observeImpl { payload in
                if isEnabled.value {
                    return handle(payload)
                }
            }
        })
    }

    /// Creates  a Signal that combines values and errors signals into resulting signal.
    internal func combine<E>(withError other: Signal<E>) -> Signal<Result<Payload, E>> {
        return Signal<Result<Payload, E>> { handler in
            AnyCancelable([
                self.observe { payload in
                    handler(.success(payload))
                },
                other.observe { e in
                    handler(.failure(e))
                }
            ])
        }
    }
}
