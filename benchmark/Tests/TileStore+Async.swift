import Foundation
import MapboxCommon

extension TileStore {
    func allTileRegions() async throws -> [TileRegion] {
        return try await withCheckedThrowingContinuation { continuation in
            allTileRegions() { result in
                continuation.resume(with: result)
            }
        }
    }

    @discardableResult
    func loadTileRegion(forId id: String,
                        loadOptions: TileRegionLoadOptions,
                        progress: TileRegionLoadProgressCallback? = nil) async throws -> TileRegion {
        return try await withCheckedThrowingContinuation { continuation in
            loadTileRegion(forId: id, loadOptions: loadOptions, progress: progress) { tileRegion in
                continuation.resume(with: tileRegion)
            }
        }
    }

}
