import UIKit

internal final class GestureDecelerationCameraAnimator: CameraAnimatorProtocol {
    private enum InternalState: Equatable {
        case initial
        case running
        case final(UIViewAnimatingPosition)
    }

    private let location: CGPoint
    private var velocity: CGPoint
    private let decelerationFactor: CGFloat
    private var previousDate: Date?
    private let locationChangeHandler: (_ fromLocation: CGPoint, _ toLocation: CGPoint) -> Void
    private let mainQueue: MainQueueProtocol
    private let dateProvider: DateProvider
    private var completionBlocks = [AnimationCompletion]()

    var onCameraAnimatorStatusChanged: Signal<CameraAnimatorStatus> { cameraAnimatorStatusSignal.signal }
    private let cameraAnimatorStatusSignal = SignalSubject<CameraAnimatorStatus>()

    private var internalState = InternalState.initial {
        didSet {
            switch (oldValue, internalState) {
            case (.initial, .running):
                cameraAnimatorStatusSignal.send(.started)
            case (.running, .final(let position)):
                let isCancelled = position != .end
                cameraAnimatorStatusSignal.send(.stopped(reason: isCancelled ? .cancelled : .finished))
            default:
                // this matches cases where…
                // * oldValue and internalState are the same
                // * initial transitions to final
                // * the transition is invalid…
                //     * running/final --> initial
                //     * final --> running
                break
            }
        }
    }

    internal var state: UIViewAnimatingState {
        switch internalState {
        case .running:
            return .active
        case .initial, .final:
            return .inactive
        }
    }

    internal let owner: AnimationOwner

    internal let animationType: AnimationType

    internal init(location: CGPoint,
                  velocity: CGPoint,
                  decelerationFactor: CGFloat,
                  owner: AnimationOwner,
                  type: AnimationType = .deceleration,
                  locationChangeHandler: @escaping (_ fromLocation: CGPoint, _ toLocation: CGPoint) -> Void,
                  mainQueue: MainQueueProtocol,
                  dateProvider: DateProvider) {
        self.location = location
        self.velocity = velocity
        self.decelerationFactor = decelerationFactor
        self.owner = owner
        self.animationType = type
        self.locationChangeHandler = locationChangeHandler
        self.mainQueue = mainQueue
        self.dateProvider = dateProvider
    }

    internal func startAnimation() {
        switch internalState {
        case .initial:
            previousDate = dateProvider.now
            internalState = .running
        case .running:
            // already running; do nothing
            break
        case .final:
            // animators cannot be restarted
            break
        }
    }

    internal func stopAnimation() {
        switch internalState {
        case .initial, .running:
            internalState = .final(.current)
            invokeCompletionBlocks(with: .current) // `current` represents an interrupted animation.
        case .final:
            // Already stopped, so do nothing
            break
        }
    }

    internal func cancel() {
        stopAnimation()
    }

    internal func addCompletion(_ completion: @escaping AnimationCompletion) {
        switch internalState {
        case .initial, .running:
            completionBlocks.append(completion)
        case .final(let position):
            mainQueue.async {
                completion(position)
            }
        }
    }

    private func invokeCompletionBlocks(with position: UIViewAnimatingPosition) {
        let blocks = completionBlocks
        for block in blocks {
            block(position)
        }
        completionBlocks.removeAll()
    }

    internal func update() {
        guard internalState == .running, let previousDate = previousDate else {
            return
        }

        let currentDate = dateProvider.now
        self.previousDate = currentDate

        let elapsedTime = CGFloat(currentDate.timeIntervalSince(previousDate))

        // This is part of a workaround for pan deceleration near the horizon.
        // Instead of allowing the touch location to travel farther and farther
        // away from the initial location, emit a series of increasingly smaller
        // displacements always relative to the initial location.
        var toLocation = location

        // calculate new location showing how far we have traveled
        toLocation.x += velocity.x * elapsedTime
        toLocation.y += velocity.y * elapsedTime

        locationChangeHandler(location, toLocation)

        // deceleration factor should be applied to the velocity once per millisecond
        velocity.x *= pow(decelerationFactor, (elapsedTime * 1000))
        velocity.y *= pow(decelerationFactor, (elapsedTime * 1000))

        if abs(velocity.x) < 35, abs(velocity.y) < 35 {
            internalState = .final(.end)
            invokeCompletionBlocks(with: .end)
        }
    }
}
