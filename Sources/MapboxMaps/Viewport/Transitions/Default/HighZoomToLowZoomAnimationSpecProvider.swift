import Foundation

internal final class HighZoomToLowZoomAnimationSpecProvider: DefaultViewportTransitionAnimationSpecProviderProtocol {

    internal func makeAnimationSpecs(cameraOptions: CameraOptions) -> [DefaultViewportTransitionAnimationSpec] {
        var animationSpecs = [DefaultViewportTransitionAnimationSpec]()

        if let center = cameraOptions.center {
            animationSpecs.append(DefaultViewportTransitionAnimationSpec(
                duration: 1,
                delay: 0.8,
                cameraOptionsComponent: CameraOptionsComponent(
                    keyPath: \.center,
                    value: center)))
        }

        if let zoom = cameraOptions.zoom {
            animationSpecs.append(DefaultViewportTransitionAnimationSpec(
                duration: 1.8,
                delay: 0,
                cameraOptionsComponent: CameraOptionsComponent(
                    keyPath: \.zoom,
                    value: zoom)))
        }

        if let bearing = cameraOptions.bearing {
            animationSpecs.append(DefaultViewportTransitionAnimationSpec(
                duration: 1.2,
                delay: 0.6,
                cameraOptionsComponent: CameraOptionsComponent(
                    keyPath: \.bearing,
                    value: bearing)))
        }

        if let pitch = cameraOptions.pitch {
            animationSpecs.append(DefaultViewportTransitionAnimationSpec(
                duration: 1,
                delay: 0,
                cameraOptionsComponent: CameraOptionsComponent(
                    keyPath: \.pitch,
                    value: pitch)))
        }

        if let padding = cameraOptions.padding {
            animationSpecs.append(DefaultViewportTransitionAnimationSpec(
                duration: 1.2,
                delay: 0,
                cameraOptionsComponent: CameraOptionsComponent(
                    keyPath: \.padding,
                    value: padding)))
        }

        return animationSpecs
    }
}
