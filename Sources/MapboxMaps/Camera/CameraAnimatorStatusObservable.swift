import Foundation

enum CameraAnimatorStatus: Equatable {
    case started
    case stopped(reason: StopReason)
    case paused

    enum StopReason: Equatable {
        case finished, cancelled
    }
}

final class CameraAnimatorStatusObserver {
    let owners: [AnimationOwner]
    let onStarted: OnCameraAnimatorStarted?
    let onStopped: OnCameraAnimatorStopped?

    init(
        owners: [AnimationOwner],
        onStarted: OnCameraAnimatorStarted? = nil,
        onStopped: OnCameraAnimatorStopped? = nil
    ) {
        self.owners = owners
        self.onStarted = onStarted
        self.onStopped = onStopped
    }
}

/// A closure to handle event when a camera animator has started.
public typealias OnCameraAnimatorStarted = (CameraAnimator) -> Void
/// A closure to handle event when a camera animator has stopped.
public typealias OnCameraAnimatorStopped = (CameraAnimator, _ isCancelled: Bool) -> Void
