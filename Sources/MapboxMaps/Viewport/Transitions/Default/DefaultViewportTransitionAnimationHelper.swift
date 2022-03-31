import UIKit

internal protocol DefaultViewportTransitionAnimationHelperProtocol: AnyObject {
    func makeAnimation(cameraOptions: CameraOptions,
                       maxDuration: TimeInterval) -> DefaultViewportTransitionAnimationProtocol
}

internal final class DefaultViewportTransitionAnimationHelper: DefaultViewportTransitionAnimationHelperProtocol {

    private let mapboxMap: MapboxMapProtocol
    private let animationSpecProvider: DefaultViewportTransitionAnimationSpecProviderProtocol
    private let cameraAnimationsManager: CameraAnimationsManagerProtocol
    private let animationFactory: DefaultViewportTransitionAnimationFactoryProtocol

    internal init(mapboxMap: MapboxMapProtocol,
                  animationSpecProvider: DefaultViewportTransitionAnimationSpecProviderProtocol,
                  cameraAnimationsManager: CameraAnimationsManagerProtocol,
                  animationFactory: DefaultViewportTransitionAnimationFactoryProtocol) {
        self.mapboxMap = mapboxMap
        self.animationSpecProvider = animationSpecProvider
        self.cameraAnimationsManager = cameraAnimationsManager
        self.animationFactory = animationFactory
    }

    internal func makeAnimation(cameraOptions: CameraOptions,
                                maxDuration: TimeInterval) -> DefaultViewportTransitionAnimationProtocol {

        var animationSpecs = animationSpecProvider.makeAnimationSpecs(
            cameraOptions: cameraOptions)

        // scale the animation durations and delays if the total exceeds the max duration
        if let longestTotal = animationSpecs.map(\.total).max(),
           longestTotal > maxDuration {
            let adjustmentFactor = maxDuration / longestTotal
            animationSpecs = animationSpecs.map {
                $0.scaled(by: adjustmentFactor)
            }
        }

        // create animations
        let animationComponents: [DefaultViewportTransitionAnimationProtocol] = animationSpecs.map { animationSpec in
            let animator = cameraAnimationsManager.makeSimpleCameraAnimator(
                from: CameraOptions(cameraState: mapboxMap.cameraState),
                to: animationSpec.cameraOptionsComponent.cameraOptions,
                duration: animationSpec.duration,
                curve: .easeInOut,
                owner: .defaultViewportTransition)
            return animationFactory.makeAnimationComponent(
                animator: animator,
                delay: animationSpec.delay,
                cameraOptionsComponent: animationSpec.cameraOptionsComponent)
        }
        return animationFactory.makeAnimation(components: animationComponents)
    }
}
