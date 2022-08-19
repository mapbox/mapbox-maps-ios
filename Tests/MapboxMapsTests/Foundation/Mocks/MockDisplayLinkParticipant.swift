@testable import MapboxMaps

final class MockDisplayLinkParticipant: NSObject, DisplayLinkParticipant {
    let participateStub = Stub<CFTimeInterval, Void>()
    func participate(targetTimestamp: CFTimeInterval) {
        participateStub.call(with: targetTimestamp)
    }
}
