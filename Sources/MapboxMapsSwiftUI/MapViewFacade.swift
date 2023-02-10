import MapboxMaps
import UIKit

/// Abstraction on MapView which makes testing possible.
struct MapViewFacade {
    var style: StyleProtocol
    var mapboxMap: MapboxMapProtocol
    var gestures: GestureManagerProtocol
    var locationForGesture: (UIGestureRecognizer) -> CGPoint
}

extension MapViewFacade {
    init(from mapView: MapView) {
        style = mapView.mapboxMap.style
        mapboxMap = mapView.mapboxMap
        gestures = mapView.gestures
        locationForGesture = { $0.location(in: mapView) }
    }
}
