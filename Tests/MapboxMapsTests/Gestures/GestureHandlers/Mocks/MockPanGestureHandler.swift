@testable import MapboxMaps
import CoreGraphics

final class MockPanGestureHandler: GestureHandler, PanGestureHandlerProtocol {
    var decelerationFactor: CGFloat = 0.999

    var panMode: PanMode = .horizontalAndVertical
}
