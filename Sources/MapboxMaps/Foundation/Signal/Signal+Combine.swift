import Combine

extension Signal: Combine.Publisher {
    public typealias Output = Payload
    public typealias Failure = Never

    public func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Never, S.Input == Payload {
        let subscription = Subscription(signal: self, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
}

private extension Signal {
    private class Subscription<S: Subscriber>: Combine.Subscription where S.Input == Payload {
        private let signal: Signal
        private let subscriber: S
        // Combine allows `request` and `cancel` to arrive on different threads;
        // the lock keeps them from tearing `cancelable`/`isCancelled`.
        private let lock = NSLock()
        private var cancelable: AnyCancelable?
        private var isCancelled = false
        private var hasSubscribed = false

        init(signal: Signal, subscriber: S) {
            self.signal = signal
            self.subscriber = subscriber
        }

        func request(_ demand: Subscribers.Demand) {
            // Signal has no backpressure — subscribe once, ignore any further demand.
            let shouldSubscribe = lock.withLock { () -> Bool in
                guard !isCancelled, !hasSubscribed else { return false }
                hasSubscribed = true
                return true
            }
            guard shouldSubscribe else { return }

            // Observe outside the lock: a current-value signal delivers synchronously,
            // and the subscriber may cancel from within that delivery (re-entering `cancel`).
            let token = signal.observe { [weak self] payload in
                _ = self?.subscriber.receive(payload)
            }
            let cancelledWhileSubscribing = lock.withLock { () -> Bool in
                guard !isCancelled else { return true }
                cancelable = token
                return false
            }
            if cancelledWhileSubscribing {
                // Cancelled while we were subscribing — tear down right away.
                token.cancel()
            }
        }

        func cancel() {
            let token: AnyCancelable? = lock.withLock {
                isCancelled = true
                let token = cancelable
                cancelable = nil
                return token
            }
            token?.cancel()
        }
    }
}

extension Publisher where Failure == Never {
    /// Wraps this publisher into a signal.
    public func eraseToSignal() -> Signal<Output> {
        Signal { handler in
            let token = self.sink(receiveValue: handler)
            return AnyCancelable {
                token.cancel()
            }
        }
    }
}
