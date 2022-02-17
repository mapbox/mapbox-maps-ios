import MapboxCoreMaps

/// `ObservableProtocol` includes methods from MapboxCoreMaps's `MBMObservable` (aka `Observable`)
/// so that ``MapboxObservable`` can depend on this protocol instead of on `MBMObservable` directly.
/// This enables us to inject mocks when unit testing.
internal protocol ObservableProtocol: AnyObject {
    func subscribe(for observer: Observer, events: [String])
    func unsubscribe(for observer: Observer)
}

extension Observable: ObservableProtocol {}
