import Foundation
import MapboxMaps

struct SetOnlineStateCommand: AsyncCommand, Decodable {
    let connected: Bool

    func execute() async throws {
        OfflineSwitch.shared.isMapboxStackConnected = connected
    }
}
