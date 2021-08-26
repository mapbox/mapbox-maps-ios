import XCTest
@testable import MapboxMaps

final class DelegatingDisplayLinkParticipantTests: XCTestCase {

    func testDelegatesParticipateInvocation() {
        let delegate = MockDelegatingDisplayLinkParticipantDelegate()
        let delegatingParticipant = DelegatingDisplayLinkParticipant()
        delegatingParticipant.delegate = delegate

        delegatingParticipant.participate()

        XCTAssertEqual(delegate.participateStub.invocations.count, 1)
        XCTAssertTrue(delegate.participateStub.parameters.first === delegatingParticipant)
    }
}
