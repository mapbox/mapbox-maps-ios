import MapboxCoreMaps

internal protocol DelegatingObserverDelegate: AnyObject {
    func notify(for event: MapboxCoreMaps.Event)
}

internal final class DelegatingObserver: Observer {
    internal weak var delegate: DelegatingObserverDelegate?

    internal func notify(for event: MapboxCoreMaps.Event) {
        delegate?.notify(for: event)
    }
}
