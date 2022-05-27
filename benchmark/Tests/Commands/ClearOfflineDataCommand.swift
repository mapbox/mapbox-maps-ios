import Foundation
import MapboxMaps
import XCTest

struct ClearOfflineDataCommand: AsyncCommand, Decodable {
    @MainActor
    func execute() async throws {
        let options = ResourceOptionsManager.default.resourceOptions
        let manager = OfflineManager(resourceOptions: options)

        let packs = try await manager.allStylePacks()

        for pack in packs {
            manager.removeStylePack(for: StyleURI(rawValue: pack.styleURI)!)
        }

        try await MapboxMap.clearData(for: options)

        let tileStore = TileStore.default
        tileStore.setOptionForKey(TileStoreOptions.diskQuota, value: 0)
        let regions = try await tileStore.allTileRegions()

        for region in regions {
            tileStore.removeTileRegion(forId: region.id)
        }

        tileStore.setOptionForKey(TileStoreOptions.diskQuota, value: NSNull())
    }
}

