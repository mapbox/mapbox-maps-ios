import Foundation
import MapboxMaps

struct EnableTerrainCommand: AsyncCommand {
    private let terrain: Terrain

    @MainActor
    func execute(context: Context) async throws {
        guard let mapView = context.mapView else {
            throw ExecutionError.cannotFindMapboxMap
        }

        if let source = terrain.rasterDemSource {
            try mapView.mapboxMap.style.addSource(source)
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
        var source = RasterDemSource(id: source)
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
