import Foundation

enum CameraAnimatorStatus: Equatable {
    case started
    case stopped(reason: StopReason)
    case paused

    enum StopReason: Equatable {
        case finished, cancelled
    }
}

typealias CameraAnimatorStatusPayload = (CameraAnimator, CameraAnimatorStatus)

extension Signal where Payload == any CameraAnimator {

    /// Creates new Signal from upstream filtering out ``CameraAnimator`` that is not owned by the given ``AnimationOwner``.
    public func owned(by owner: AnimationOwner) -> Self {
        filter { $0.owner == owner }
    }
}
