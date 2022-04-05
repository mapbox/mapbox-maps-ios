@testable import MapboxMaps

final class MockDefaultViewportTransitionAnimationHelper: DefaultViewportTransitionAnimationHelperProtocol {

    struct MakeAnimationParams {
        var cameraOptions: CameraOptions
        var maxDuration: TimeInterval
    }
    let makeAnimationStub = Stub<
        MakeAnimationParams,
        DefaultViewportTransitionAnimationProtocol>(
            defaultReturnValue: MockDefaultViewportTransitionAnimation())
    func makeAnimation(cameraOptions: CameraOptions,
                       maxDuration: TimeInterval) -> DefaultViewportTransitionAnimationProtocol {
        makeAnimationStub.call(with: .init(
            cameraOptions: cameraOptions,
            maxDuration: maxDuration))
    }
}
