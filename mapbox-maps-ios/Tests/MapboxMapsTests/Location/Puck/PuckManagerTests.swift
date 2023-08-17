import XCTest
@testable import MapboxMaps

final class PuckManagerTests: XCTestCase {

    var puck2DProvider: Stub<Puck2DConfiguration, MockPuck2D>!
    var puck3DProvider: Stub<Puck3DConfiguration, MockPuck3D>!
    var puckManager: PuckManager!

    override func setUp() {
        super.setUp()
        puck2DProvider = Stub(defaultReturnValue: MockPuck2D())
        puck3DProvider = Stub(defaultReturnValue: MockPuck3D())
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
        XCTAssertEqual(puckManager.puckBearing, .heading)
        XCTAssertEqual(puckManager.puckBearingEnabled, true)
    }

    func testSetPuckTypeToPuck2D() throws {
        let configuration = Puck2DConfiguration()
        puckManager.puckBearing = [.heading, .course].randomElement()!
        puckManager.puckBearingEnabled = .random()
        puckManager.puckType = .puck2D(configuration)

        XCTAssertEqual(puck2DProvider.invocations.map(\.parameters), [configuration])
        let puck = try XCTUnwrap(puck2DProvider.invocations.first?.returnValue)
        XCTAssertEqual(puck.$puckBearing.setStub.invocations.map(\.parameters), [puckManager.puckBearing])
        XCTAssertEqual(puck.$puckBearingEnabled.setStub.invocations.map(\.parameters), [puckManager.puckBearingEnabled])
        XCTAssertEqual(puck.$isActive.setStub.invocations.map(\.parameters), [true])

        // setting the same should update only configuration
        var newConfiguration = Puck2DConfiguration()
        newConfiguration.opacity = 0.5
        puck2DProvider.reset()
        puck.$puckBearing.setStub.reset()
        puck.$puckBearingEnabled.setStub.reset()
        puck.$isActive.setStub.reset()
        puckManager.puckType = .puck2D(newConfiguration)
        XCTAssertTrue(puck2DProvider.invocations.isEmpty)
        XCTAssertTrue(puck.$puckBearing.setStub.invocations.isEmpty)
        XCTAssertTrue(puck.$puckBearingEnabled.setStub.invocations.isEmpty)
        XCTAssertTrue(puck.$isActive.setStub.invocations.isEmpty)
        XCTAssertEqual(puck.$configuration.setStub.invocations.count, 1)
        XCTAssertEqual(puck.$configuration.setStub.invocations.last?.parameters, newConfiguration)
    }

    func testSetPuckTypeToPuck3D() throws {
        let configuration = Puck3DConfiguration(model: Model())
        puckManager.puckBearing = [.heading, .course].randomElement()!
        puckManager.puckBearingEnabled = .random()
        puckManager.puckType = .puck3D(configuration)

        XCTAssertEqual(puck3DProvider.invocations.map(\.parameters), [configuration])
        let puck = try XCTUnwrap(puck3DProvider.invocations.first?.returnValue)
        XCTAssertEqual(puck.$puckBearing.setStub.invocations.map(\.parameters), [puckManager.puckBearing])
        XCTAssertEqual(puck.$puckBearingEnabled.setStub.invocations.map(\.parameters), [puckManager.puckBearingEnabled])
        XCTAssertEqual(puck.$isActive.setStub.invocations.map(\.parameters), [true])

        // setting the same should update only configuration
        let newConfiguration = Puck3DConfiguration(model: Model(uri: try XCTUnwrap(URL(string: "foo.bar"))))
        puck3DProvider.reset()
        puck.$puckBearing.setStub.reset()
        puck.$puckBearingEnabled.setStub.reset()
        puck.$isActive.setStub.reset()
        puckManager.puckType = .puck3D(newConfiguration)
        XCTAssertTrue(puck3DProvider.invocations.isEmpty)
        XCTAssertTrue(puck.$puckBearing.setStub.invocations.isEmpty)
        XCTAssertTrue(puck.$puckBearingEnabled.setStub.invocations.isEmpty)
        XCTAssertTrue(puck.$isActive.setStub.invocations.isEmpty)
        XCTAssertEqual(puck.$configuration.setStub.invocations.count, 1)
        XCTAssertEqual(puck.$configuration.setStub.invocations.last?.parameters, newConfiguration)
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
        let puck = MockPuck2D()
        puck2DProvider.defaultReturnValue = puck
        puckManager.puckType = .puck2D()
        puck2DProvider.reset()
        puck.$isActive.setStub.reset()

        puckManager.puckType = nil

        XCTAssertTrue(puck2DProvider.invocations.isEmpty)
        XCTAssertTrue(puck3DProvider.invocations.isEmpty)
        XCTAssertEqual(puck.$isActive.setStub.invocations.map(\.parameters), [false])
    }

    func testSettingPuckBearingWhenPuckTypeIsNonNil() {
        let puck2d = MockPuck2D()
        puck2DProvider.defaultReturnValue = puck2d
        puckManager.puckType = .puck2D()
        puck2d.$puckBearing.setStub.reset()
        let bearingSource: PuckBearing = [.heading, .course].randomElement()!

        puckManager.puckBearing = bearingSource

        XCTAssertEqual(puck2d.$puckBearing.setStub.invocations.map(\.parameters), [bearingSource])
    }

    func testSettingPuckBearingEnabledWhenPuckTypeIsNonNil() {
        let puck = MockPuck3D()
        puck3DProvider.defaultReturnValue = puck
        puckManager.puckType = .puck3D(.init(model: Model()))
        puck.$puckBearingEnabled.setStub.reset()

        let bearingEnable = Bool.random()
        puckManager.puckBearingEnabled = bearingEnable

        XCTAssertEqual(puck.$puckBearingEnabled.setStub.invocations.map(\.parameters), [bearingEnable])
    }
}
