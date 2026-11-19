import Foundation
@_spi(Experimental) import MapboxCoreMaps

internal final class HighZoomToLowZoomAnimationSpecProvider: DefaultViewportTransitionAnimationSpecProviderProtocol {

    internal func makeAnimationSpecs(cameraOptions: CameraOptions) -> [DefaultViewportTransitionAnimationSpec] {
        var animationSpecs = [DefaultViewportTransitionAnimationSpec]()

        if let center = cameraOptions.center {
            animationSpecs.append(spec(\.center, center, duration: 1, delay: 0.8))
        }

        if let zoom = cameraOptions.zoom {
            animationSpecs.append(spec(\.zoom, zoom, duration: 1.8, delay: 0))
        }

        if let bearing = cameraOptions.bearing {
            animationSpecs.append(spec(\.bearing, bearing, duration: 1.2, delay: 0.6))
        }

        if let pitch = cameraOptions.pitch {
            animationSpecs.append(spec(\.pitch, pitch, duration: 1, delay: 0))
        }

        if let padding = cameraOptions.padding {
            animationSpecs.append(spec(\.padding, padding, duration: 1.2, delay: 0))
        }

        if let positionPoint = cameraOptions.positionPoint {
            animationSpecs.append(spec(\.positionPoint, positionPoint, duration: 1.2, delay: 0))
        }

        if let viewPoint = cameraOptions.viewPoint {
            animationSpecs.append(spec(\.viewPoint, viewPoint, duration: 1.2, delay: 0))
        }

        return animationSpecs
    }

    private func spec<T>(
        _ keyPath: WritableKeyPath<CameraOptions, T?>,
        _ value: T,
        duration: TimeInterval,
        delay: TimeInterval
    ) -> DefaultViewportTransitionAnimationSpec {
        DefaultViewportTransitionAnimationSpec(
            duration: duration,
            delay: delay,
            cameraOptionsComponent: CameraOptionsComponent(keyPath: keyPath, value: value))
    }
}
