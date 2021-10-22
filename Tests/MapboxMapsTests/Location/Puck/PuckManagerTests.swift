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
        XCTAssertEqual(puckManager.puckAccuracy, .full)
        XCTAssertEqual(puckManager.puckBearingSource, .heading)
    }

    func testSetPuckTypeToPuck2D() throws {
        let configuration = Puck2DConfiguration()
        puck2DProvider.defaultReturnValue.isActive = false
        puckManager.puckAccuracy = [.full, .reduced].randomElement()!
        puckManager.puckBearingSource = [.heading, .course].randomElement()!

        puckManager.puckType = .puck2D(configuration)

        XCTAssertEqual(puck2DProvider.parameters, [configuration])
        let puck = try XCTUnwrap(puck2DProvider.returnedValues.first)
        XCTAssertEqual(puck.setPuckAccuracyStub.parameters, [puckManager.puckAccuracy])
        XCTAssertEqual(puck.setPuckBearingSourceStub.parameters, [puckManager.puckBearingSource])
        XCTAssertTrue(puck.isActive)

        // setting the same puck again should have no further effect
        puck2DProvider.reset()
        puckManager.puckType = .puck2D(configuration)
        XCTAssertTrue(puck2DProvider.invocations.isEmpty)
    }

    func testSetPuckTypeToPuck3D() throws {
        let configuration = Puck3DConfiguration(model: Model())
        puck3DProvider.defaultReturnValue.isActive = false
        puckManager.puckAccuracy = [.full, .reduced].randomElement()!
        puckManager.puckBearingSource = [.heading, .course].randomElement()!

        puckManager.puckType = .puck3D(configuration)

        XCTAssertEqual(puck3DProvider.parameters, [configuration])
        let puck = try XCTUnwrap(puck3DProvider.returnedValues.first)
        XCTAssertEqual(puck.setPuckAccuracyStub.parameters, [puckManager.puckAccuracy])
        XCTAssertEqual(puck.setPuckBearingSourceStub.parameters, [puckManager.puckBearingSource])
        XCTAssertTrue(puck.isActive)

        // setting the same puck again should have no further effect
        puck3DProvider.reset()
        puckManager.puckType = .puck3D(configuration)
        XCTAssertTrue(puck3DProvider.invocations.isEmpty)
    }

    func testOldPuckIsDeactivatedBeforeNewPuckIsActivated() throws {

    }

    func testResettingPuckTypeToNil() {

    }

    func testSettingPuckAccuracyWhenPuckTypeIsNonNil() {

    }

    func testSettingPuckBearingSourceWhenPuckTypeIsNonNil() {

    }
}
