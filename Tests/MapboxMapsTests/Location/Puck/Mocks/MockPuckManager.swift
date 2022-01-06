@testable import MapboxMaps

final class MockPuckManager: PuckManagerProtocol {
    var puckType: PuckType?

    var puckBearingSource: PuckBearingSource = .heading
}
