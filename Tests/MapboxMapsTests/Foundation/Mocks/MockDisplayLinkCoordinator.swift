@testable import MapboxMaps

final class MockDisplayLinkCoordinator: DisplayLinkCoordinator {
    let addStub = Stub<DisplayLinkParticipant, Void>()
    func add(_ participant: DisplayLinkParticipant) {
        addStub.call(with: participant)
    }

    let removeStub = Stub<DisplayLinkParticipant, Void>()
    func remove(_ participant: DisplayLinkParticipant) {
        removeStub.call(with: participant)
    }
}
