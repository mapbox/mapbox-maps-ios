/// Allows to store a closure handlers for some event.
class ClosureHandlersStore<Payload, ReturnType> {
    typealias Handler = (Payload) -> ReturnType
    typealias ObservationHandler = (Bool) -> Void
    typealias ObjectHandler = ObjectWrapper<Handler>

    /// The handler is always invoked on the main thread.
    var onObserved: ObservationHandler? {
        get { lock.withLock { _onObserved } }
        set { lock.withLock { _onObserved = newValue } }
    }

    // Guards `objectHandlers` so add/cancel/iteration can run on different threads at once.
    private let lock = NSLock()
    private var objectHandlers = [ObjectHandler]()
    // All guarded by `lock`.
    private var _onObserved: ObservationHandler?
    private var notifiedObserved = false
    // Number of `onObserved` deliveries queued on the main queue but not yet run.
    private var pendingObservations = 0

    func add(handler: @escaping Handler) -> AnyCancelable {
        let objectHandler = ObjectHandler(subject: handler)
        lock.withLock { objectHandlers.append(objectHandler) }
        notifyObservedIfNeeded()

        // Use of AnyCancelable here allows to have unambiguous cancellation behavior:
        // If you don't store the cancellable, it inevitably cancels the subscription.
        return AnyCancelable {
            self.cancel(handler: objectHandler)
        }
    }

    private func cancel(handler: ObjectHandler) {
        lock.withLock { objectHandlers.removeAll(where: { $0 === handler }) }
        notifyObservedIfNeeded()
    }

    /// Fires `onObserved` on the main thread exactly once per empty↔non-empty transition, in order.
    /// The sync path exists so current-value signals can react and emit immediately when already
    /// on main; `pendingObservations` stops it from jumping ahead of an already-queued async call.
    private func notifyObservedIfNeeded() {
        lock.lock()
        let observed = !objectHandlers.isEmpty
        guard observed != notifiedObserved else {
            lock.unlock()
            return
        }
        notifiedObserved = observed
        let handler = _onObserved

        if Thread.isMainThread && pendingObservations == 0 {
            lock.unlock()
            handler?(observed)
            return
        }

        pendingObservations += 1
        DispatchQueue.main.async { [self] in
            handler?(observed)
            lock.withLock { pendingObservations -= 1 }
        }
        lock.unlock()
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
        // Snapshot the handlers under the lock (O(1) COW retain)
        // `send` then iterates and calls them outside the lock.
        lock.withLock { Iterator(proxy: objectHandlers.makeIterator()) }
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
