@_spi(Experimental) public final class FollowPuckViewportState {

    // MARK: - Public Config

    public var options: FollowPuckViewportStateOptions {
        get {
            dataSource.options
        }
        set {
            dataSource.options = newValue
        }
    }

    // MARK: - Injected Dependencies

    private let dataSource: FollowPuckViewportStateDataSourceProtocol

    private let cameraAnimationsManager: CameraAnimationsManagerProtocol

    private let mapboxMap: MapboxMapProtocol

    // MARK: - Private State

    private var updatingCameraCancelable: Cancelable?

    // MARK: - Initialization

    internal init(dataSource: FollowPuckViewportStateDataSourceProtocol,
                  cameraAnimationsManager: CameraAnimationsManagerProtocol,
                  mapboxMap: MapboxMapProtocol) {
        self.dataSource = dataSource
        self.cameraAnimationsManager = cameraAnimationsManager
        self.mapboxMap = mapboxMap
    }
}

extension FollowPuckViewportState: ViewportState {
    // delivers the latest location synchronously, if available
    public func observeDataSource(with handler: @escaping (CameraOptions) -> Bool) -> Cancelable {
        return dataSource.observe(with: handler)
    }

    public func startUpdatingCamera() {
        guard updatingCameraCancelable == nil else {
            return
        }
        updatingCameraCancelable = dataSource.observe { [mapboxMap] cameraOptions in
            mapboxMap.setCamera(to: cameraOptions)
            return true
        }
    }

    public func stopUpdatingCamera() {
        updatingCameraCancelable?.cancel()
        updatingCameraCancelable = nil
    }
}
