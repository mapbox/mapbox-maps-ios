@testable import MapboxMaps

final class MockDoubleTouchToZoomOutGestureHandler: GestureHandler, FocusableGestureHandlerProtocol {
    var focalPoint: CGPoint?
}
