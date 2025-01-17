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
        private var cancelable: AnyCancelable?

        init(signal: Signal, subscriber: S) {
            self.signal = signal
            self.subscriber = subscriber
        }

        func request(_ demand: Subscribers.Demand) {
            // Signal doesn't implement backpressure concept, so we ignore demand here.
            cancelable = signal.observe { [weak self] payload in
                _ = self?.subscriber.receive(payload)
            }
        }

        func cancel() {
            cancelable?.cancel()
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
