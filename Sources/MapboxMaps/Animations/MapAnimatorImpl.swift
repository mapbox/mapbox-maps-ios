import Foundation
import QuartzCore

internal final class MapAnimatorImpl {
    private enum InternalState: Equatable {
        case initial
        case running(CFTimeInterval)
        case paused(CFTimeInterval)
        case final(UIViewAnimatingPosition)
    }

    /// The animator's owner.
    internal let owner: AnimationOwner

    private let mainQueue: MainQueueProtocol

    /// Represents the animation that this animator is attempting to execute
    private var animations: [(Double) -> Void] = []

    private var completions = [AnimationCompletion]()
    private lazy var displayLink: CADisplayLink = {
        let link = CADisplayLink(
            target: ForwardingDisplayLinkTarget { [weak self] in
                self?.updateFromDisplayLink($0)
            },
            selector: #selector(ForwardingDisplayLinkTarget.update(with:)))
        return link
    }()
    private var internalState = InternalState.initial {
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

    public var duration: TimeInterval
    /// Boolean that represents if the animation is running or not.
    internal private(set) var isRunning: Bool = false

    /// Boolean that represents if the animation is running normally or in reverse.
    internal var isReversed: Bool = false

    /// A Boolean value that indicates whether a completed animation remains in the active state.
    internal var pausesOnCompletion: Bool = false

    /// Value that represents what percentage of the animation has been completed.
    internal var fractionComplete: Double = 0

    internal var repeatCount: Int = 0
    internal var autoreverses: Bool = false

    // MARK: Initializer
    internal init(duration: TimeInterval, curve: TimingCurve, owner: AnimationOwner = .unspecified, mainQueue: MainQueueProtocol = MainQueue()) {
        self.duration = duration
        self.owner = owner
        self.mainQueue = mainQueue
        self.unitBezier = UnitBezier(p1: curve.p1, p2: curve.p1)
    }

    deinit {
        if internalState != .initial {
            displayLink.remove(from: .main, forMode: .default)
        }
    }

    /// See ``BasicCameraAnimator/startAnimation()``
    internal func startAnimation() {
        switch internalState {
        case .initial:
            internalState = .running(CACurrentMediaTime())
            displayLink.add(to: .main, forMode: .default)
        case .running:
            // already running; do nothing
            break
        case let .paused(startTime):
            internalState = .running(startTime)
            displayLink.isPaused = false
        case .final:
            // animators cannot be restarted
            break
        }
    }

    /// See ``BasicCameraAnimator/startAnimation(afterDelay:)``
    internal func startAnimation(afterDelay delay: TimeInterval) {
        switch internalState {
        case .initial:
            internalState = .running(CACurrentMediaTime() + delay)
            displayLink.add(to: .main, forMode: .default)
        case .running:
            // already running; do nothing
            break
        case .paused:
            fatalError("A paused animator cannot be started with a delay.")
        case .final:
            // animators cannot be restarted
            break
        }
    }

    /// See ``BasicCameraAnimator/pauseAnimation()``
    internal func pauseAnimation() {
        switch internalState {
        case .initial:
            internalState = .paused(CACurrentMediaTime())
        case let .running(startTime):
            internalState = .paused(startTime)
            displayLink.isPaused = true
        case .paused:
            // already paused; do nothing
            break
        case .final:
            // already completed; do nothing
            break
        }
    }

    /// Stops the animation.
    internal func stopAnimation() {
        switch internalState {
        case .initial:
            internalState = .final(.current)
            for completion in completions {
                completion(.current)
            }

            completions.removeAll()
        case .running, .paused:
            internalState = .final(.current)
            displayLink.remove(from: .main, forMode: .default)
            completions.forEach { $0(.current) }
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
        case .running(let startTime):
            if pausesOnCompletion {
                internalState = .paused(startTime)
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

    internal func updateFromDisplayLink(_ displayLink: CADisplayLink) {
        switch internalState {
        case .initial, .paused, .final:
            return
        case let .running(startTimestamp):
            let targetTime = displayLink.targetTimestamp
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

        for animation in animations {
            animation(curvedProgress)
        }
    }
}
