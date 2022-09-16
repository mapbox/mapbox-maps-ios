import Foundation
import MapboxMaps

struct EnableTerrainCommand: AsyncCommand {
    private let terrain: Terrain

    @MainActor
    func execute() async throws {
        guard let mapView = UIViewController.rootController?.findMapView() else {
            throw ExecutionError.cannotFindMapboxMap
        }

        try mapView.mapboxMap.style.setTerrain(terrain)
    }
}

extension EnableTerrainCommand: Decodable {

    init(from decoder: Decoder) throws {
        terrain = try Terrain(from: decoder)
    }
}
