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

    // MARK: - Private State

    private var updatingCameraCancelable: Cancelable?

    private var cameraAnimationCancelable: Cancelable?

    // MARK: - Initialization

    internal init(dataSource: FollowPuckViewportStateDataSourceProtocol,
                  cameraAnimationsManager: CameraAnimationsManagerProtocol) {
        self.dataSource = dataSource
        self.cameraAnimationsManager = cameraAnimationsManager
    }

    // MARK: - Private Utilities

    private func animate(to cameraOptions: CameraOptions) {
        cameraAnimationCancelable?.cancel()
        cameraAnimationCancelable = cameraAnimationsManager.ease(
            to: cameraOptions,
            duration: max(0, options.animationDuration),
            curve: .linear,
            completion: nil)
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
        updatingCameraCancelable = dataSource.observe { [weak self] cameraOptions in
            self?.animate(to: cameraOptions)
            return true
        }
    }

    public func stopUpdatingCamera() {
        updatingCameraCancelable?.cancel()
        updatingCameraCancelable = nil
        cameraAnimationCancelable?.cancel()
        cameraAnimationCancelable = nil
    }
}
