@testable import MapboxMaps

final class MockDisplayLinkParticipant: NSObject, DisplayLinkParticipant {
    let participateStub = Stub<Void, Void>()
    func participate() {
        participateStub.call()
    }
}
