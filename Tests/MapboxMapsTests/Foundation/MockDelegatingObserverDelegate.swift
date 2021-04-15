@testable import MapboxMaps

final class MockDelegatingObserverDelegate: DelegatingObserverDelegate {
    let notifyStub = Stub<Event, Void>()
    func notify(for event: Event) {
        notifyStub.call(with: event)
    }
}
