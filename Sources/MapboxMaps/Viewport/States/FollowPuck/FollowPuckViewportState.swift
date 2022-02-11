/// A ``ViewportState`` implementation that tracks the location puck (to show a puck, use
/// ``LocationOptions/puckType``)
///
/// Use ``Viewport/makeFollowPuckViewportState(options:)`` to create instances of this
/// class.
@_spi(Experimental) public final class FollowPuckViewportState {

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
        var animationStarted = false
        var animationComplete = false

        let compositeCancelable = CompositeCancelable()

        updatingCameraCancelable = compositeCancelable

        compositeCancelable.add(dataSource.observe { [mapboxMap, cameraAnimationsManager, options] cameraOptions in
            if animationComplete {
                mapboxMap.setCamera(to: cameraOptions)
            } else if !animationStarted {
                animationStarted = true
                compositeCancelable.add(cameraAnimationsManager.internalEase(
                    to: cameraOptions,
                    duration: options.animationDuration,
                    curve: .linear) { _ in
                        animationComplete = true
                    })
            }
            return true
        })
    }

    /// :nodoc:
    /// See ``ViewportState/stopUpdatingCamera()``.
    public func stopUpdatingCamera() {
        updatingCameraCancelable?.cancel()
        updatingCameraCancelable = nil
    }
}
