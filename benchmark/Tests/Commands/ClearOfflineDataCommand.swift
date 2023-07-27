import Foundation
import MapboxMaps
import XCTest

struct ClearOfflineDataCommand: AsyncCommand, Decodable {
    @MainActor
    func execute(context: Context) async throws {
        let offlineManager = OfflineManager()
        let packs = try await offlineManager.allStylePacks()

        try await MapboxMap.clearData()

        try await withThrowingTaskGroup(of: Void.self) { group in
            for pack in packs {
                group.addTask {
                    try await offlineManager.remove(stylePack: pack)
                }
            }

            try await group.waitForAll()
        }

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
