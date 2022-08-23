import XCTest
@testable import MapboxMaps

final class StandaloneDisplayLinkCoordinatorTests: XCTestCase {
    var displayLink: MockDisplayLink!
    var displayLinkTarget: DelegatingDisplayLinkTarget!
    var coordinator: StandaloneDisplayLinkCoordinator!

    override func setUpWithError() throws {
        try super.setUpWithError()

        displayLink = MockDisplayLink()
        displayLinkTarget = DelegatingDisplayLinkTarget()
        coordinator = StandaloneDisplayLinkCoordinator(displayLink: displayLink, target: displayLinkTarget)
    }

    override func tearDown() {
        displayLink = nil
        displayLinkTarget = nil
        coordinator = nil

        super.tearDown()
    }

    func testInitPausesDisplayLinkAndAddsItToRunloop() {
        XCTAssertTrue(displayLink.isPaused)
        XCTAssertEqual(displayLink.addStub.invocations.count, 1)
        XCTAssertEqual(displayLink.addStub.invocations.first?.parameters.runloop, .main)
        XCTAssertEqual(displayLink.addStub.invocations.first?.parameters.mode, .default)
        XCTAssertIdentical(displayLinkTarget.delegate, coordinator)
    }

    func testAddParticipantResumesDisplayLink() {
        // given
        displayLink.$isPaused.reset()

        // when
        coordinator.add(MockDisplayLinkParticipant())

        XCTAssertEqual(displayLink.$isPaused.setStub.invocations.count, 1)
        XCTAssertEqual(displayLink.$isPaused.setStub.invocations.first?.parameters, false)
    }

    func testRemoveEmptyParticipantsPauseDisplayLink() {
        // given
        displayLink.$isPaused.reset()

        // given
        let participant = MockDisplayLinkParticipant()
        coordinator.add(participant)

        // when
        coordinator.remove(participant)

        XCTAssertEqual(displayLink.$isPaused.setStub.invocations.count, 2)
        XCTAssertEqual(displayLink.$isPaused.setStub.invocations.last?.parameters, true)
    }

    func testDisplayLinkInvokesParticipants() throws {
        let participant1 = MockDisplayLinkParticipant()
        let participant2 = MockDisplayLinkParticipant()
        let timestamp1 = Double.random(in: 0...100)
        let timestamp2 = Double.random(in: 0...100)
        let timestamp3 = Double.random(in: 0...100)

        coordinator.add(participant1)

        displayLink.targetTimestamp = timestamp1
        coordinator.delegatingTargetDisplayLinkDidUpdate(displayLink)

        XCTAssertEqual(participant1.participateStub.invocations.count, 1)
        XCTAssertEqual(participant1.participateStub.invocations.first?.parameters, timestamp1)
        XCTAssertEqual(participant2.participateStub.invocations.count, 0)

        coordinator.add(participant2)

        displayLink.targetTimestamp = timestamp2
        coordinator.delegatingTargetDisplayLinkDidUpdate(displayLink)

        XCTAssertEqual(participant1.participateStub.invocations.count, 2)
        XCTAssertEqual(participant1.participateStub.invocations.last?.parameters, timestamp2)
        XCTAssertEqual(participant2.participateStub.invocations.count, 1)
        XCTAssertEqual(participant2.participateStub.invocations.first?.parameters, timestamp2)

        coordinator.remove(participant2)

        displayLink.targetTimestamp = timestamp3
        coordinator.delegatingTargetDisplayLinkDidUpdate(displayLink)

        XCTAssertEqual(participant1.participateStub.invocations.count, 3)
        XCTAssertEqual(participant1.participateStub.invocations.last?.parameters, timestamp3)
        XCTAssertEqual(participant2.participateStub.invocations.count, 1)

        coordinator.remove(participant1)

        coordinator.delegatingTargetDisplayLinkDidUpdate(displayLink)

        XCTAssertEqual(participant1.participateStub.invocations.count, 3)
        XCTAssertEqual(participant2.participateStub.invocations.count, 1)
    }

    func testDisplayLinkInvalidateOnDeinit() {
        coordinator = nil

        XCTAssertEqual(displayLink.invalidateStub.invocations.count, 1)
    }
}

final class ProxyingDisplayLinkCoordinatorTests: XCTestCase {

    var coordinator: ProxyingDisplayLinkCoordinator!

    override func setUpWithError() throws {
        try super.setUpWithError()

        coordinator = ProxyingDisplayLinkCoordinator()
    }

    override func tearDown() {
        coordinator = nil

        super.tearDown()
    }

    func testDisplayLinkInvokesParticipants() throws {
        let participant1 = MockDisplayLinkParticipant()
        let participant2 = MockDisplayLinkParticipant()
        let timestamp1 = Double.random(in: 0...100)
        let timestamp2 = Double.random(in: 0...100)
        let timestamp3 = Double.random(in: 0...100)

        coordinator.add(participant1)

        coordinator.notify(with: timestamp1)

        XCTAssertEqual(participant1.participateStub.invocations.count, 1)
        XCTAssertEqual(participant1.participateStub.invocations.first?.parameters, timestamp1)
        XCTAssertEqual(participant2.participateStub.invocations.count, 0)

        coordinator.add(participant2)

        coordinator.notify(with: timestamp2)

        XCTAssertEqual(participant1.participateStub.invocations.count, 2)
        XCTAssertEqual(participant1.participateStub.invocations.last?.parameters, timestamp2)
        XCTAssertEqual(participant2.participateStub.invocations.count, 1)
        XCTAssertEqual(participant2.participateStub.invocations.first?.parameters, timestamp2)

        coordinator.remove(participant2)

        coordinator.notify(with: timestamp3)

        XCTAssertEqual(participant1.participateStub.invocations.count, 3)
        XCTAssertEqual(participant1.participateStub.invocations.last?.parameters, timestamp3)
        XCTAssertEqual(participant2.participateStub.invocations.count, 1)

        coordinator.remove(participant1)

        coordinator.notify(with: .random(in: 0...100))

        XCTAssertEqual(participant1.participateStub.invocations.count, 3)
        XCTAssertEqual(participant2.participateStub.invocations.count, 1)
    }
}
