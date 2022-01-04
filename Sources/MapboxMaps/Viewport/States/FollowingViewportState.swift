public final class FollowingViewportState {

    // MARK: - Public Config

    public let zoom: CGFloat
    public let pitch: CGFloat

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

    private var observers = [CameraObserver]()

    private var isUpdatingCamera = false

    private var cameraAnimationCancelable: Cancelable?

    // MARK: - Initialization

    internal init(zoom: CGFloat,
                  pitch: CGFloat,
                  locationProducer: LocationProducerProtocol,
                  cameraAnimationsManager: CameraAnimationsManagerProtocol) {
        self.zoom = zoom
        self.pitch = pitch
        self.cameraAnimationsManager = cameraAnimationsManager
        self.delegatingLocationConsumer = DelegatingLocationConsumer(locationProducer: locationProducer)
        self.delegatingLocationConsumer.delegate = self
    }

    // MARK: - Private Utilities

    private func cameraOptions(for location: Location) -> CameraOptions {
        return CameraOptions(
            center: location.location.coordinate,
            zoom: zoom,
            bearing: location.location.course,
            pitch: pitch)
    }

    private func animate(to cameraOptions: CameraOptions) {
        cameraAnimationCancelable?.cancel()
        cameraAnimationCancelable = cameraAnimationsManager.ease(
            to: cameraOptions,
            duration: 1,
            curve: .linear,
            completion: nil)
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

    // viewport should only call this method when the state is not already updating the camera
    public func startUpdatingCamera() -> Cancelable {
        assert(!isUpdatingCamera)
        isUpdatingCamera = true
        if let latestCameraOptions = latestLocation.map(cameraOptions(for:)) {
            animate(to: latestCameraOptions)
        }
        return BlockCancelable { [weak self] in
            self?.cameraAnimationCancelable?.cancel()
            self?.cameraAnimationCancelable = nil
            self?.isUpdatingCamera = false
        }
    }
}

extension FollowingViewportState: DelegatingLocationConsumerDelegate {
    internal func delegatingLocationConsumer(_ consumer: DelegatingLocationConsumer, didReceiveLocation location: Location) {
        latestLocation = location
    }
}

private final class CameraObserver {
    private let handler: (CameraObserver, CameraOptions) -> Void

    internal init(handler: @escaping (CameraObserver, CameraOptions) -> Void) {
        self.handler = handler
    }

    func invokeHandler(with cameraOptions: CameraOptions) {
        handler(self, cameraOptions)
    }
}
