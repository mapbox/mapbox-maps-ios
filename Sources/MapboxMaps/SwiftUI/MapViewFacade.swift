import SwiftUI
import UIKit

/// Abstraction around MapView which makes unit testing possible.
@available(iOS 13.0, *)
struct MapViewFacade {
    var styleManager: StyleProtocol
    var mapboxMap: MapboxMapProtocol
    var gestureManager: GestureManagerProtocol
    var viewportManager: ViewportManagerProtocol
    var ornaments: OrnamentsManaging

    var makeViewportTransition: (ViewportAnimation) -> ViewportTransition
    var makeViewportState: (Viewport, LayoutDirection) -> ViewportState?
}

@available(iOS 13.0, *)
extension MapViewFacade {
    init(from mapView: MapView) {
        styleManager = mapView.mapboxMap
        mapboxMap = mapView.mapboxMap
        gestureManager = mapView.gestures
        viewportManager = mapView.viewport
        ornaments = mapView.ornaments

        makeViewportTransition = { animation in
            animation.makeViewportTransition(mapView)
        }
        makeViewportState = { viewport, LayoutDirection in
            viewport.makeState(with: mapView, layoutDirection: LayoutDirection)
        }
    }
}
