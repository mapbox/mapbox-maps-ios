internal protocol FollowPuckViewportStateDataSourceProtocol: AnyObject {
    var options: FollowPuckViewportStateOptions { get set }
    func observe(with handler: @escaping (CameraOptions) -> Bool) -> Cancelable
}

internal final class FollowPuckViewportStateDataSource: FollowPuckViewportStateDataSourceProtocol {

    internal var options: FollowPuckViewportStateOptions // TODO: Trigger need repaint?

    // MARK: - Private State

    private let onPuckRender: Signal<PuckRenderingData>
    private let observableCameraOptions: ObservableCameraOptionsProtocol
    private var cancelables = Set<AnyCancelable>()

    // MARK: - Initialization

    internal init(options: FollowPuckViewportStateOptions,
                  onPuckRender: Signal<PuckRenderingData>,
                  observableCameraOptions: ObservableCameraOptionsProtocol) {
        self.options = options
        self.onPuckRender = onPuckRender
        self.observableCameraOptions = observableCameraOptions
        onPuckRender.observe { [weak self] data in
            self?.processUpdatedCamera(with: data)
        }.store(in: &cancelables)
    }

    // MARK: - Observation

    // delivers the latest camera synchronously, if available
    internal func observe(with handler: @escaping (CameraOptions) -> Bool) -> Cancelable {
        return observableCameraOptions.observe(with: handler)
    }

    // MARK: - Private Utilities

    private func processUpdatedCamera(with data: PuckRenderingData) {
        let cameraOptions = CameraOptions(
            center: data.location.coordinate,
            padding: options.padding,
            zoom: options.zoom,
            bearing: options.bearing?.evaluate(with: data),
            pitch: options.pitch)
        observableCameraOptions.notify(with: cameraOptions)
    }
}
