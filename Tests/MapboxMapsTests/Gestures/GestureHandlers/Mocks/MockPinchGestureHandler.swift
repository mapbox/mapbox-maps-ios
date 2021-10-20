@testable import MapboxMaps

final class MockPinchGestureHandler: GestureHandler, PinchGestureHandlerProtocol {
    var rotationEnabled: Bool = true
}
