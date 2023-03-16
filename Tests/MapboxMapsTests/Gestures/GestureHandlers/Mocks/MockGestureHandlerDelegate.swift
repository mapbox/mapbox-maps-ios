@testable import MapboxMaps

final class MockGestureHandlerDelegate: GestureHandlerDelegate {
    let gestureBeganStub = Stub<GestureType, Void>()
    func gestureBegan(for gestureType: GestureType) {
        gestureBeganStub.call(with: gestureType)
    }

    struct GestureEndedParams: Equatable {
        var gestureType: GestureType
        var willAnimate: Bool
    }
    let gestureEndedStub = Stub<GestureEndedParams, Void>()
    func gestureEnded(for gestureType: GestureType, willAnimate: Bool) {
        gestureEndedStub.call(with: GestureEndedParams(gestureType: gestureType, willAnimate: willAnimate))
    }

    let animationEndedStub = Stub<GestureType, Void>()
    func animationEnded(for gestureType: GestureType) {
        animationEndedStub.call(with: gestureType)
    }
}
