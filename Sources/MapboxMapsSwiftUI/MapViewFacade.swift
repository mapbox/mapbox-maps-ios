import MapboxMaps
import UIKit

/// Abstraction on MapView which makes testing possible.
struct MapViewFacade {
    var style: StyleProtocol
    var mapboxMap: MapboxMapProtocol
    var gestures: GestureManagerProtocol
    var realMapboxMap: MapboxMap? // nil for tests
    var locationForGesture: (UIGestureRecognizer) -> CGPoint
    var cameraState: () -> CameraState
}

extension MapViewFacade {
    init(from mapView: MapView) {
        style = mapView.mapboxMap.style
        mapboxMap = mapView.mapboxMap
        gestures = mapView.gestures
        realMapboxMap = mapView.mapboxMap
        locationForGesture = { $0.location(in: mapView) }
        cameraState = { mapView.cameraState }
    }
}
