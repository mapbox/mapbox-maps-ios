import Foundation
import QuartzCore

internal final class MapAnimatorImpl {
    internal enum InternalState: Equatable {
        case initial
        case running(CFTimeInterval)
        case paused(Double)
        case final(UIViewAnimatingPosition)
    }

    /// The animator's owner.
    internal let owner: AnimationOwner

    private let mainQueue: MainQueueProtocol

    /// Represents the animation that this animator is attempting to execute
    private var animations: [(Double) -> Void] = []

    private var completions = [AnimationCompletion]()

    internal private(set) var internalState = InternalState.initial {
        didSet {
            switch (oldValue, internalState) {
            case (.initial, .running), (.paused, .running):
//                delegate?.basicCameraAnimatorDidStartRunning(self)
                break
            case (.running, .paused), (.running, .final):
//                delegate?.basicCameraAnimatorDidStopRunning(self)
                break
            default:
                // this matches cases where…
                // * oldValue and internalState are the same
                // * initial transitions to paused
                // * paused transitions to final
                // * initial transitions to final
                // * the transition is invalid…
                //     * running/paused/final --> initial
                //     * final --> running/paused
                break
            }
        }
    }

    private var unitBezier: UnitBezier

    internal var timingCurve: TimingCurve = .linear {
        didSet { unitBezier = UnitBezier(p1: timingCurve.p1, p2: timingCurve.p1) }
    }

    internal var duration: TimeInterval

    /// Boolean that represents if the animation is running or not.
    internal var isRunning: Bool {
        switch internalState {
        case .initial:
            return false
        case .running:
            return true
        case .final, .paused:
            return false
        }
    }

    /// Boolean that represents if the animation is running normally or in reverse.
    internal var isReversed: Bool = false

    /// A Boolean value that indicates whether a completed animation remains in the active state.
    internal var pausesOnCompletion: Bool = false

    internal var scrubsLinearly: Bool = true

    private var internalFractionComplete: Double = 0

    /// Value that represents what percentage of the animation has been completed.
    internal var fractionComplete: Double {
        get { internalFractionComplete }
        set {
            switch internalState {
            case .initial:
                internalState = .running(timeProvider.current)
                fallthrough
            case .paused:
                internalFractionComplete = newValue
                if scrubsLinearly {
                    updateLinearly(for: newValue)
                } else {
                    update(for: newValue)
                }
            case .running, .final:
                // do nothing
                break
            }
        }
    }

    internal var repeatCount: Int = 0
    internal var autoreverses: Bool = false
    private var displayLinkCoordinator: DisplayLinkCoordinator
    private var timeProvider: TimeProvider

    // MARK: Initializer
    internal init(
        duration: TimeInterval,
        curve: TimingCurve,
        owner: AnimationOwner = .unspecified,
        mainQueue: MainQueueProtocol = MainQueue(),
        timeProvider: TimeProvider = DefaultTimeProvider(),
        displayLinkCoordinator: DisplayLinkCoordinator
    ) {
        self.duration = duration
        self.timingCurve = curve
        self.owner = owner
        self.mainQueue = mainQueue
        self.timeProvider = timeProvider
        self.displayLinkCoordinator = displayLinkCoordinator
        self.unitBezier = UnitBezier(p1: curve.p1, p2: curve.p1)
    }

    /// See ``BasicCameraAnimator/startAnimation()``
    internal func startAnimation() {
        startAnimation(afterDelay: 0)
    }

    /// See ``BasicCameraAnimator/startAnimation(afterDelay:)``
    internal func startAnimation(afterDelay delay: TimeInterval) {
        switch internalState {
        case .initial:
            internalState = .running(timeProvider.current + delay)
            displayLinkCoordinator.add(self)
        case .running:
            // already running; do nothing
            break
        case let .paused(progress):
            let timePassed = duration * progress
            let retrojectedStartTime = timeProvider.current - timePassed
            if delay > 0 {
                Log.error(forMessage: "A paused animator cannot be started with a delay. It will be started immediately.")
            }
            internalState = .running(retrojectedStartTime)
            displayLinkCoordinator.add(self)
        case .final:
            // animators cannot be restarted
            break
        }
    }

    /// See ``BasicCameraAnimator/pauseAnimation()``
    internal func pauseAnimation() {
        switch internalState {
        case .initial:
            internalState = .paused(0)
        case .running:
            internalState = .paused(internalFractionComplete)
            displayLinkCoordinator.remove(self)
        case .paused, .final:
            // do nothing
            break
        }
    }

    /// Stops the animation.
    internal func stopAnimation() {
        switch internalState {
        case .initial:
            internalState = .final(.current)
            completions.forEach { $0(.current) }
            completions.removeAll()
        case .running, .paused:
            internalState = .final(.current)
            displayLinkCoordinator.remove(self)
            completions.forEach { $0(.current) }
            completions.removeAll()
        case .final:
            // Already stopped, so do nothing
            break
        }
    }

    /// Add animations block to the animator.
    internal func addAnimations(_ animation: @escaping (Double) -> Void) {
        animations.append(animation)
    }

    /// Add a completion block to the animator.
    internal func addCompletion(_ completion: @escaping AnimationCompletion) {
        switch internalState {
        case .initial, .running, .paused:
            completions.append(completion)
        case .final(let position):
            mainQueue.async {
                completion(position)
            }
        }
    }

    private func completeOrPause() {
        switch internalState {
        case .initial:
            break
        case .running:
            if pausesOnCompletion {
                internalState = .paused(internalFractionComplete)
            } else {
                internalState = .final(.end)
                completions.forEach { $0(.end) }
            }
        case .paused:
            if !pausesOnCompletion {
                internalState = .final(.end)
                completions.forEach { $0(.end) }
            }
        case .final:
            break
        }
    }

    internal func updateWith(targetTime: CFTimeInterval) {
        switch internalState {
        case .initial, .paused, .final:
            return
        case let .running(startTimestamp):
            guard targetTime > startTimestamp else {
                return
            }
            let timePassed = targetTime - startTimestamp
            let cycle = Int(timePassed / duration)

            if cycle > repeatCount {
                completeOrPause()
                return
            }

            let cycleProgress = timePassed.truncatingRemainder(dividingBy: duration)

            let fractionComplete: Double
            if !autoreverses || (autoreverses && cycle.isMultiple(of: 2)) {
                fractionComplete = cycleProgress / duration
            } else {
                fractionComplete = 1 - cycleProgress / duration
            }

            update(for: fractionComplete)
        }
    }

    private func update(for fractionComplete: Double) {
        let curvedProgress = unitBezier.solve(fractionComplete, 1e-6)

        updateLinearly(for: curvedProgress)
    }

    private func updateLinearly(for fractionComplete: Double) {
        for animation in animations {
            animation(fractionComplete)
        }
    }
}

extension MapAnimatorImpl: DisplayLinkParticipant {
    func participate(targetTimestamp: CFTimeInterval) {
        updateWith(targetTime: targetTimestamp)
    }
}
