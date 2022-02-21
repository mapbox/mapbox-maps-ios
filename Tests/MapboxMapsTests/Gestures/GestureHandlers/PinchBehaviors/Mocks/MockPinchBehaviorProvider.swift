@testable import MapboxMaps

final class MockPinchBehaviorProvider: PinchBehaviorProviderProtocol {
    struct MakePinchBehaviorParams: Equatable {
        var panEnabled: Bool
        var zoomEnabled: Bool
        var rotateEnabled: Bool
        var initialCameraState: CameraState
        var initialPinchMidpoint: CGPoint
        var initialPinchAngle: CGFloat
        var focalPoint: CGPoint?
    }
    let makePinchBehaviorStub = Stub<MakePinchBehaviorParams, PinchBehavior>(defaultReturnValue: MockPinchBehavior())
    // swiftlint:disable:next function_parameter_count
    func makePinchBehavior(panEnabled: Bool,
                           zoomEnabled: Bool,
                           rotateEnabled: Bool,
                           initialCameraState: CameraState,
                           initialPinchMidpoint: CGPoint,
                           initialPinchAngle: CGFloat,
                           focalPoint: CGPoint?) -> PinchBehavior {
        makePinchBehaviorStub.call(with: .init(
            panEnabled: panEnabled,
            zoomEnabled: zoomEnabled,
            rotateEnabled: rotateEnabled,
            initialCameraState: initialCameraState,
            initialPinchMidpoint: initialPinchMidpoint,
            initialPinchAngle: initialPinchAngle,
            focalPoint: focalPoint))
    }
}
