@testable import MapboxMaps

final class MockDoubleTouchToZoomOutGestureHandler: GestureHandler, DoubleTouchToZoomOutGestureHandlerProtocol {
    var focalPoint: CGPoint? = nil
}
