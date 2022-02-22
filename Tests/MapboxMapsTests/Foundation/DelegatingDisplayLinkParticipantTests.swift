import XCTest
@testable import MapboxMaps

final class DelegatingDisplayLinkParticipantTests: XCTestCase {

    func testDelegatesParticipateInvocation() {
        let delegate = MockDelegatingDisplayLinkParticipantDelegate()
        let delegatingParticipant = DelegatingDisplayLinkParticipant()
        delegatingParticipant.delegate = delegate

        delegatingParticipant.participate()

        assertMethodCall(delegate.participateStub)
        XCTAssertTrue(delegate.participateStub.parameters.first === delegatingParticipant)
    }
}
