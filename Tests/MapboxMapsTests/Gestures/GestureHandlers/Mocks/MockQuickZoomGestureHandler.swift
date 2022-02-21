@testable import MapboxMaps

final class MockQuickZoomGestureHandler: GestureHandler, FocusableGestureHandlerProtocol {
    var focalPoint: CGPoint?
}
