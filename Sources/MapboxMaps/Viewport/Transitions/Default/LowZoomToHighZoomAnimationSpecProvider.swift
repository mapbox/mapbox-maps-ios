import Foundation

internal final class LowZoomToHighZoomAnimationSpecProvider: DefaultViewportTransitionAnimationSpecProviderProtocol {
    private let mapboxMap: MapboxMapProtocol

    internal init(mapboxMap: MapboxMapProtocol) {
        self.mapboxMap = mapboxMap
    }

    // swiftlint:disable:next function_body_length
    internal func makeAnimationSpecs(cameraOptions: CameraOptions) -> [DefaultViewportTransitionAnimationSpec] {
        var animationSpecs = [DefaultViewportTransitionAnimationSpec]()

        let maxDuration: TimeInterval = 3
        let cameraState = mapboxMap.cameraState

        var centerDuration: TimeInterval = 0
        if let center = cameraOptions.center {
            let distance = distanceInViewSpace(from: cameraState.center, to: center)
            // points / s
            let centerAnimationRate: Double = 500
            centerDuration = min(Double(distance) / centerAnimationRate, maxDuration)
            animationSpecs.append(DefaultViewportTransitionAnimationSpec(
                duration: centerDuration,
                delay: 0,
                cameraOptionsComponent: CameraOptionsComponent(
                    keyPath: \.center,
                    value: center)))
        }

        var zoomDelay: TimeInterval = 0
        var zoomDuration: TimeInterval = 0
        if let zoom = cameraOptions.zoom {
            let zoomDelta = abs(zoom - cameraState.zoom)
            // zoom level / s
            let zoomAnimationRate = 2.2
            zoomDelay = centerDuration / 2
            zoomDuration = min(Double(zoomDelta) / zoomAnimationRate, maxDuration)
            animationSpecs.append(DefaultViewportTransitionAnimationSpec(
                duration: zoomDuration,
                delay: zoomDelay,
                cameraOptionsComponent: CameraOptionsComponent(
                    keyPath: \.zoom,
                    value: zoom)))
        }

        if let bearing = cameraOptions.bearing {
            let bearingDuration: TimeInterval = 1.8
            let bearingDelay: TimeInterval = max(zoomDelay + zoomDuration - bearingDuration, 0)
            animationSpecs.append(DefaultViewportTransitionAnimationSpec(
                duration: bearingDuration,
                delay: bearingDelay,
                cameraOptionsComponent: CameraOptionsComponent(
                    keyPath: \.bearing,
                    value: bearing)))
        }

        let pitchAndPaddingDuration: TimeInterval = 1.2
        let pitchAndPaddingDelay: TimeInterval = max(zoomDelay + zoomDuration - pitchAndPaddingDuration + 0.1, 0)
        if let pitch = cameraOptions.pitch {
            animationSpecs.append(DefaultViewportTransitionAnimationSpec(
                duration: pitchAndPaddingDuration,
                delay: pitchAndPaddingDelay,
                cameraOptionsComponent: CameraOptionsComponent(
                    keyPath: \.pitch,
                    value: pitch)))
        }

        if let padding = cameraOptions.padding {
            animationSpecs.append(DefaultViewportTransitionAnimationSpec(
                duration: pitchAndPaddingDuration,
                delay: pitchAndPaddingDelay,
                cameraOptionsComponent: CameraOptionsComponent(
                    keyPath: \.padding,
                    value: padding)))
        }

        return animationSpecs
    }

    func distanceInViewSpace(from fromCoordinate: CLLocationCoordinate2D,
                             to toCoordinate: CLLocationCoordinate2D) -> CGFloat {
        let fromPoint = mapboxMap.point(for: fromCoordinate)
        let toPoint = mapboxMap.point(for: toCoordinate)
        return hypot(fromPoint.x - toPoint.x, fromPoint.y - toPoint.y)
    }
}
