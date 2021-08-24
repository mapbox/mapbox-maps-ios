import Foundation

internal protocol DisplayLinkCoordinator: AnyObject {
    // The coordinator would only keep weak references to participants
    func add(_ participant: DisplayLinkParticipant)
    // Removal would be based on object identity
    func remove(_ participant: DisplayLinkParticipant)
}

// The participants would need to be NSObjects so that the DisplayLinkCoordinator implementation can use WeakSet
internal protocol DisplayLinkParticipant: NSObject {
    func participate()
}
