/// Allows to store a closure handlers for some event.
class ClosureHandlersStore<Payload, ReturnType> {
    typealias Handler = (Payload) -> ReturnType
    typealias ObservationHandler = (Bool) -> Void
    typealias ObjectHandler = ObjectWrapper<Handler>

    var onObserved: ObservationHandler?

    private var objectHandlers = [ObjectHandler]() {
        didSet {
            if oldValue.isEmpty && !objectHandlers.isEmpty {
                onObserved?(true)
            } else if objectHandlers.isEmpty && !oldValue.isEmpty {
                onObserved?(false)
            }
        }
    }

    func add(handler: @escaping Handler) -> AnyCancelable {
        let objectHandler = ObjectHandler(subject: handler)
        objectHandlers.append(objectHandler)

        // Use of AnyCancelable here allows to have unambiguous cancellation behavior:
        // If you don't store the cancellable, it inevitably cancels the subscription.
        return AnyCancelable {
            self.cancel(handler: objectHandler)
        }
    }

    private func cancel(handler: ObjectHandler) {
        objectHandlers.removeAll(where: { $0 === handler })
    }
}

extension ClosureHandlersStore: Sequence {
    struct Iterator: IteratorProtocol {
        private var proxy: Array<ObjectHandler>.Iterator
        init(proxy: Array<ObjectHandler>.Iterator) {
            self.proxy = proxy
        }

        mutating func next() -> Handler? {
            proxy.next()?.subject
        }
    }

    func makeIterator() -> Iterator {
        return Iterator(proxy: objectHandlers.makeIterator())
    }
}

extension ClosureHandlersStore where ReturnType == Void {
    /// Use `signal` to subscribe to events.
    var signal: Signal<Payload> {
        Signal { [weak self] handler in
            self?.add(handler: handler) ?? .empty
        }
    }

    /// Sends payload to every handler.
    func send(_ payload: Payload) {
        for handler in self {
            handler(payload)
        }
    }
}

extension ClosureHandlersStore where Payload == Void, ReturnType == Void {
    func send() {
        send(())
    }
}
