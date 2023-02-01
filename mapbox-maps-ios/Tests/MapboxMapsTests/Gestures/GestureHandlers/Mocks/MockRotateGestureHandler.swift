import Foundation
@testable import MapboxMaps

final class MockRotateGestureHandler: GestureHandler, RotateGestureHandlerProtocol {
    var focalPoint: CGPoint?
    var simultaneousRotateAndPinchZoomEnabled: Bool = true

    let scheduleRotationUpdateIfNeededStub = Stub<Void, Void>()
    func scheduleRotationUpdateIfNeeded() {
        scheduleRotationUpdateIfNeededStub.call()
    }
}
