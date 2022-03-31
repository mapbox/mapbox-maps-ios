import Foundation

internal protocol DefaultViewportTransitionAnimationFactoryProtocol: AnyObject {
    func makeAnimationComponent(animator: SimpleCameraAnimatorProtocol,
                                delay: TimeInterval,
                                cameraOptionsComponent: CameraOptionsComponentProtocol) -> DefaultViewportTransitionAnimationProtocol

    func makeAnimation(components: [DefaultViewportTransitionAnimationProtocol]) -> DefaultViewportTransitionAnimationProtocol
}

internal final class DefaultViewportTransitionAnimationFactory: DefaultViewportTransitionAnimationFactoryProtocol {
    private let mapboxMap: MapboxMapProtocol

    internal init(mapboxMap: MapboxMapProtocol) {
        self.mapboxMap = mapboxMap
    }

    internal func makeAnimation(components: [DefaultViewportTransitionAnimationProtocol]) -> DefaultViewportTransitionAnimationProtocol {
        return DefaultViewportTransitionAnimation(components: components)
    }

    internal func makeAnimationComponent(animator: SimpleCameraAnimatorProtocol,
                                         delay: TimeInterval,
                                         cameraOptionsComponent: CameraOptionsComponentProtocol) -> DefaultViewportTransitionAnimationProtocol {
        return DefaultViewportTransitionAnimationComponent(
            animator: animator,
            delay: delay,
            cameraOptionsComponent: cameraOptionsComponent,
            mapboxMap: mapboxMap)
    }
}
