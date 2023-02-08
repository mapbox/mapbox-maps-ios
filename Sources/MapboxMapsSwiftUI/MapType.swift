import MapboxMaps
import UIKit

struct MapViewType {
    var style: Style
    var mapboxMap: MapboxMapProtocol
    var realMapboxMap: MapboxMap? // nil for tests
    var gestures: GestureManager
    var locationForGesture: (UIGestureRecognizer) -> CGPoint
    var cameraState: () -> CameraState
}

extension MapViewType {
    init(from mapView: MapView) {
        self.style = mapView.mapboxMap.style
        self.mapboxMap = mapView.mapboxMap
        self.realMapboxMap = mapView.mapboxMap
        self.gestures = mapView.gestures
        self.locationForGesture = { $0.location(in: mapView) }
        self.cameraState = { mapView.cameraState }
    }
}
