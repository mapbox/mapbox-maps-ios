import Foundation
import QuartzCore

internal protocol DisplayLinkCoordinator: AnyObject {
    // The coordinator must only keep weak references to participants
    func add(_ participant: DisplayLinkParticipant)
    // Removal is be based on object identity
    func remove(_ participant: DisplayLinkParticipant)
}

internal final class StandaloneDisplayLinkCoordinator: DisplayLinkCoordinator, DelegatingDisplayLinkTargetDelegate {
    private let displayLinkParticipants = WeakSet<DisplayLinkParticipant>()
    private let displayLink: DisplayLinkProtocol

    deinit {
        displayLink.invalidate()
    }

    internal convenience init() {
        let displayLinkTarget = DelegatingDisplayLinkTarget()
        let link = CADisplayLink(
            target: displayLinkTarget,
            selector: #selector(DelegatingDisplayLinkTarget.update(with:)))
        self.init(displayLink: link, target: displayLinkTarget)
    }

    internal init(displayLink: DisplayLinkProtocol, target: DelegatingDisplayLinkTarget) {
        self.displayLink = displayLink
        target.delegate = self
        displayLink.isPaused = true
        displayLink.add(to: .main, forMode: .default)
    }

    internal func add(_ participant: DisplayLinkParticipant) {
        displayLinkParticipants.add(participant)

        displayLink.isPaused = false
    }

    internal func remove(_ participant: DisplayLinkParticipant) {
        displayLinkParticipants.remove(participant)

        if displayLinkParticipants.allObjects.isEmpty {
            displayLink.isPaused = true
        }
    }

    internal func delegatingTargetDisplayLinkDidUpdate(_ displayLink: DisplayLinkProtocol) {
        for participant in displayLinkParticipants.allObjects {
            participant.participate(targetTimestamp: displayLink.targetTimestamp)
        }
    }
}

internal final class ProxyingDisplayLinkCoordinator: DisplayLinkCoordinator {
    private let displayLinkParticipants = WeakSet<DisplayLinkParticipant>()

    internal func notify(with targetTimestamp: CFTimeInterval) {
        for participant in displayLinkParticipants.allObjects {
            participant.participate(targetTimestamp: targetTimestamp)
        }
    }

    internal func add(_ participant: DisplayLinkParticipant) {
        displayLinkParticipants.add(participant)
    }

    internal func remove(_ participant: DisplayLinkParticipant) {
        displayLinkParticipants.remove(participant)
    }
}

// The participants must be AnyObjects so that the DisplayLinkCoordinator implementation can use WeakSet
internal protocol DisplayLinkParticipant: AnyObject {
    func participate(targetTimestamp: CFTimeInterval)
}
