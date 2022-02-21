@testable import MapboxMaps

final class MockDoubleTapToZoomInGestureHandler: GestureHandler, FocusableGestureHandlerProtocol {
    var focalPoint: CGPoint?
}
