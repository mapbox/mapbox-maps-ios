/// Signal is a typed interface for observing arbitrary values over time.
///
/// Signal delegates observers managing logic to the `observeImpl` closure, but provides flexible interface for observing.
///
/// - Note: `Signal` is iOS12-compatible simplified alternative to `Combine.Publisher`. It's behavior is
/// aligned with Publisher for easier future migration to Combine. If your app supports iOS >= 13.0, use `Signal` as `Combine.Publisher` .
public struct Signal<Payload> {
    /// Handles received payloads.
    public typealias Handler = (Payload) -> Void

    /// A closure that implements observing.
    public typealias ObserveImpl = (@escaping Handler) -> AnyCancelable

    private let observeImpl: ObserveImpl

    /// Adds an observer closure that will be called every time signal is triggered.
    ///
    /// - Note: Analogous to `sink` in Combine.
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
    /// Creates a signal that sends payload once to every subscribed.
    ///
    /// - Note: The created signal is analogous to the `Combine.Just`.
    ///
    /// - Parameters:
    ///   - constant: A payload.
    public init(just constant: Payload) {
        self.init { handler in
            handler(constant)
            return .empty
        }
    }

    /// Adds an observer closure that will be triggered only once.
    ///
    /// - Note: Analogous to `prefix(1).sink` in Combine.
    ///
    /// - Parameters:
    ///     - handler: A handler closure.
    /// - Returns: Cancellable object that is used to cancel the subscription. If it is canceled or deinited the subscription will be cancelled immediately.
    public func observeNext(_ handler: @escaping Handler) -> AnyCancelable {
        takeFirst().observe(handler)
    }
}

// NOTE: Signal implements the Combine.Publisher, which means every operator available for
// Publisher (such as `map`, `prefix`, `sink` and others) may be used on Signal.
// It means that Signal's naming shouldn't collide with Combine for better user experience.
// We don't ship full-featured reactive framework (which Combine is) with Maps SDK,
// so be careful with publishing operators on Signal.
// Currently only the `observe` and `observeNext` are published which seem to be enough
// for the most common use cases.
extension Signal {
    /// Creates a signal that triggers once, then cancels itself.
    func takeFirst() -> Signal {
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

    /// Creates a signal that triggers if `condition` is `true`.
    func filter(_ condition: @escaping (Payload) -> Bool) -> Signal {
        Signal(observeImpl: { handle in
            observeImpl { payload in
                if condition(payload) {
                    handle(payload)
                }
            }
        })
    }

    /// Creates a signal that is enabled only when `isEnabled` value is `true`.
    func conditional(_ isEnabled: Ref<Bool>) -> Signal {
        filter { _ in isEnabled.value }
    }

    func map<U>(_ transform: @escaping (Payload) -> U) -> Signal<U> {
        Signal<U> { handler in
            return self.observe { payload in
                handler(transform(payload))
            }
        }
    }

    func compactMap<U>(_ transform: @escaping (Payload) -> U?) -> Signal<U> {
        return Signal<U> { handler in
            return self.observe { payload in
                if let transformed = transform(payload) {
                    handler(transformed)
                }
            }
        }
    }

    func skipNil<U>() -> Signal<U> where Payload == U? {
        compactMap { $0 }
    }

    /// Returns Signal that retains the given object while signal subscription is alive.
    func retaining(_ object: AnyObject) -> Signal {
        map { payload in
            withExtendedLifetime(object) { payload }
        }
    }

    /// Removes values that equal to the previous value from the stream.
    func skipRepeats(by isEqual: @escaping (Payload, Payload) -> Bool) -> Signal {
        Signal { handler in
            var value: Payload?
            return self.observe { newValue in
                if value == nil || !isEqual(newValue, value!) {
                    value = newValue
                    handler(newValue)
                }
            }
        }
    }

    func skipRepeats() -> Signal where Payload: Equatable {
        skipRepeats(by: ==)
    }

    /// Used to implement ViewportState's observing pattern which handler closure can return `false` value to unsubscribe.
    /// See `ViewportState.observeDataSource`.
    func observeWithCancellingHandler(_ handler: @escaping (Payload) -> Bool) -> Cancelable {
        var capturedToken: AnyCancelable?
        var cancelled = false
        let token = self.observe { payload in
            cancelled = !handler(payload)
            if cancelled {
                capturedToken?.cancel()
            }
        }

        capturedToken = token

        // In case of immediate (synchronous) cancellation in `handler` closure
        // the token won't be cancelled. The following code handles it.
        if cancelled {
            token.cancel()
        }

        // The token is retained by the `observe` closure until `handler` cancels it.
        // The subscription will be alive even if call-site ignores cancellable.
        return token
    }
}

extension Signal {
    static func combineLatest<P1, P2>(_ s1: Signal<P1>, _ s2: Signal<P2>) -> Signal where Payload == (P1, P2) {
        Signal { handler in
            var last1: P1?
            var last2: P2?
            let handle = {
                if let last1, let last2 {
                    handler((last1, last2))
                }
            }
            return AnyCancelable([
                s1.observe { value in
                    last1 = value
                    handle()
                },
                s2.observe { value in
                    last2 = value
                    handle()
                }
            ])
        }
    }
}

extension Signal {
    /// Extracts the latest saved value from a caching Signal (such as CurrentValueSignalSubject).
    ///
    /// - Note: In general, this method is not recommended to use, since it has side effect
    /// of adding/removing observer. It's always better to subscribe to signal if you need it's values.
    var latestValue: Payload? {
        var payload: Payload?
        _ = observe { payload = $0 }
        return payload
    }
}

extension Signal {
    /// Calls method with every new value.
    func handle<Root: AnyObject>(in method: @escaping (Root) -> (Payload) -> Void, ofWeak root: Root) -> AnyCancelable {
        observe { [weak root] payload in
            guard let root else { return }
            let handler = method(root)
            handler(payload)
        }
    }

    /// Assigns every value to a property.
    func assign<Root: AnyObject>(to: ReferenceWritableKeyPath<Root, Payload>, ofWeak root: Root) -> AnyCancelable {
        observe { [weak root] payload in
            root?[keyPath: to] = payload
        }
    }
}
