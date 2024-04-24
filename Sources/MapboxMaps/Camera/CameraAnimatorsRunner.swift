import UIKit

internal protocol CameraAnimatorsRunnerProtocol: AnyObject {
    var isEnabled: Bool { get set }
    var cameraAnimators: [CameraAnimator] { get }
    func update()
    func cancelAnimations()
    func cancelAnimations(withOwners owners: [AnimationOwner])
    func cancelAnimations(withOwners owners: [AnimationOwner], andTypes: [AnimationType])
    func add(_ animator: CameraAnimatorProtocol)
    var onCameraAnimatorStatusChanged: Signal<CameraAnimatorStatusPayload> { get }
}

internal final class CameraAnimatorsRunner: CameraAnimatorsRunnerProtocol {

    /// When `false`, all existing animations
    /// will be canceled at each invocation of ``CameraAnimatorsRunner/update()`` and any
    /// new animations will be canceled immediately
    /// It is false by default, until the MapView is added to a UIWindow and display link is created.
    var isEnabled: Bool = false {
        didSet {
            if !isEnabled {
                cancelAnimations()
            }
        }
    }

    private var cameraAnimatorStatusSignal = SignalSubject<CameraAnimatorStatusPayload>()
    var onCameraAnimatorStatusChanged: Signal<CameraAnimatorStatusPayload> { cameraAnimatorStatusSignal.signal }

    /// See ``CameraAnimationsManager/cameraAnimators``.
    internal var cameraAnimators: [CameraAnimator] {
        return allCameraAnimators.allObjects
    }

    /// Weak references to all camera animators
    private let allCameraAnimators = WeakSet<CameraAnimatorProtocol>()

    /// Strong references only to running camera animators
    private var runningCameraAnimators = [CameraAnimatorProtocol]()
    private let mapboxMap: MapboxMapProtocol
    private var cancelables: Set<AnyCancelable> = []

    internal init(mapboxMap: MapboxMapProtocol) {
        self.mapboxMap = mapboxMap
    }

    internal func update() {
        guard isEnabled else {
            cancelAnimations()
            return
        }
        for animator in runningCameraAnimators {
            animator.update()
        }
    }

    /// See ``CameraAnimationsManager/cancelAnimations()``.
    internal func cancelAnimations() {
        for animator in cameraAnimators {
            animator.stopAnimation()
        }
    }

    internal func cancelAnimations(withOwners owners: [AnimationOwner]) {
        for animator in allCameraAnimators.allObjects where owners.contains(animator.owner) {
            animator.stopAnimation()
        }
    }

    func cancelAnimations(withOwners owners: [AnimationOwner], andTypes types: [AnimationType]) {
        for animator in allCameraAnimators.allObjects
        where owners.contains(animator.owner) && types.contains(animator.animationType) {
            animator.stopAnimation()
        }
    }

    func add(_ animator: CameraAnimatorProtocol) {
        allCameraAnimators.add(animator)

        animator.onCameraAnimatorStatusChanged.observe { [weak self, weak animator] status in
            guard let animator else { return }
            switch status {
            case .started:
                self?.cameraAnimatorDidStartRunning(animator)
            case .stopped(let reason):
                self?.cameraAnimatorDidStopRunning(animator, reason: reason)
            case .paused:
                self?.cameraAnimatorDidPause(animator)
            }
        }
        .store(in: &cancelables)
        if !isEnabled {
            animator.stopAnimation()
        }
    }
}

extension CameraAnimatorsRunner {
    /// When an animator starts running, `CameraAnimationsRunner` takes a strong reference to it
    /// so that it stays alive while it is running. It also calls `beginAnimation` on `MapboxMap`.
    ///
    /// This solution replaces a previous implementation in which each animator was responsible for
    /// keeping itself alive while it was running (if desired). That approach was problematic because
    /// it was possible for it to result in a memory leak if the owning `MapView` (and corresponding display
    /// link) was deallocated, resulting in no more calls to `update()` which would prevent some
    /// animators from ever breaking their strong self references.
    ///
    /// Moving this responsibility to `CameraAnimationsRunner` means that if the `MapView` is
    /// deallocated, these strong references will be released as well.
    private func cameraAnimatorDidStartRunning(_ cameraAnimator: CameraAnimatorProtocol) {
        if !runningCameraAnimators.contains(where: { $0 === cameraAnimator }) {
            runningCameraAnimators.append(cameraAnimator)
            mapboxMap.beginAnimation()
        }
        cameraAnimatorStatusSignal.send((cameraAnimator, .started))
    }

    /// When an animator stops running, `CameraAnimationsRunner` releases its strong reference to
    /// it so that it can be deinited if there are no other owning references. It also calls `endAnimation`
    /// on `MapboxMap`.
    ///
    /// See `cameraAnimatorDidStartRunning(_:)` for further discussion of the rationale for this
    /// architecture.
    private func cameraAnimatorDidStopRunning(_ cameraAnimator: CameraAnimatorProtocol, reason: CameraAnimatorStatus.StopReason) {
        if runningCameraAnimators.contains(where: { $0 === cameraAnimator }) {
            runningCameraAnimators.removeAll { $0 === cameraAnimator }
            mapboxMap.endAnimation()
        }
        cameraAnimatorStatusSignal.send((cameraAnimator, .stopped(reason: reason)))
    }

    /// When an animator is paused, `CameraAnimationsRunner` releases its strong reference to
    /// it so that it can be deinited if there are no other owning references. It also calls `endAnimation`
    /// on `MapboxMap`, upon resuming, it will be added back to the runner.
    ///
    /// See `cameraAnimatorDidStartRunning(_:)` for further discussion of the rationale for this
    /// architecture.
    private func cameraAnimatorDidPause(_ cameraAnimator: CameraAnimatorProtocol) {
        if runningCameraAnimators.contains(where: { $0 === cameraAnimator }) {
            runningCameraAnimators.removeAll { $0 === cameraAnimator }
            mapboxMap.endAnimation()
        }
        cameraAnimatorStatusSignal.send((cameraAnimator, .paused))
    }
}
