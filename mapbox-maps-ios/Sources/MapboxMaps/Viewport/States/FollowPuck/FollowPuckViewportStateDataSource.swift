internal protocol FollowPuckViewportStateDataSourceProtocol: AnyObject {
    var options: FollowPuckViewportStateOptions { get set }
    func observe(with handler: @escaping (CameraOptions) -> Bool) -> Cancelable
}

internal final class FollowPuckViewportStateDataSource: FollowPuckViewportStateDataSourceProtocol {

    internal var options: FollowPuckViewportStateOptions {
        didSet {
            processUpdatedCamera()
        }
    }

    // MARK: - Private State

    private let interpolatedLocationProducer: InterpolatedLocationProducerProtocol
    private let observableCameraOptions: ObservableCameraOptionsProtocol
    private let cancelables = CancelableContainer()

    // MARK: - Initialization

    internal init(options: FollowPuckViewportStateOptions,
                  interpolatedLocationProducer: InterpolatedLocationProducerProtocol,
                  observableCameraOptions: ObservableCameraOptionsProtocol) {
        self.options = options
        self.interpolatedLocationProducer = interpolatedLocationProducer
        self.observableCameraOptions = observableCameraOptions
        interpolatedLocationProducer
            .observe { [weak self] _ in
                self?.processUpdatedCamera()
                return true
            }
            .add(to: cancelables)
    }

    // MARK: - Observation

    // delivers the latest camera synchronously, if available
    internal func observe(with handler: @escaping (CameraOptions) -> Bool) -> Cancelable {
        return observableCameraOptions.observe(with: handler)
    }

    // MARK: - Private Utilities

    private func cameraOptions(for location: InterpolatedLocation) -> CameraOptions {
        return CameraOptions(
            center: location.coordinate,
            padding: options.padding,
            zoom: options.zoom,
            bearing: options.bearing?.evaluate(with: location),
            pitch: options.pitch)
    }

    private func processUpdatedCamera() {
        if let cameraOptions = interpolatedLocationProducer.location.map(cameraOptions(for:)) {
            observableCameraOptions.notify(with: cameraOptions)
        }
    }
}
