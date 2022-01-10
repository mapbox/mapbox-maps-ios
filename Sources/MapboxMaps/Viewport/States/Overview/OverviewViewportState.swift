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

    private let mapboxMap: MapboxMapProtocol

    private let observableCameraOptions: ObservableCameraOptionsProtocol

    private var updatingCameraCancelable: Cancelable?

    internal init(options: OverviewViewportStateOptions,
                  mapboxMap: MapboxMapProtocol,
                  observableCameraOptions: ObservableCameraOptionsProtocol) {
        self.options = options
        self.mapboxMap = mapboxMap
        self.observableCameraOptions = observableCameraOptions
        recalculateCameraOptions()
    }

    private func recalculateCameraOptions() {
        observableCameraOptions.notify(with: mapboxMap.camera(
            for: options.geometry,
               padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10),
               bearing: 0,
               pitch: 0))
    }
}

extension OverviewViewportState: ViewportState {
    public func observeDataSource(with handler: @escaping (CameraOptions) -> Bool) -> Cancelable {
        return observableCameraOptions.observe(with: handler)
    }

    public func startUpdatingCamera() {
        guard updatingCameraCancelable == nil else {
            return
        }
        updatingCameraCancelable = observableCameraOptions.observe { [mapboxMap] cameraOptions in
            mapboxMap.setCamera(to: cameraOptions)
            return true
        }
    }

    public func stopUpdatingCamera() {
        updatingCameraCancelable?.cancel()
        updatingCameraCancelable = nil
    }
}
