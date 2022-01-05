import MapboxMaps

final class MockViewportState: ViewportState {

    let observeDataSourceStub = Stub<(CameraOptions) -> Bool, Cancelable>(defaultReturnValue: MockCancelable())
    func observeDataSource(with handler: @escaping (CameraOptions) -> Bool) -> Cancelable {
        observeDataSourceStub.call(with: handler)
    }

    let startUpdatingCameraStub = Stub<Void, Cancelable>(defaultReturnValue: MockCancelable())
    func startUpdatingCamera() -> Cancelable {
        startUpdatingCameraStub.call()
    }
}
