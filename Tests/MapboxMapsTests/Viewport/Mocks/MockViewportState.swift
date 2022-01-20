@_spi(Experimental) import MapboxMaps

final class MockViewportState: ViewportState {

    let observeDataSourceStub = Stub<(CameraOptions) -> Bool, Cancelable>(defaultReturnValue: MockCancelable())
    func observeDataSource(with handler: @escaping (CameraOptions) -> Bool) -> Cancelable {
        observeDataSourceStub.call(with: handler)
    }

    let startUpdatingCameraStub = Stub<Void, Void>()
    func startUpdatingCamera() {
        startUpdatingCameraStub.call()
    }

    let stopUpdatingCameraStub = Stub<Void, Void>()
    func stopUpdatingCamera() {
        stopUpdatingCameraStub.call()
    }
}
