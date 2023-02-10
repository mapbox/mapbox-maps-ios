@testable import MapboxMaps

final class MockDefaultViewportTransitionAnimationSpecProvider: DefaultViewportTransitionAnimationSpecProviderProtocol {
    let makeAnimationSpecsStub = Stub<
        CameraOptions,
        [DefaultViewportTransitionAnimationSpec]>(
            defaultReturnValue: [])
    func makeAnimationSpecs(cameraOptions: CameraOptions) -> [DefaultViewportTransitionAnimationSpec] {
        makeAnimationSpecsStub.call(with: cameraOptions)
    }
}
