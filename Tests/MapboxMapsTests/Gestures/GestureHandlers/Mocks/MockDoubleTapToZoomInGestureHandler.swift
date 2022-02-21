@testable import MapboxMaps

final class MockDoubleTapToZoomInGestureHandler: GestureHandler, ZoomGestureHandlerProtocol {
    var focalPoint: CGPoint?
}
