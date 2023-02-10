@testable import MapboxMaps

final class MockObservableCameraOptions: ObservableCameraOptionsProtocol {
    let observeStub = Stub<(CameraOptions) -> Bool, Cancelable>(defaultReturnValue: MockCancelable())
    func observe(with handler: @escaping (CameraOptions) -> Bool) -> Cancelable {
        observeStub.call(with: handler)
    }

    let notifyStub = Stub<CameraOptions, Void>()
    func notify(with newValue: CameraOptions) {
        notifyStub.call(with: newValue)
    }
}
