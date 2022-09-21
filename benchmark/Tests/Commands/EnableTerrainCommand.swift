import Foundation
import MapboxMaps

struct EnableTerrainCommand: AsyncCommand {
    private let terrain: Terrain

    @MainActor
    func execute() async throws {
        guard let mapView = UIViewController.rootController?.findMapView() else {
            throw ExecutionError.cannotFindMapboxMap
        }

        if let source = terrain.rasterDemSource {
            try mapView.mapboxMap.style.addSource(source, id: terrain.source)
        }

        try mapView.mapboxMap.style.setTerrain(terrain)
    }
}

extension EnableTerrainCommand: Decodable {

    init(from decoder: Decoder) throws {
        terrain = try Terrain(from: decoder)
    }
}

private extension Terrain {
    var rasterDemSource: RasterDemSource? {
        var source = RasterDemSource()
        source.maxzoom = 14

        switch self.source {
        case "mapbox-dem":
            source.url = "mapbox://mapbox.terrain-rgb"
            source.tileSize = 512
        case "mapbox-dem-padded":
            source.url = "mapbox://mapbox.mapbox-terrain-dem-v1"
            source.tileSize = 514
        default:
            return nil
        }

        return source
    }
}
