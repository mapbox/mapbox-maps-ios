import MapboxCoreMaps

final class MockObserver: NSObject, Observer {
    let notifyStub = Stub<Event, Void>()
    func notify(for event: Event) {
        notifyStub.call(with: event)
    }
}
