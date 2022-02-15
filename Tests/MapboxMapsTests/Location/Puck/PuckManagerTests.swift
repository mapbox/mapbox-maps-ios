import XCTest
@testable import MapboxMaps

final class PuckManagerTests: XCTestCase {

    var puck2DProvider: Stub<Puck2DConfiguration, MockPuck>!
    var puck3DProvider: Stub<Puck3DConfiguration, MockPuck>!
    var puckManager: PuckManager!

    override func setUp() {
        super.setUp()
        puck2DProvider = Stub(defaultReturnValue: MockPuck())
        puck3DProvider = Stub(defaultReturnValue: MockPuck())
        puckManager = PuckManager(
            puck2DProvider: puck2DProvider.call(with:),
            puck3DProvider: puck3DProvider.call(with:))
    }

    override func tearDown() {
        puckManager = nil
        puck3DProvider = nil
        puck2DProvider = nil
        super.tearDown()
    }

    func testInitialPropertyValues() {
        XCTAssertNil(puckManager.puckType)
        XCTAssertEqual(puckManager.puckBearingSource, .heading)
        XCTAssertEqual(puckManager.puckBearingEnabled, true)
    }

    func testSetPuckTypeToPuck2D() throws {
        let configuration = Puck2DConfiguration()
        puckManager.puckBearingSource = [.heading, .course].randomElement()!
        puckManager.puckBearingEnabled = .random()
        puckManager.puckType = .puck2D(configuration)

        XCTAssertEqual(puck2DProvider.parameters, [configuration])
        let puck = try XCTUnwrap(puck2DProvider.returnedValues.first)
        XCTAssertEqual(puck.$puckBearingSource.setStub.parameters, [puckManager.puckBearingSource])
        XCTAssertEqual(puck.$puckBearingEnabled.setStub.parameters, [puckManager.puckBearingEnabled])
        XCTAssertEqual(puck.$isActive.setStub.parameters, [true])

        // setting the same puck again should have no further effect
        puck2DProvider.reset()
        puck.$puckBearingSource.setStub.reset()
        puck.$puckBearingEnabled.setStub.reset()
        puck.$isActive.setStub.reset()
        puckManager.puckType = .puck2D(configuration)
        XCTAssertTrue(puck2DProvider.invocations.isEmpty)
        XCTAssertTrue(puck.$puckBearingSource.setStub.invocations.isEmpty)
        XCTAssertTrue(puck.$puckBearingEnabled.setStub.invocations.isEmpty)
        XCTAssertTrue(puck.$isActive.setStub.invocations.isEmpty)
    }

    func testSetPuckTypeToPuck3D() throws {
        let configuration = Puck3DConfiguration(model: Model())
        puckManager.puckBearingSource = [.heading, .course].randomElement()!
        puckManager.puckBearingEnabled = .random()
        puckManager.puckType = .puck3D(configuration)

        XCTAssertEqual(puck3DProvider.parameters, [configuration])
        let puck = try XCTUnwrap(puck3DProvider.returnedValues.first)
        XCTAssertEqual(puck.$puckBearingSource.setStub.parameters, [puckManager.puckBearingSource])
        XCTAssertEqual(puck.$puckBearingEnabled.setStub.parameters, [puckManager.puckBearingEnabled])
        XCTAssertEqual(puck.$isActive.setStub.parameters, [true])

        // setting the same puck again should have no further effect
        puck3DProvider.reset()
        puck.$puckBearingSource.setStub.reset()
        puck.$puckBearingEnabled.setStub.reset()
        puck.$isActive.setStub.reset()
        puckManager.puckType = .puck3D(configuration)
        XCTAssertTrue(puck3DProvider.invocations.isEmpty)
        XCTAssertTrue(puck.$puckBearingSource.setStub.invocations.isEmpty)
        XCTAssertTrue(puck.$puckBearingEnabled.setStub.invocations.isEmpty)
        XCTAssertTrue(puck.$isActive.setStub.invocations.isEmpty)
    }

    // this is important so that if they're the same type of puck,
    // the one getting deactivated doesn't remove the layer/source
    // that the one getting activated added
    func testOldPuckIsDeactivatedBeforeNewPuckIsActivated() throws {
        var oldPuckDeactivated = false
        puck2DProvider.defaultReturnValue.$isActive.setStub.defaultSideEffect = { invocation in
            if !invocation.parameters {
                oldPuckDeactivated = true
            }
        }
        var oldPuckDeactivatedBeforeNewPuckActivated = false
        puck3DProvider.defaultReturnValue.$isActive.setStub.defaultSideEffect = { invocation in
            if invocation.parameters {
                oldPuckDeactivatedBeforeNewPuckActivated = oldPuckDeactivated
            }
        }

        puckManager.puckType = .puck2D()

        puckManager.puckType = .puck3D(Puck3DConfiguration(model: Model()))

        XCTAssertTrue(oldPuckDeactivatedBeforeNewPuckActivated)
    }

    func testResettingPuckTypeToNil() {
        let puck = MockPuck()
        puck2DProvider.defaultReturnValue = puck
        puckManager.puckType = .puck2D()
        puck2DProvider.reset()
        puck.$isActive.setStub.reset()

        puckManager.puckType = nil

        XCTAssertTrue(puck2DProvider.invocations.isEmpty)
        XCTAssertTrue(puck3DProvider.invocations.isEmpty)
        XCTAssertEqual(puck.$isActive.setStub.parameters, [false])
    }

    func testSettingPuckBearingSourceWhenPuckTypeIsNonNil() {
        let puck = MockPuck()
        puck2DProvider.defaultReturnValue = puck
        puck3DProvider.defaultReturnValue = puck
        puckManager.puckType = [.puck2D(), .puck3D(.init(model: Model()))].randomElement()!
        puck.$puckBearingSource.setStub.reset()
        let bearingSource: PuckBearingSource = [.heading, .course].randomElement()!

        puckManager.puckBearingSource = bearingSource

        XCTAssertEqual(puck.$puckBearingSource.setStub.parameters, [bearingSource])
    }

    func testSettingPuckBearingEnabledWhenPuckTypeIsNonNil() {
        let puck = MockPuck()
        puck2DProvider.defaultReturnValue = puck
        puck3DProvider.defaultReturnValue = puck
        puckManager.puckType = [.puck2D(), .puck3D(.init(model: Model()))].randomElement()!
        puck.$puckBearingEnabled.setStub.reset()

        let bearingEnable = Bool.random()
        puckManager.puckBearingEnabled = bearingEnable

        XCTAssertEqual(puck.$puckBearingEnabled.setStub.parameters, [bearingEnable])
    }
}
