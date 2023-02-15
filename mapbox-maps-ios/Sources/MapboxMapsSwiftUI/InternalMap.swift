import SwiftUI
import MapboxMaps

@available(iOS 13.0, *)
struct InternalMap: UIViewRepresentable {
    var camera: Binding<CameraState>?
    var mapDependencies: MapDependencies
    private var mapInitOptions: Map.InitOptionsProvider?

    @Environment(\.colorScheme) var colorScheme

    init(
        camera: Binding<CameraState>?,
        mapDependencies: MapDependencies,
        mapInitOptions: Map.InitOptionsProvider?
    ) {
        self.camera = camera
        self.mapDependencies = mapDependencies
        self.mapInitOptions = mapInitOptions
    }

    func makeCoordinator() -> MapCoordinator {
        MapCoordinator(setCamera: camera.map(\.setter))
    }

    func makeUIView(context: Context) -> MapView {
        let mapView = MapView(frame: .zero, mapInitOptions: mapInitOptions?() ?? MapInitOptions())
        context.environment.mapViewProvider?.mapView = mapView
        context.coordinator.setMapView(MapViewFacade(from: mapView))
        return mapView
    }

    func updateUIView(_ mapView: MapView, context: Context) {
        context.coordinator.update(
            camera: camera?.wrappedValue,
            deps: mapDependencies,
            colorScheme: colorScheme)
    }
}

@available(iOS 13.0, *)
private extension Binding {
    var setter: (Value) -> Void {
        { self.wrappedValue = $0 }
    }
}
