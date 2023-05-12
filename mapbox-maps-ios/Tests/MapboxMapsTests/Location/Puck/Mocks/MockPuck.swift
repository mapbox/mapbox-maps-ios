@testable import MapboxMaps

final class MockPuck: Puck {
    @Stubbed var isActive: Bool = false
    @Stubbed var puckBearing: PuckBearing = .heading
    @Stubbed var puckBearingEnabled: Bool = true
}
