import MapboxMaps

final class MockCancelable: Cancelable {
    let cancelStub = Stub<Void, Void>()
    func cancel() {
        cancelStub.call()
    }
}
