import SwiftUI
import MapboxMaps

@available(iOS 13.0, *)
struct InternalMap: UIViewRepresentable {
    var camera: Binding<CameraState>?
    var mapDependencies: MapDependencies
    var annotationsOptions: [AnyHashable: ViewAnnotationOptions]
    var mapInitOptions: Map.InitOptionsProvider?
    var locationDependencies: LocationDependencies
    var onAnnotationLayoutUpdate: (AnnotationLayouts) -> Void

    @Environment(\.colorScheme) var colorScheme

    func makeCoordinator() -> Coordinator {
        Coordinator(
            basic: MapBasicCoordinator(setCamera: camera.map(\.setter)),
            viewAnnotation: ViewAnnotationCoordinator(),
            location: LocationCoordinator())
    }

    func makeUIView(context: Context) -> MapView {
        let mapView = MapView(frame: .zero, mapInitOptions: mapInitOptions?() ?? MapInitOptions())
        context.environment.mapViewProvider?.mapView = mapView
        context.coordinator.basic.setMapView(MapViewFacade(from: mapView))
        context.coordinator.viewAnnotation.setup(with: .init(map: mapView.mapboxMap, onLayoutUpdate: onAnnotationLayoutUpdate))
        context.coordinator.location.setup(with: mapView.location)
        return mapView
    }

    func updateUIView(_ mapView: MapView, context: Context) {
        context.coordinator.basic.update(
            camera: camera?.wrappedValue,
            deps: mapDependencies,
            colorScheme: colorScheme)
        context.coordinator.viewAnnotation.annotations = annotationsOptions
        context.coordinator.location.update(deps: locationDependencies)
    }
}

@available(iOS 13.0, *)
extension InternalMap {
    final class Coordinator {
        let basic: MapBasicCoordinator
        let viewAnnotation: ViewAnnotationCoordinator
        let location: LocationCoordinator

        init(basic: MapBasicCoordinator, viewAnnotation: ViewAnnotationCoordinator, location: LocationCoordinator) {
            self.basic = basic
            self.viewAnnotation = viewAnnotation
            self.location = location
        }
    }
}

@available(iOS 13.0, *)
private extension Binding {
    var setter: (Value) -> Void {
        { self.wrappedValue = $0 }
    }
}
