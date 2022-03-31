@testable import MapboxMaps
import XCTest

final class MockDefaultViewportTransitionAnimationFactory: DefaultViewportTransitionAnimationFactoryProtocol {
    struct MakeAnimationComponentParams {
        var animator: SimpleCameraAnimatorProtocol
        var delay: TimeInterval
        var cameraOptionsComponent: CameraOptionsComponentProtocol
    }
    let makeAnimationComponentStub = Stub<
        MakeAnimationComponentParams,
        DefaultViewportTransitionAnimationProtocol>(
            defaultReturnValue: MockDefaultViewportTransitionAnimation())
    func makeAnimationComponent(animator: SimpleCameraAnimatorProtocol,
                                delay: TimeInterval,
                                cameraOptionsComponent: CameraOptionsComponentProtocol) -> DefaultViewportTransitionAnimationProtocol {
        makeAnimationComponentStub.call(with: .init(
            animator: animator,
            delay: delay,
            cameraOptionsComponent: cameraOptionsComponent))
    }

    let makeAnimationStub = Stub<
        [DefaultViewportTransitionAnimationProtocol],
        DefaultViewportTransitionAnimationProtocol>(
            defaultReturnValue: MockDefaultViewportTransitionAnimation())
    func makeAnimation(components: [DefaultViewportTransitionAnimationProtocol]) -> DefaultViewportTransitionAnimationProtocol {
        makeAnimationStub.call(with: components)
    }
}
