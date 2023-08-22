@testable import MapboxMaps

final class MockDelegatingDisplayLinkParticipantDelegate: DelegatingDisplayLinkParticipantDelegate {
    let participateStub = Stub<DelegatingDisplayLinkParticipant, Void>()
    func participate(for participant: DelegatingDisplayLinkParticipant) {
        participateStub.call(with: participant)
    }
}
