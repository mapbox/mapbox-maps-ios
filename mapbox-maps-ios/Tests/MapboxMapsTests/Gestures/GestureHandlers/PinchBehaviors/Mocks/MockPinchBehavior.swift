@testable import MapboxMaps

final class MockPinchBehavior: PinchBehavior {
    struct UpdateParams: Equatable {
        var pinchMidpoint: CGPoint
        var pinchScale: CGFloat
    }
    let updateStub = Stub<UpdateParams, Void>()
    func update(pinchMidpoint: CGPoint, pinchScale: CGFloat) {
        updateStub.call(with: .init(pinchMidpoint: pinchMidpoint, pinchScale: pinchScale))
    }
}
