@testable import MapboxMaps

final class MockFollowPuckViewportStateDataSource: FollowPuckViewportStateDataSourceProtocol {

    @Stubbed var options: FollowPuckViewportStateOptions = .random()

    let observeStub = Stub<(CameraOptions) -> Bool, Cancelable>(defaultReturnValue: MockCancelable())
    func observe(with handler: @escaping (CameraOptions) -> Bool) -> Cancelable {
        observeStub.call(with: handler)
    }
}
