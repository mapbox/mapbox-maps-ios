import SwiftUI
@_spi(Experimental) @testable import MapboxMaps

@available(iOS 13.0, *)
struct MapContentFixture: MapContent {
    class Route {
        let json: String
        init(json: String) {
            self.json = json
        }
    }

    struct RouteLine: MapStyleContent {
        var route: Route
        var body: some MapStyleContent {
            GeoJSONSource(id: "route")
                .data(.string(route.json))
        }
    }

    var id: String
    var route: Route
    var optional: String?
    var condition: Bool

    var mapViewAnnotation = MapViewAnnotation(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0)) {
        Circle()
    }

    var body: some MapContent {
        CircleAnnotationGroup([1, 2], id: \.self) { i in
            CircleAnnotation(
                id: "\(i)",
                point: Point(LocationCoordinate2D(latitude: CGFloat(i * 10), longitude: CGFloat(i * 10)))
            )
        }
        .layerId("circle-test")

        mapViewAnnotation

        Puck3D(model: Model(), bearing: nil)

        SymbolLayer(id: id, source: "test")
        RouteLine(route: route)

        if let optional {
            SymbolLayer(id: optional, source: "test")
        }

        if condition {
            SymbolLayer(id: "condition-true", source: "test")
        } else {
            SymbolLayer(id: "condition-false", source: "test")
        }
    }
}
