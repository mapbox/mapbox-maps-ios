@testable import MapboxMaps

final class MockPinchBehavior: PinchBehavior {
    struct UpdateParams: Equatable {
        var pinchMidpoint: CGPoint
        var pinchScale: CGFloat
        var pinchAngle: CGFloat
    }
    let updateStub = Stub<UpdateParams, Void>()
    func update(pinchMidpoint: CGPoint, pinchScale: CGFloat, pinchAngle: CGFloat) {
        updateStub.call(with: .init(
            pinchMidpoint: pinchMidpoint,
            pinchScale: pinchScale,
            pinchAngle: pinchAngle))
    }
}
