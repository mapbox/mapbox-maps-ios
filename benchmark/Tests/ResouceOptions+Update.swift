import Foundation
import MapboxMaps

extension ResourceOptions {

    func tileStoreUsageMode(_ mode: TileStoreUsageMode) -> Self {
        var updated = self
        updated.tileStoreUsageMode = mode
        return updated
    }
}
