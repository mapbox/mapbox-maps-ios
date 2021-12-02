@_spi(Experimental) @testable import MapboxMaps

final class MockPinchGestureHandler: GestureHandler, PinchGestureHandlerProtocol {
    var rotateEnabled: Bool = true

    var behavior: PinchGestureBehavior = .tracksTouchLocationsWhenPanningAfterZoomChange
}
