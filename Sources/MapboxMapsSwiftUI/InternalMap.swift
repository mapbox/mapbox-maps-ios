import SwiftUI
import MapboxMaps

@available(iOS 13.0, *)
struct InternalMap: UIViewRepresentable {
    var camera: Binding<CameraState>?
    let mapDependencies: MapDependencies
    private var mapInitOptions: Map.InitOptionsProvider

    @Environment(\.colorScheme) var colorScheme
    var effectiveStyleURI: StyleURI {
        mapDependencies.styleURIs.effectiveURI(with: colorScheme)
    }

    init(
        camera: Binding<CameraState>?,
        mapConfiguration: MapDependencies,
        mapInitOptions: @escaping Map.InitOptionsProvider
    ) {
        self.camera = camera
        self.mapDependencies = mapConfiguration
        self.mapInitOptions = mapInitOptions
    }

    func makeCoordinator() -> MapCoordinator {
        MapCoordinator(camera: camera)
    }

    func makeUIView(context: Context) -> MapView {
        MapView(frame: .zero, mapInitOptions: mapInitOptions())
    }

    func updateUIView(_ mapView: MapView, context: Context) {
        context.environment.mapViewProvider?.mapView = mapView
        context.coordinator.mapView = mapView
        context.coordinator.update(from: self)
    }
}
