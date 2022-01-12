internal protocol DefaultViewportTransitionAnimationHelperProtocol: AnyObject {
    func animate(to cameraOptions: CameraOptions,
                 maxDuration: TimeInterval,
                 completion: @escaping (Bool) -> Void) -> Cancelable
}

internal final class DefaultViewportTransitionAnimationHelper: DefaultViewportTransitionAnimationHelperProtocol {

    private let mapboxMap: MapboxMapProtocol
    private let cameraAnimationsManager: CameraAnimationsManagerProtocol

    internal init(mapboxMap: MapboxMapProtocol,
                  cameraAnimationsManager: CameraAnimationsManagerProtocol) {
        self.mapboxMap = mapboxMap
        self.cameraAnimationsManager = cameraAnimationsManager
    }

    internal func animate(to cameraOptions: CameraOptions,
                          maxDuration: TimeInterval,
                          completion: @escaping (Bool) -> Void) -> Cancelable {

        var animations: [Animation]

        let currentZoom = mapboxMap.cameraState.zoom
        if let targetZoom = cameraOptions.zoom, currentZoom < targetZoom {
            animations = makeAnimationsForLowZoomToHighZoom(cameraOptions: cameraOptions)
        } else {
            animations = makeAnimationsForHighZoomToLowZoom(cameraOptions: cameraOptions)
        }

        if let longestAnimation = animations.max(by: { $0.total <= $1.total }),
           longestAnimation.total > maxDuration {
            let adjustmentFactor = maxDuration / longestAnimation.total
            animations = animations.map {
                Animation(
                    duration: $0.duration * adjustmentFactor,
                    delay: $0.delay * adjustmentFactor,
                    cameraOptions: $0.cameraOptions)
            }
        }

        let cancelable = CompositeCancelable()
        let group = DispatchGroup()
        var isFinished = true
        for animation in animations {
            group.enter()
            let animator = cameraAnimationsManager.makeAnimator(
                duration: animation.duration,
                curve: .easeInOut,
                animationOwner: AnimationOwner(rawValue: "Viewport")) {
                    $0.center.toValue = animation.cameraOptions.center
                    $0.zoom.toValue = animation.cameraOptions.zoom
                    $0.bearing.toValue = animation.cameraOptions.bearing
                    $0.pitch.toValue = animation.cameraOptions.pitch
                    $0.padding.toValue = animation.cameraOptions.padding
                }
            animator.addCompletion { position in
                isFinished = isFinished && (position != .current)
                group.leave()
            }
            animator.startAnimation(afterDelay: animation.delay)
            cancelable.add(animator)
        }
        group.notify(queue: .main) {
            completion(isFinished)
        }
        return cancelable
    }

    private func distanceInViewSpace(from fromCoordinate: CLLocationCoordinate2D,
                                     to toCoordinate: CLLocationCoordinate2D) -> CGFloat {
        let fromPoint = mapboxMap.point(for: fromCoordinate)
        let toPoint = mapboxMap.point(for: toCoordinate)
        return hypot(fromPoint.x - toPoint.x, fromPoint.y - toPoint.y)
    }

    private struct Animation {
        var duration: TimeInterval
        var delay: TimeInterval
        var cameraOptions: CameraOptions

        var total: TimeInterval {
            delay + duration
        }
    }

    private func makeAnimationsForLowZoomToHighZoom(cameraOptions: CameraOptions) -> [Animation] {

        var animations = [Animation]()

        let maxDuration: TimeInterval = 3
        let cameraState = mapboxMap.cameraState

        var centerDuration: TimeInterval = 0
        if let center = cameraOptions.center {
            let distance = distanceInViewSpace(from: cameraState.center, to: center)
            // points / s
            let centerAnimationRate: Double = 500
            centerDuration = min(Double(distance) / centerAnimationRate, maxDuration)
            animations.append(Animation(
                duration: centerDuration,
                delay: 0,
                cameraOptions: CameraOptions(center: center)))
        }

        var zoomDelay: TimeInterval = 0
        var zoomDuration: TimeInterval = 0
        if let zoom = cameraOptions.zoom {
            let currentMapCameraZoom = cameraState.zoom
            let zoomDelta = abs(zoom - currentMapCameraZoom)
            // zoom level / s
            let zoomAnimationRate = 2.2
            zoomDelay = centerDuration / 2
            zoomDuration = min(Double(zoomDelta) / zoomAnimationRate, maxDuration)
            animations.append(Animation(
                duration: zoomDuration,
                delay: zoomDelay,
                cameraOptions: CameraOptions(zoom: zoom)))
        }

        if let bearing = cameraOptions.bearing {
            let bearingDuration: TimeInterval = 1.8
            let bearingDelay: TimeInterval = max(zoomDelay + zoomDuration - bearingDuration, 0)
            animations.append(Animation(
                duration: bearingDuration,
                delay: bearingDelay,
                cameraOptions: CameraOptions(bearing: bearing)))
        }

        let pitchAndPaddingDuration: TimeInterval = 1.2
        let pitchAndPaddingDelay: TimeInterval = max(zoomDelay + zoomDuration - pitchAndPaddingDuration + 0.1, 0)
        if let pitch = cameraOptions.pitch {
            animations.append(Animation(
                duration: pitchAndPaddingDuration,
                delay: pitchAndPaddingDelay,
                cameraOptions: CameraOptions(pitch: pitch)))
        }

        if let padding = cameraOptions.padding {
            animations.append(Animation(
                duration: pitchAndPaddingDuration,
                delay: pitchAndPaddingDelay,
                cameraOptions: CameraOptions(padding: padding)))
        }

        return animations
    }

    private func makeAnimationsForHighZoomToLowZoom(cameraOptions: CameraOptions) -> [Animation] {
        var animations = [Animation]()

        if let center = cameraOptions.center {
            animations.append(Animation(
                duration: 1,
                delay: 0.8,
                cameraOptions: CameraOptions(center: center)))
        }

        if let zoom = cameraOptions.zoom {
            animations.append(Animation(
                duration: 1.8,
                delay: 0,
                cameraOptions: CameraOptions(zoom: zoom)))
        }

        if let bearing = cameraOptions.bearing {
            animations.append(Animation(
                duration: 1.2,
                delay: 0.6,
                cameraOptions: CameraOptions(bearing: bearing)))
        }

        if let pitch = cameraOptions.pitch {
            animations.append(Animation(
                duration: 1,
                delay: 0,
                cameraOptions: CameraOptions(pitch: pitch)))
        }

        if let padding = cameraOptions.padding {
            animations.append(Animation(
                duration: 1.2,
                delay: 0,
                cameraOptions: CameraOptions(padding: padding)))
        }

        return animations
    }
}
