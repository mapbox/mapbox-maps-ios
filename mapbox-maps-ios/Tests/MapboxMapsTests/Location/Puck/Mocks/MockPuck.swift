@testable import MapboxMaps

final class MockPuck2D: Puck2DRendererProtocol {
    @Stubbed var isActive: Bool = false
    @Stubbed var puckBearing: PuckBearing = .heading
    @Stubbed var puckBearingEnabled: Bool = true
    @Stubbed var configuration: Puck2DConfiguration = .makeDefault()
}

final class MockPuck3D: Puck3DRendererProtocol {
    @Stubbed var isActive: Bool = false
    @Stubbed var puckBearing: PuckBearing = .heading
    @Stubbed var puckBearingEnabled: Bool = true
    @Stubbed var configuration: Puck3DConfiguration = Puck3DConfiguration(model: Model())
}
