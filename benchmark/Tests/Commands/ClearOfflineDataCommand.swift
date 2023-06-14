import Foundation
import MapboxMaps
import XCTest

struct ClearOfflineDataCommand: AsyncCommand, Decodable {
    @MainActor
    func execute(context: Context) async throws {
        let manager = OfflineManager()

        let packs = try await manager.allStylePacks()

        for pack in packs {
            manager.removeStylePack(for: StyleURI(rawValue: pack.styleURI)!)
        }

        try await MapboxMap.clearData()

        let tileStore = TileStore.default
        tileStore.setOptionForKey(TileStoreOptions.diskQuota, value: 0)
        tileStore.setOptionForKey(TileStoreOptions.diskQuotaCooldownDuration, value: 0)
        let regions = try await tileStore.allTileRegions()

        for region in regions {
            tileStore.removeTileRegion(forId: region.id)
        }

        tileStore.setOptionForKey(TileStoreOptions.diskQuota, value: NSNull())
    }
}

extension TileStoreOptions {
    fileprivate static let diskQuotaCooldownDuration = "disk-quota-enforcement-cooldown-duration"
}
