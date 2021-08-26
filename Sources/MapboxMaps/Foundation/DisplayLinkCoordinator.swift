import Foundation

internal protocol DisplayLinkCoordinator: AnyObject {
    // The coordinator must only keep weak references to participants
    func add(_ participant: DisplayLinkParticipant)
    // Removal is be based on object identity
    func remove(_ participant: DisplayLinkParticipant)
}

// The participants must be NSObjects so that the DisplayLinkCoordinator implementation can use WeakSet
internal protocol DisplayLinkParticipant: NSObject {
    func participate()
}
