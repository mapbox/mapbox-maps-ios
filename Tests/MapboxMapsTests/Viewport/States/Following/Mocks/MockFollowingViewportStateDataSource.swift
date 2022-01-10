@testable import MapboxMaps

final class MockFollowingViewportStateDataSource: FollowingViewportStateDataSourceProtocol {

    @Stubbed var options: FollowingViewportStateOptions = .random()

    let observeStub = Stub<(CameraOptions) -> Bool, Cancelable>(defaultReturnValue: MockCancelable())
    func observe(with handler: @escaping (CameraOptions) -> Bool) -> Cancelable {
        observeStub.call(with: handler)
    }
}
