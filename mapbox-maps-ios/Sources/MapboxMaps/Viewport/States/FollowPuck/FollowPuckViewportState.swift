/// A ``ViewportState`` implementation that tracks the location puck (to show a puck, use
/// ``LocationOptions/puckType``)
///
/// Use ``Viewport/makeFollowPuckViewportState(options:)`` to create instances of this
/// class.
public final class FollowPuckViewportState {

    /// Configuration options for this state.
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

    private let mapboxMap: MapboxMapProtocol

    // MARK: - Private State

    private var updatingCameraCancelable: Cancelable?

    // MARK: - Initialization

    internal init(dataSource: FollowPuckViewportStateDataSourceProtocol,
                  mapboxMap: MapboxMapProtocol) {
        self.dataSource = dataSource
        self.mapboxMap = mapboxMap
    }
}

extension FollowPuckViewportState: ViewportState {
    /// :nodoc:
    /// See ``ViewportState/observeDataSource(with:)``.
    public func observeDataSource(with handler: @escaping (CameraOptions) -> Bool) -> Cancelable {
        return dataSource.observe(with: handler)
    }

    /// :nodoc:
    /// See ``ViewportState/startUpdatingCamera()``.
    public func startUpdatingCamera() {
        guard updatingCameraCancelable == nil else {
            return
        }

        updatingCameraCancelable = dataSource.observe { [mapboxMap] cameraOptions in
            mapboxMap.setCamera(to: cameraOptions)
            return true
        }
    }

    /// :nodoc:
    /// See ``ViewportState/stopUpdatingCamera()``.
    public func stopUpdatingCamera() {
        updatingCameraCancelable?.cancel()
        updatingCameraCancelable = nil
    }
}
