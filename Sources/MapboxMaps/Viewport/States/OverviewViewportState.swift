import Turf
public struct OverviewViewportStateOptions: Equatable {
    public var geometry: Geometry

    public init(geometry: GeometryConvertible) {
        self.geometry = geometry.geometry
    }
}

public final class OverviewViewportState {

    public var options: OverviewViewportStateOptions {
        didSet {
            recalculateCameraOptions()
        }
    }

    private var cameraOptions: CameraOptions = .init() {
        didSet {
            guard cameraOptions != oldValue else {
                return
            }
            if isUpdatingCamera {
                mapboxMap.setCamera(to: cameraOptions)
            }
            observers.forEach { (observer) in
                observer.invokeHandler(with: cameraOptions)
            }
        }
    }

    private let mapboxMap: MapboxMapProtocol

    private var observers = [CameraObserver]()

    private var isUpdatingCamera = false

    internal init(options: OverviewViewportStateOptions, mapboxMap: MapboxMapProtocol) {
        self.options = options
        self.mapboxMap = mapboxMap
        recalculateCameraOptions()
    }

    private func recalculateCameraOptions() {
        cameraOptions = mapboxMap.camera(
            for: options.geometry,
            padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10),
            bearing: 0,
            pitch: 0)
    }
}

extension OverviewViewportState: ViewportState {
    public func observeDataSource(with handler: @escaping (CameraOptions) -> Bool) -> Cancelable {
        let observer = CameraObserver { [weak self] (observer, cameraOptions) in
            // handler returns false if it wants to stop receiving updates
            if !handler(cameraOptions) {
                self?.observers.removeAll { $0 === observer }
            }
        }
        observers.append(observer)
        observer.invokeHandler(with: cameraOptions)
        return BlockCancelable { [weak self] in
            self?.observers.removeAll { $0 === observer }
        }
    }

    public func startUpdatingCamera() {
        guard !isUpdatingCamera else {
            return
        }
        isUpdatingCamera = true
        mapboxMap.setCamera(to: cameraOptions)
    }

    public func stopUpdatingCamera() {
        isUpdatingCamera = false
    }
}
