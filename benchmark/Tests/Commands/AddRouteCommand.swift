import UIKit
import MapboxMaps

struct AddRouteCommand: AsyncCommand {
    private enum ID {
        static let routeSource = "route-line-source-id"
        static let routeLineLayer = "route-line-layer-id"
        static let casingLineLayer = "route-casing-layer-id"
    }

    private let fileURL: URL
    private var locationProvider = OnDemandLocationProvider()

    @MainActor
    func execute(context: Context) async throws {
        guard let mapView = context.mapView else {
            throw ExecutionError.cannotFindMapboxMap
        }

        mapView.location.options.puckType = .puck2D(.makeDefault(showBearing: false))
        mapView.location.options.puckBearing = .course
        mapView.location.provider = locationProvider

        // Setup route.
        let route = try getRoute()

        var source = GeoJSONSource(id: ID.routeSource)
        source.data = .geometry(Geometry(route.line))
        source.lineMetrics = true
        try mapView.mapboxMap.addSource(source)
        try mapView.mapboxMap.addPersistentLayer(makeCasingLayer())
        try mapView.mapboxMap.addPersistentLayer(makeLineLayer())

        mapView.mapboxMap.onCameraChanged.observe { [weak locationProvider] payload in
            let newLocation = payload.cameraState.center
            let traveledDistance = route.line.distance(to: newLocation) ?? 0
            let progess = traveledDistance / route.distance

            locationProvider?.currentCoordination = newLocation
            try? mapView.mapboxMap.setLayerProperty(
                for: ID.routeLineLayer,
                property: "line-trim-offset",
                value: [0, progess])
            try? mapView.mapboxMap.setLayerProperty(
                for: ID.casingLineLayer,
                property: "line-trim-offset",
                value: [0, progess])
        }.store(in: &context.cancellables)
    }

    private func makeLineLayer() -> LineLayer {
        var lineLayer = LineLayer(id: ID.routeLineLayer, source: ID.routeSource)
        lineLayer.lineCap = .constant(.round)
        lineLayer.lineJoin = .constant(.round)
        lineLayer.lineWidth = .constant(10)
        lineLayer.lineGradient = .expression(
            Exp(.interpolate) {
                Exp(.linear)
                Exp(.lineProgress)
                0.0
                UIColor(red: 6.0/255.0, green: 1.0/255.0, blue: 255.0/255.0, alpha: 1)
                0.1
                UIColor(red: 59.0/255.0, green: 118.0/255.0, blue: 227.0/255.0, alpha: 1)
                0.3
                UIColor(red: 7.0/255.0, green: 238.0/255.0, blue: 251.0/255.0, alpha: 1)
                0.5
                UIColor(red: 0, green: 255.0/255.0, blue: 42.0/255.0, alpha: 1)
                0.7
                UIColor(red: 255.0/255.0, green: 252.0/255.0, blue: 0, alpha: 1)
                1.0
                UIColor(red: 255.0/255.0, green: 30.0/255.0, blue: 0, alpha: 1)
            }
        )

        return lineLayer
    }

    private func makeCasingLayer() -> LineLayer {
        var casingLayer = LineLayer(id: ID.casingLineLayer, source: ID.routeSource)
        casingLayer.lineCap = .constant(.round)
        casingLayer.lineJoin = .constant(.round)
        casingLayer.lineWidth = .expression(
            Exp(.interpolate) {
                Exp(.exponential) { 1.5 }
                Exp(.zoom)
                10.0
                Exp(.product) {
                    7.0
                    1.0
                }
                14.0
                Exp(.product) {
                    10.5
                    1.0
                }
                16.5
                Exp(.product) {
                    15.5
                    1.0
                }
                19.0
                Exp(.product) {
                    24.0
                    1.0
                }
                22.0
                Exp(.product) {
                    29.0
                    1.0
                }
            }
        )
        casingLayer.lineGradient = .expression(
            Exp(.interpolate) {
                Exp(.linear)
                Exp(.lineProgress)
                0.0
                UIColor(red: 47.0/255.0, green: 122.0/255.0, blue: 198.0/255.0, alpha: 1)
                1.0
                UIColor(red: 47.0/255.0, green: 122.0/255.0, blue: 198.0/255.0, alpha: 1)
            }
        )

        return casingLayer
    }
}

// MARK: Decodable

extension AddRouteCommand: Decodable {

    init(from decoder: Decoder) throws {
        enum Keys: String, CodingKey {
            case fileName
        }

        let container = try decoder.container(keyedBy: Keys.self)
        fileURL = Bundle.main.bundleURL.appendingPathComponent(try container.decode(String.self, forKey: .fileName))
    }
}

// MARK: Route Data

extension AddRouteCommand {

    private struct Route: Decodable {
        let line: LineString
        let distance: LocationDistance

        enum CodingKeys: String, CodingKey {
            case line = "geometry"
            case distance
        }
    }

    private func getRoute() throws -> Route {
        struct Routes: Decodable {
            let routes: [Route]
        }

        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode(Routes.self, from: data).routes[0]
    }
}
