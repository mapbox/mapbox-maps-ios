@testable import MapboxMaps

final class MockQuickZoomGestureHandler: GestureHandler, ZoomGestureHandlerProtocol {
    var focalPoint: CGPoint?
}
