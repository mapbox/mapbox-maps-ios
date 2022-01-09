public final class FollowingViewportState {

    // MARK: - Public Config

    public var options: FollowingViewportStateOptions {
        didSet {
            processUpdatedCamera()
        }
    }

    // MARK: - Injected Dependencies

    private let cameraAnimationsManager: CameraAnimationsManagerProtocol

    // MARK: - Private Dependencies

    // avoids needing to expose a NSObject subclass in the public API.
    // this can be improved in the next major version by eliminating
    // the requirement that `LocationConsumer`s inherit from NSObject.
    private let delegatingLocationConsumer: DelegatingLocationConsumer

    // MARK: - Private State

    private var latestLocation: Location? {
        didSet {
            processUpdatedCamera()
        }
    }

    private var observers = [CameraObserver]()

    private var isUpdatingCamera = false

    private var cameraAnimationCancelable: Cancelable?

    // MARK: - Initialization

    internal init(options: FollowingViewportStateOptions,
                  locationProducer: LocationProducerProtocol,
                  cameraAnimationsManager: CameraAnimationsManagerProtocol) {
        self.options = options
        self.cameraAnimationsManager = cameraAnimationsManager
        self.delegatingLocationConsumer = DelegatingLocationConsumer(locationProducer: locationProducer)
        self.delegatingLocationConsumer.delegate = self
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

    private func animate(to cameraOptions: CameraOptions) {
        cameraAnimationCancelable?.cancel()
        cameraAnimationCancelable = cameraAnimationsManager.ease(
            to: cameraOptions,
            duration: max(0, options.animationDuration),
            curve: .linear,
            completion: nil)
    }

    private func processUpdatedCamera() {
        if let cameraOptions = latestLocation.map(cameraOptions(for:)) {
            if isUpdatingCamera {
                animate(to: cameraOptions)
            }
            observers.forEach { (observer) in
                observer.invokeHandler(with: cameraOptions)
            }
        }
    }
}

extension FollowingViewportState: ViewportState {
    // delivers the latest location synchronously, if available
    public func observeDataSource(with handler: @escaping (CameraOptions) -> Bool) -> Cancelable {
        let observer = CameraObserver { [weak self] (observer, cameraOptions) in
            // handler returns false if it wants to stop receiving updates
            if !handler(cameraOptions) {
                self?.observers.removeAll { $0 === observer }
            }
        }
        observers.append(observer)
        if let latestLocation = latestLocation {
            observer.invokeHandler(with: cameraOptions(for: latestLocation))
        }
        return BlockCancelable { [weak self] in
            self?.observers.removeAll { $0 === observer }
        }
    }

    public func startUpdatingCamera() {
        guard !isUpdatingCamera else {
            return
        }
        isUpdatingCamera = true
        if let latestCameraOptions = latestLocation.map(cameraOptions(for:)) {
            animate(to: latestCameraOptions)
        }
    }

    public func stopUpdatingCamera() {
        cameraAnimationCancelable?.cancel()
        cameraAnimationCancelable = nil
        isUpdatingCamera = false
    }
}

extension FollowingViewportState: DelegatingLocationConsumerDelegate {
    internal func delegatingLocationConsumer(_ consumer: DelegatingLocationConsumer, didReceiveLocation location: Location) {
        latestLocation = location
    }
}

internal final class CameraObserver {
    private let handler: (CameraObserver, CameraOptions) -> Void

    internal init(handler: @escaping (CameraObserver, CameraOptions) -> Void) {
        self.handler = handler
    }

    internal func invokeHandler(with cameraOptions: CameraOptions) {
        handler(self, cameraOptions)
    }
}
