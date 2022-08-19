import Foundation

internal protocol DisplayLinkCoordinator: AnyObject {
    // The coordinator must only keep weak references to participants
    func add(_ participant: DisplayLinkParticipant)
    // Removal is be based on object identity
    func remove(_ participant: DisplayLinkParticipant)
}

internal final class StandaloneDisplayLinkCoordinator: DisplayLinkCoordinator {
    private let displayLinkParticipants = WeakSet<DisplayLinkParticipant>()
    private lazy var displayLink: CADisplayLink = {
        let link = CADisplayLink(
            target: ForwardingDisplayLinkTarget { [weak self] in
                self?.updateFromDisplayLink($0)
            },
            selector: #selector(ForwardingDisplayLinkTarget.update(with:)))
        return link
    }()

    deinit {
        displayLink.remove(from: .main, forMode: .default)
    }

    init() {
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

    private func updateFromDisplayLink(_ displayLink: CADisplayLink) {
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
