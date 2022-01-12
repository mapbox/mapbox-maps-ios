@testable import MapboxMaps

final class MockDefaultViewportTransitionAnimationHelper: DefaultViewportTransitionAnimationHelperProtocol {

    struct AnimateParams {
        var cameraOptions: CameraOptions
        var maxDuration: TimeInterval
        var completion: (Bool) -> Void
    }
    let animateStub = Stub<AnimateParams, Cancelable>(defaultReturnValue: MockCancelable())
    func animate(to cameraOptions: CameraOptions,
                 maxDuration: TimeInterval,
                 completion: @escaping (Bool) -> Void) -> Cancelable {
        animateStub.call(with: .init(
            cameraOptions: cameraOptions,
            maxDuration: maxDuration,
            completion: completion))
    }
}
