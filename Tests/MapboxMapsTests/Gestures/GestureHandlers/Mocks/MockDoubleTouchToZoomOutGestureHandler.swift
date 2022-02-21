@testable import MapboxMaps

final class MockDoubleTouchToZoomOutGestureHandler: GestureHandler, ZoomGestureHandlerProtocol {
    var focalPoint: CGPoint?
}
