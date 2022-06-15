import MapboxCoreMaps

internal protocol MapboxObservableProtocol: AnyObject {
    func subscribe(_ observer: Observer, events: [String])
    func unsubscribe(_ observer: Observer, events: [String])
    @available(*, deprecated, renamed: "onNext(event:handler:)")
    func onNext(_ eventTypes: [MapEvents.EventKind], handler: @escaping (Event) -> Void) -> Cancelable
    @available(*, deprecated, renamed: "onEvery(event:handler:)")
    func onEvery(_ eventTypes: [MapEvents.EventKind], handler: @escaping (Event) -> Void) -> Cancelable
    func onNext<Payload>(event: MapEvents.Event<Payload>, handler: @escaping (MapEvent<Payload>) -> Void) -> Cancelable
    func onEvery<Payload>(event: MapEvents.Event<Payload>, handler: @escaping (MapEvent<Payload>) -> Void) -> Cancelable
    func performWithoutNotifying(_ block: () -> Void)
}

/// `MapboxObservable` wraps the event listener APIs of ``MapboxCoreMaps/MBMObservable``,
/// re-exposing the subscribe/unsubscribe interfaces and adding onNext/onEvery block-based interfaces.
/// This design reduces duplication between ``MapboxMap`` and ``Snapshotter``, which can both
/// implement their public versions of this API via thin wrappers around this class.
///
/// Regardless of whether a listener is added via ``MapboxObservable/subscribe(_:events:)``,
/// ``MapboxObservalbe/onNext(_:handler:)``, or
/// ``MapboxObservable/onEvery(_:handler:)``, `MapboxObservable` wraps the provided
/// object or closure, keeps a strong reference to the wrapper, and passes the wrapper to
/// `MapboxCoreMaps`. This will enable us to build filtering capabilities by selectively ignoring certain
/// events regardless of which listener API was used.
internal final class MapboxObservable: MapboxObservableProtocol {

    private let observable: ObservableProtocol

    private var observerWrappers = [ObjectIdentifier: ObserverWrapper]()

    internal init(observable: ObservableProtocol) {
        self.observable = observable
    }

    deinit {
        for observer in observerWrappers.values {
            observable.unsubscribe(for: observer)
        }
    }

    internal func subscribe(_ observer: Observer, events: [String]) {
        // maintain only one wrapper per observer. merge current and new events.
        var allEvents = Set(events)
        if let oldWrapper = observerWrappers[ObjectIdentifier(observer)] {
            guard Set(oldWrapper.events) != allEvents else {
                return
            }
            allEvents.formUnion(oldWrapper.events)
            observable.unsubscribe(for: oldWrapper)
        }
        let allEventsArray = Array(allEvents)
        let newWrapper = ObserverWrapper(wrapped: observer, events: allEventsArray)
        observerWrappers[ObjectIdentifier(observer)] = newWrapper
        observable.subscribe(for: newWrapper, events: allEventsArray)
    }

    internal func unsubscribe(_ observer: Observer, events: [String]) {
        guard let wrapper = observerWrappers.removeValue(forKey: ObjectIdentifier(observer)) else {
            return
        }

        let wrapperEvents = Set(wrapper.events)

        guard events.isEmpty || !wrapperEvents.isDisjoint(with: events) else {
            return
        }

        observable.unsubscribe(for: wrapper)

        if !events.isEmpty {
            let remainingEvents = wrapperEvents.subtracting(events)
            if !remainingEvents.isEmpty {
                subscribe(observer, events: Array(remainingEvents))
            }
        }
    }

    @available(*, deprecated, renamed: "onNext(event:handler:)")
    internal func onNext(_ eventTypes: [MapEvents.EventKind], handler: @escaping (Event) -> Void) -> Cancelable {
        return onNext(eventTypes.map(\.rawValue), handler: handler)
    }

    internal func onNext<Payload>(event: MapEvents.Event<Payload>, handler: @escaping (MapEvent<Payload>) -> Void) -> Cancelable {
        return onNext([event.name]) { event in
            handler(MapEvent(event: event))
        }
    }

    private func onNext(_ events: [String], handler: @escaping (Event) -> Void) -> Cancelable {
        let cancelable = CompositeCancelable()
        let observer = BlockObserver {
            handler($0)
            cancelable.cancel()
        }
        subscribe(observer, events: events)
        // Capturing self and observer with weak refs in the closure passed to BlockCancelable
        // avoids a retain cycle. MapboxObservable holds a strong reference to observer, which has a
        // strong reference to cancelable, which has a strong reference to BlockCancelable, which only
        // has weak references back to MapboxObservable and observer. If MapboxObservable is deinited,
        // observer will be released.
        cancelable.add(BlockCancelable { [weak self, weak observer] in
            if let self = self, let observer = observer {
                self.unsubscribe(observer, events: [])
            }
        })
        return cancelable
    }

    @available(*, deprecated, renamed: "onEvery(event:handler:)")
    internal func onEvery(_ eventTypes: [MapEvents.EventKind], handler: @escaping (Event) -> Void) -> Cancelable {
        return onEvery(eventTypes.map(\.rawValue), handler: handler)
    }

    internal func onEvery<Payload>(event: MapEvents.Event<Payload>, handler: @escaping (MapEvent<Payload>) -> Void) -> Cancelable {
        onEvery([event.name]) { event in
            handler(MapEvent(event: event))
        }
    }

    private func onEvery(_ events: [String], handler: @escaping (Event) -> Void) -> Cancelable {
        let observer = BlockObserver(block: handler)
        subscribe(observer, events: events)
        return BlockCancelable { [weak self, weak observer] in
            if let self = self, let observer = observer {
                self.unsubscribe(observer, events: [])
            }
        }
    }

    internal func performWithoutNotifying(_ block: () -> Void) {
        for wrapper in observerWrappers.values {
            wrapper.ignoringCount += 1
        }
        block()
        for wrapper in observerWrappers.values {
            wrapper.ignoringCount -= 1
        }
    }

    private final class ObserverWrapper: Observer {
        internal let wrapped: Observer
        internal let events: [String]
        internal var ignoringCount = 0

        internal init(wrapped: Observer, events: [String]) {
            self.wrapped = wrapped
            self.events = events
        }

        internal func notify(for event: Event) {
            if ignoringCount == 0 {
                wrapped.notify(for: event)
            }
        }
    }

    private final class BlockObserver: Observer {
        private let block: (Event) -> Void

        internal init(block: @escaping (Event) -> Void) {
            self.block = block
        }

        internal func notify(for event: Event) {
            block(event)
        }
    }
}
