@testable import MapboxMaps

final class MockPanGestureHandler: GestureHandler, PanGestureHandlerProtocol {
    var decelerationFactor: CGFloat = 0.999

    var panMode: PanMode = .horizontalAndVertical
    var multiFingerPanEnabled: Bool = true
}
