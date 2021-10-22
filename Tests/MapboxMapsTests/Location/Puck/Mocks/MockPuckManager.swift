@testable import MapboxMaps

final class MockPuckManager: PuckManagerProtocol {
    var puckType: PuckType?

    var puckAccuracy: PuckAccuracy = .full

    var puckBearingSource: PuckBearingSource = .heading
}
