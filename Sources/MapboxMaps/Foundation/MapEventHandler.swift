import Foundation

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
