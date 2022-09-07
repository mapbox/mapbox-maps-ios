@testable import MapboxMaps

final class MockMainQueue: DispatchQueueProtocol {
    let asyncStub = Stub<() -> Void, Void>()
    func async(execute work: @escaping () -> Void) {
        asyncStub.call(with: work)
    }
}
