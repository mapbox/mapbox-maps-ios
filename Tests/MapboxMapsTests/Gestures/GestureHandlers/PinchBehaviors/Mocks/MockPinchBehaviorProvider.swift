@testable import MapboxMaps

final class MockPinchBehaviorProvider: PinchBehaviorProviderProtocol {
    struct MakePinchBehaviorParams: Equatable {
        var panEnabled: Bool
        var zoomEnabled: Bool
        var initialCameraState: CameraState
        var initialPinchMidpoint: CGPoint
        var focalPoint: CGPoint?
    }
    let makePinchBehaviorStub = Stub<MakePinchBehaviorParams, PinchBehavior>(defaultReturnValue: MockPinchBehavior())
    func makePinchBehavior(panEnabled: Bool,
                           zoomEnabled: Bool,
                           initialCameraState: CameraState,
                           initialPinchMidpoint: CGPoint,
                           focalPoint: CGPoint?) -> PinchBehavior {
        makePinchBehaviorStub.call(with: .init(
            panEnabled: panEnabled,
            zoomEnabled: zoomEnabled,
            initialCameraState: initialCameraState,
            initialPinchMidpoint: initialPinchMidpoint,
            focalPoint: focalPoint))
    }
}
