import Foundation
import MapboxMaps
import Turf

public struct CreateOfflinePacksCommand: AsyncCommand {
    let minZoom: Double
    let maxZoom: Double
    let style: StyleURI
    let geometry: Polygon

    func execute() async throws {
        let options = ResourceOptionsManager.default.resourceOptions
        let manager = OfflineManager(resourceOptions: options)

        let loadOptions = StylePackLoadOptions(glyphsRasterizationMode: nil)!
        try await manager.loadStylePack(for: style, loadOptions: loadOptions)

        let descriptor = manager.createTilesetDescriptor(
            for: TilesetDescriptorOptions(
                styleURI: style.rawValue,
                minZoom: UInt8(minZoom),
                maxZoom: UInt8(maxZoom),
                stylePack: nil
            )
        )

        let polygonId = "\(geometry.coordinates[0][0].longitude):\(geometry.coordinates[0][0].latitude)"

        let regionLoadOptions = TileRegionLoadOptions(geometry: geometry.geometry, descriptors: [descriptor])!
        try await TileStore.default.loadTileRegion(forId: "\(style)-\(minZoom)-\(maxZoom)-\(polygonId)",
                                         loadOptions: regionLoadOptions)
    }
}

extension CreateOfflinePacksCommand: Decodable {
    enum CodingKeys: CodingKey {
        case minZoom
        case maxZoom
        case style
        case geometry
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        minZoom = try container.decode(Double.self, forKey: .minZoom)
        maxZoom = try container.decode(Double.self, forKey: .maxZoom)
        style = try container.decode(StyleURI.self, forKey: .style)
        let coordinates = try container.decode([CLLocationCoordinate2D].self, forKey: .geometry)
        geometry = Polygon([coordinates])
    }
}
