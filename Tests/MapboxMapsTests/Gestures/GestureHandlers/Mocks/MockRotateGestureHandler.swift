import Foundation
@testable import MapboxMaps

final class MockRotateGestureHandler: GestureHandler, RotateGestureHandlerProtocol {
    var focalPoint: CGPoint?
    var simultaneousRotateAndPinchZoomEnabled: Bool = true
}
