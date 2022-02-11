@testable import MapboxMaps

final class MockPuck: Puck {
    @Stubbed var isActive: Bool = false
    @Stubbed var puckBearingSource: PuckBearingSource = .heading
    @Stubbed var puckBearingEnabled: Bool = true
}
