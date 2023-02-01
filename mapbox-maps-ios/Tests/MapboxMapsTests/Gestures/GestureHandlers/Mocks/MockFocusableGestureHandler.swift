@testable import MapboxMaps

final class MockFocusableGestureHandler: GestureHandler, FocusableGestureHandlerProtocol {
    var focalPoint: CGPoint?
}
