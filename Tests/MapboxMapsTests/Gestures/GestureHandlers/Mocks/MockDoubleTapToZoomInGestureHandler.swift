@testable import MapboxMaps

final class MockDoubleTapToZoomInGestureHandler: GestureHandler, DoubleTapToZoomInGestureHandlerProtocol {
    var focalPoint: CGPoint? = nil
}
