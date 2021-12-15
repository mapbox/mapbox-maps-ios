public final class OverviewViewportState {

    public let geometry: Geometry

    private let mapboxMap: MapboxMapProtocol

    internal init(geometry: GeometryConvertible, mapboxMap: MapboxMapProtocol) {
        self.geometry = geometry.geometry
        self.mapboxMap = mapboxMap
    }

    private var cameraOptions: CameraOptions {
        return mapboxMap.camera(for: geometry, padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10), bearing: 0, pitch: 0)
    }
}

extension OverviewViewportState: ViewportState {
    public func didMove(to viewport: Viewport?) {
    }

    public func observeCamera(with handler: @escaping (CameraOptions) -> Bool) -> Cancelable {
        _ = handler(cameraOptions)
        return EmptyCancelable()
    }

    public func startUpdatingCamera() -> Cancelable {
        mapboxMap.setCamera(to: cameraOptions)
        return EmptyCancelable()
    }
}
