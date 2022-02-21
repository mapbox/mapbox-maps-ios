@testable import MapboxMaps

final class MockQuickZoomGestureHandler: GestureHandler, QuickZoomGestureHandlerProtocol {
    var focalPoint: CGPoint?
}
