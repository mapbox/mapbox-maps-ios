import Foundation
import MapboxMaps

struct SetOnlineStateCommand: AsyncCommand, Decodable {
    let connected: Bool

    func execute(context: Context) async throws {
        OfflineSwitch.shared.isMapboxStackConnected = connected
    }
}
