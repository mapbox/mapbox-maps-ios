import Foundation

public protocol MapEventsObservable: AnyObject {
    /// Listen to multiple occurrences of a Map event.
    ///
    /// - Parameters:
    ///   - eventType: The event type to listen to.
    ///   - handler: The closure to execute when the event occurs.
    ///
    /// - Returns: A `Cancelable` object that you can use to stop listening for
    ///     events. This is especially important if you have a retain cycle in
    ///     the handler.
    @discardableResult
    func onEvery(_ eventType: MapEvents.EventKind, handler: @escaping (Event) -> Void) -> Cancelable

    /// Listen to a single occurrence of a Map event.
    ///
    /// This will observe the next (and only the next) event of the specified
    /// type. After observation, the underlying subscriber will unsubscribe from
    /// the map or snapshotter.
    ///
    /// If you need to unsubscribe before the event fires, call `cancel()` on
    /// the returned `Cancelable` object.
    ///
    /// - Parameters:
    ///   - eventType: The event type to listen to.
    ///   - handler: The closure to execute when the event occurs.
    ///
    /// - Returns: A `Cancelable` object that you can use to stop listening for
    ///     the event. This is especially important if you have a retain cycle in
    ///     the handler.
    @discardableResult
    func onNext(_ eventType: MapEvents.EventKind, handler: @escaping (Event) -> Void) -> Cancelable
}

internal final class MapEventHandler: NSObject, Observer, Cancelable {
    // Events to match
    private let events: [String]

    // Convenience closure used to capture the passed handler *and* self
    private var observation: ((Event) -> Void)?

    // Observable, e.g. the `Map`
    private weak var observable: ObservableProtocol?

    // self is captured for the duration of observation.
    // handler should return `true` when it's handled all the events it wants
    // Could mark this with @discardableResult
    internal init(for events: [String], observable: ObservableProtocol, handler: @escaping (Event) -> Bool) {
        self.events = events

        super.init()

        // Retain self in the closure, until it's been called and then
        // nilled out.
        self.observation = { event in
            if handler(event) {
                self.cancel()
            }
        }

        self.observable = observable

        observable.subscribe(self, events: events)
    }

    // Can be called to cancel observation if needed.
    public func cancel() {
        observable?.unsubscribe(self, events: events)

        // Important to nil observation to break any retain cycles
        observation = nil
    }

    internal func notify(for event: Event) {
        guard events.contains(event.type) else {
            return
        }

        observation?(event)
    }
}
