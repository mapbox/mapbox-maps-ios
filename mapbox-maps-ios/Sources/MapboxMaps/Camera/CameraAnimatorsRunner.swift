import UIKit

internal protocol CameraAnimatorsRunnerProtocol: AnyObject {
    var cameraAnimators: [CameraAnimator] { get }
    func update()
    func cancelAnimations()
    func cancelAnimations(withOwners owners: [AnimationOwner])
    func cancelAnimations(withOwners owners: [AnimationOwner], andTypes: [AnimationType])
    func add(_ animator: CameraAnimatorProtocol)
}

internal final class CameraAnimatorsRunner: CameraAnimatorsRunnerProtocol {

    /// When ``EnablableProtocol/isEnabled`` is `false`, all existing animations
    /// will be canceled at each invocation of ``CameraAnimatorsRunner/update()`` and any
    /// new animations will be canceled immediately.
    private let enablable: EnablableProtocol

    /// See ``CameraAnimationsManager/cameraAnimators``.
    internal var cameraAnimators: [CameraAnimator] {
        return allCameraAnimators.allObjects
    }

    /// Weak references to all camera animators
    private let allCameraAnimators = WeakSet<CameraAnimatorProtocol>()

    /// Strong references only to running camera animators
    private var runningCameraAnimators = [CameraAnimatorProtocol]()

    private let mapboxMap: MapboxMapProtocol

    internal init(mapboxMap: MapboxMapProtocol,
                  enablable: EnablableProtocol) {
        self.mapboxMap = mapboxMap
        self.enablable = enablable
    }

    internal func update() {
        guard enablable.isEnabled else {
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

    internal func add(_ animator: CameraAnimatorProtocol) {
        animator.delegate = self
        allCameraAnimators.add(animator)
        if !enablable.isEnabled {
            animator.stopAnimation()
        }
    }
}

extension CameraAnimatorsRunner: CameraAnimatorDelegate {
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
    internal func cameraAnimatorDidStartRunning(_ cameraAnimator: CameraAnimatorProtocol) {
        if !runningCameraAnimators.contains(where: { $0 === cameraAnimator }) {
            runningCameraAnimators.append(cameraAnimator)
            mapboxMap.beginAnimation()
        }
    }

    /// When an animator stops running, `CameraAnimationsRunner` releases its strong reference to
    /// it so that it can be deinited if there are no other owning references. It also calls `endAnimation`
    /// on `MapboxMap`.
    ///
    /// See `cameraAnimatorDidStartRunning(_:)` for further discussion of the rationale for this
    /// architecture.
    internal func cameraAnimatorDidStopRunning(_ cameraAnimator: CameraAnimatorProtocol) {
        if runningCameraAnimators.contains(where: { $0 === cameraAnimator }) {
            runningCameraAnimators.removeAll { $0 === cameraAnimator }
            mapboxMap.endAnimation()
        }
    }
}
