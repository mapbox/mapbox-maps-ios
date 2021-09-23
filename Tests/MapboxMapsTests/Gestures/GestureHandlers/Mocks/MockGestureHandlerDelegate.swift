@testable import MapboxMaps

final class MockGestureHandlerDelegate: GestureHandlerDelegate {
    let gestureBeganStub = Stub<GestureType, Void>()
    func gestureBegan(for gestureType: GestureType) {
        gestureBeganStub.call(with: gestureType)
    }

    struct GestureEndedParams {
        var gestureType: GestureType
        var willAnimate: Bool
    }
    let gestureEndedStub = Stub<GestureEndedParams, Void>()
    func gestureEnded(for gestureType: GestureType, willAnimate: Bool) {
        gestureEndedStub.call(with: GestureEndedParams(gestureType: gestureType, willAnimate: willAnimate))
    }

    let driftEndedStub = Stub<GestureType, Void>()
    func driftEnded(for gestureType: GestureType) {
        driftEndedStub.call(with: gestureType)
    }
}
