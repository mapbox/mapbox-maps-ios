internal protocol FollowPuckViewportStateDataSourceProtocol: AnyObject {
    var options: FollowPuckViewportStateOptions { get set }
    func observe(with handler: @escaping (CameraOptions) -> Bool) -> Cancelable
}

internal final class FollowPuckViewportStateDataSource: NSObject, FollowPuckViewportStateDataSourceProtocol {

    internal var options: FollowPuckViewportStateOptions {
        didSet {
            processUpdatedCamera()
        }
    }

    // MARK: - Private State

    private var latestLocation: Location? {
        didSet {
            processUpdatedCamera()
        }
    }

    private let observableCameraOptions: ObservableCameraOptionsProtocol

    // MARK: - Initialization

    internal init(options: FollowPuckViewportStateOptions,
                  locationProducer: LocationProducerProtocol,
                  observableCameraOptions: ObservableCameraOptionsProtocol) {
        self.options = options
        self.observableCameraOptions = observableCameraOptions
        super.init()
        locationProducer.add(self)
    }

    // MARK: - Observation

    // delivers the latest camera synchronously, if available
    internal func observe(with handler: @escaping (CameraOptions) -> Bool) -> Cancelable {
        return observableCameraOptions.observe(with: handler)
    }

    // MARK: - Private Utilities

    private func cameraOptions(for location: Location) -> CameraOptions {
        return CameraOptions(
            center: location.location.coordinate,
            padding: options.padding,
            zoom: options.zoom,
            bearing: options.bearing.evaluate(with: location),
            pitch: options.pitch)
    }

    private func processUpdatedCamera() {
        if let cameraOptions = latestLocation.map(cameraOptions(for:)) {
            observableCameraOptions.notify(with: cameraOptions)
        }
    }
}

extension FollowPuckViewportStateDataSource: LocationConsumer {
    internal func locationUpdate(newLocation: Location) {
        latestLocation = newLocation
    }
}
