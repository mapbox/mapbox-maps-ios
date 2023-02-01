import MapboxMaps

final class MockCancelable: Cancelable {
    let cancelStub = Stub<Void, Void>()
    func cancel() {
        cancelStub.call()
    }

    let deinitStub = Stub<Void, Void>()
    deinit {
        deinitStub.call()
    }
}
