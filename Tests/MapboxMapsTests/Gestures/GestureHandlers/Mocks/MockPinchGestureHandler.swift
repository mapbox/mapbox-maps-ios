@testable import MapboxMaps

final class MockPinchGestureHandler: GestureHandler, PinchGestureHandlerProtocol {
    var rotateEnabled: Bool = true

    var zoomEnabled: Bool = true

    var focalPoint: CGPoint?

    var simultaneousRotateAndPinchZoomEnabled: Bool = true
}
