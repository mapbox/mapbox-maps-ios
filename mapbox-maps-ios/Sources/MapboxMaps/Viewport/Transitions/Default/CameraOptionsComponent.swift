internal protocol CameraOptionsComponentProtocol {
    var cameraOptions: CameraOptions { get }
    func updated(with cameraOptions: CameraOptions) -> CameraOptionsComponentProtocol?
}

internal struct CameraOptionsComponent<T>: CameraOptionsComponentProtocol {
    internal let keyPath: WritableKeyPath<CameraOptions, T?>
    internal let value: T

    internal var cameraOptions: CameraOptions {
        var cameraOptions = CameraOptions()
        cameraOptions[keyPath: keyPath] = value
        return cameraOptions
    }

    internal func updated(with cameraOptions: CameraOptions) -> CameraOptionsComponentProtocol? {
        cameraOptions[keyPath: keyPath].map {
            CameraOptionsComponent(keyPath: keyPath, value: $0)
        }
    }
}
