import Foundation

internal protocol DefaultViewportTransitionAnimationProtocol: Cancelable {
    func updateTargetCamera(with cameraOptions: CameraOptions)
    func start(with completion: @escaping (Bool) -> Void)
}

internal final class DefaultViewportTransitionAnimation: DefaultViewportTransitionAnimationProtocol {
    private let components: [DefaultViewportTransitionAnimationProtocol]

    internal init(components: [DefaultViewportTransitionAnimationProtocol]) {
        self.components = components
    }

    func start(with completion: @escaping (Bool) -> Void) {
        let group = DispatchGroup()
        var allFinished = true
        for component in components {
            group.enter()
            component.start { isFinished in
                allFinished = allFinished && isFinished
                group.leave()
            }
        }
        group.notify(queue: .main) {
            completion(allFinished)
        }
    }

    internal func updateTargetCamera(with cameraOptions: CameraOptions) {
        for component in components {
            component.updateTargetCamera(with: cameraOptions)
        }
    }

    internal func cancel() {
        for component in components {
            component.cancel()
        }
    }
}

internal final class DefaultViewportTransitionAnimationComponent: DefaultViewportTransitionAnimationProtocol {
    private let animator: SimpleCameraAnimatorProtocol
    private let delay: TimeInterval
    private let cameraOptionsComponent: CameraOptionsComponentProtocol
    private let mapboxMap: MapboxMapProtocol

    internal init(animator: SimpleCameraAnimatorProtocol,
                  delay: TimeInterval,
                  cameraOptionsComponent: CameraOptionsComponentProtocol,
                  mapboxMap: MapboxMapProtocol) {
        self.animator = animator
        self.delay = delay
        self.cameraOptionsComponent = cameraOptionsComponent
        self.mapboxMap = mapboxMap
    }

    func start(with completion: @escaping (Bool) -> Void) {
        animator.addCompletion { position in
            completion(position != .current)
        }
        animator.startAnimation(afterDelay: delay)
    }

    internal func updateTargetCamera(with cameraOptions: CameraOptions) {
        guard let updatedComponent = cameraOptionsComponent.updated(with: cameraOptions) else {
            return
        }
        let isComplete = animator.state == .inactive
        if isComplete {
            mapboxMap.setCamera(to: updatedComponent.cameraOptions)
        } else {
            animator.to = updatedComponent.cameraOptions
        }
    }

    internal func cancel() {
        animator.cancel()
    }
}
