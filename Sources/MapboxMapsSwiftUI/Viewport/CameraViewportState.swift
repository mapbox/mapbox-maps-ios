@_spi(Package) import MapboxMaps

final class CameraViewportState: ViewportState {
    private let cameraOptions: CameraOptions

    init(cameraOptions: CameraOptions) {
        self.cameraOptions = cameraOptions
    }

    func observeDataSource(with handler: @escaping (CameraOptions) -> Bool) -> Cancelable {
        _ = handler(cameraOptions)
        return AnyCancelable {}
    }

    func startUpdatingCamera() {
    }

    func stopUpdatingCamera() {
    }
}
