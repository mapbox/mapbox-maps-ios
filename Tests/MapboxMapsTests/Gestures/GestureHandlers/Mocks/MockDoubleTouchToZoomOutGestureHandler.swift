@testable import MapboxMaps

final class MockDoubleTouchToZoomOutGestureHandlerProtocol: GestureHandler, PanGestureHandlerProtocol {
    var focalPoint: CGPoint? = nil
}
