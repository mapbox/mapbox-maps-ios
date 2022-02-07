import XCTest
@testable import MapboxMaps

final class Puck3DTests: XCTestCase {

    var configuration: Puck3DConfiguration!
    var style: MockStyle!
    var interpolatedLocationProducer: MockInterpolatedLocationProducer!
    var puck3D: Puck3D!

    override func setUp() {
        super.setUp()
        configuration = Puck3DConfiguration(model: Model())
        style = MockStyle()
        interpolatedLocationProducer = MockInterpolatedLocationProducer()
        recreatePuck()
    }

    override func tearDown() {
        puck3D = nil
        interpolatedLocationProducer = nil
        style = nil
        configuration = nil
        super.tearDown()
    }

    func recreatePuck() {
        puck3D = Puck3D(
            configuration: configuration,
            style: style,
            interpolatedLocationProducer: interpolatedLocationProducer)
    }

    func testDefaultPropertyValues() {
        XCTAssertFalse(puck3D.isActive)
        XCTAssertEqual(puck3D.puckBearingSource, .heading)
    }

    func testLocationConsumerIsNotAddedAtInitialization() {
        XCTAssertEqual(interpolatedLocationProducer.observeStub.invocations.count, 0)
    }

    func testActivatingPuckAddsLocationConsumer() throws {
        puck3D.isActive = true

        XCTAssertEqual(interpolatedLocationProducer.observeStub.invocations.count, 1)
        let cancelable = try XCTUnwrap(interpolatedLocationProducer.observeStub.invocations.first?.returnValue as? MockCancelable)
        XCTAssertEqual(cancelable.cancelStub.invocations.count, 0)

        // activating again should have no effect
        puck3D.isActive = true

        XCTAssertEqual(interpolatedLocationProducer.observeStub.invocations.count, 1)
        XCTAssertEqual(cancelable.cancelStub.invocations.count, 0)
    }

    func testDeactivatingPuckRemovesLocationConsumer() throws {
        puck3D.isActive = true
        let cancelable = try XCTUnwrap(interpolatedLocationProducer.observeStub.invocations.first?.returnValue as? MockCancelable)
        interpolatedLocationProducer.observeStub.reset()

        puck3D.isActive = false

        XCTAssertEqual(interpolatedLocationProducer.observeStub.invocations.count, 0)
        XCTAssertEqual(cancelable.cancelStub.invocations.count, 1)

        // deactivating again should have no effect
        puck3D.isActive = false

        XCTAssertEqual(interpolatedLocationProducer.observeStub.invocations.count, 0)
        XCTAssertEqual(cancelable.cancelStub.invocations.count, 1)
    }

    func testSourceAndLayerAreNotAddedAtInitialization() {
        XCTAssertEqual(style.addSourceStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
    }

    func testActivatingPuckDoesNotAddSourceAndLayerIfLatestLocationIsNil() {
        interpolatedLocationProducer.location = nil

        puck3D.isActive = true

        XCTAssertEqual(style.addSourceStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
    }

    func testActivatingPuckAddsSourceAndLayerIfLatestLocationIsNonNil() throws {
        let coordinate = CLLocationCoordinate2D.random()
        var location = InterpolatedLocation.random()
        location.coordinate = coordinate
        location.heading = nil
        interpolatedLocationProducer.location = location
        style.sourceExistsStub.defaultReturnValue = false
        style.layerExistsStub.defaultReturnValue = false

        puck3D.isActive = true

        var expectedModel = configuration.model
        expectedModel.position = [coordinate.longitude, coordinate.latitude]
        expectedModel.orientation = [0, 0, 0]
        XCTAssertEqual(style.addSourceStub.invocations.count, 1)
        let actualSource = try XCTUnwrap(style.addSourceStub.parameters.first?.source as? ModelSource)
        XCTAssertEqual(actualSource.type, .model)
        XCTAssertEqual(actualSource.models, ["puck-model": expectedModel])
        XCTAssertEqual(style.addSourceStub.parameters.first?.id, "puck-model-source")

        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 1)
        let actualLayer = try XCTUnwrap(style.addPersistentLayerStub.parameters.first?.layer as? ModelLayer)
        XCTAssertEqual(actualLayer.id, "puck-model-layer")
        XCTAssertEqual(actualLayer.paint?.modelLayerType, .constant(.locationIndicator))
        XCTAssertEqual(actualLayer.source, "puck-model-source")
        XCTAssertEqual(style.addPersistentLayerStub.parameters.first?.layerPosition, nil)
    }

    func testModelOrientationBasedOnHeading() throws {
        configuration.model.orientation = [
            .random(in: 0..<360),
            .random(in: 0..<360),
            .random(in: 0..<360)]
        recreatePuck()
        let heading = CLLocationDirection.random(in: 0..<360)
        var location = InterpolatedLocation.random()
        location.heading = heading
        interpolatedLocationProducer.location = location
        style.sourceExistsStub.defaultReturnValue = false
        puck3D.puckBearingSource = .heading

        puck3D.isActive = true

        var expectedOrientation = configuration.model.orientation!
        expectedOrientation[2] += heading
        let actualSource = try XCTUnwrap(style.addSourceStub.parameters.first?.source as? ModelSource)
        XCTAssertEqual(actualSource.models?["puck-model"]?.orientation, expectedOrientation)
    }

    func testModelOrientationBasedOnCourse() throws {
        configuration.model.orientation = [
            .random(in: 0..<360),
            .random(in: 0..<360),
            .random(in: 0..<360)]
        recreatePuck()
        var location = InterpolatedLocation.random()
        location.course = .random(in: 0..<360)
        interpolatedLocationProducer.location = location
        style.sourceExistsStub.defaultReturnValue = false
        puck3D.puckBearingSource = .course

        puck3D.isActive = true

        var expectedOrientation = configuration.model.orientation!
        expectedOrientation[2] += location.course!
        let actualSource = try XCTUnwrap(style.addSourceStub.parameters.first?.source as? ModelSource)
        XCTAssertEqual(actualSource.models?["puck-model"]?.orientation, expectedOrientation)
    }

    func testModelScaleAndRotation() throws {
        configuration.modelScale = .constant(.random(withLength: 3, generator: { .random(in: 1..<10) }))
        configuration.modelRotation = .constant(.random(withLength: 3, generator: { .random(in: 0..<360) }))
        recreatePuck()
        interpolatedLocationProducer.location = .random()
        style.layerExistsStub.defaultReturnValue = false

        puck3D.isActive = true

        let actualLayer = try XCTUnwrap(style.addPersistentLayerStub.parameters.first?.layer as? ModelLayer)
        XCTAssertEqual(actualLayer.paint?.modelScale, configuration.modelScale)
        XCTAssertEqual(actualLayer.paint?.modelRotation, configuration.modelRotation)
    }

    func testUpdateExistingSource() throws {
        var location = InterpolatedLocation.random()
        location.heading = nil
        interpolatedLocationProducer.location = location
        style.sourceExistsStub.defaultReturnValue = true
        style.layerExistsStub.defaultReturnValue = true

        puck3D.isActive = true

        var expectedModel = configuration.model
        expectedModel.position = [
            location.coordinate.longitude,
            location.coordinate.latitude]
        expectedModel.orientation = [0, 0, 0]
        var expectedSource = ModelSource()
        expectedSource.models = ["puck-model": expectedModel]
        XCTAssertEqual(style.addSourceStub.invocations.count, 0)
        XCTAssertEqual(style.setSourcePropertiesStub.invocations.count, 1)
        let actualProperties = try XCTUnwrap(style.setSourcePropertiesStub.parameters.first?.properties)
        let expectedProperties = try expectedSource.jsonObject()
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
        XCTAssertEqual(style.setSourcePropertiesStub.parameters.first?.sourceId, "puck-model-source")

        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 0)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 0)
    }

    func testSettingPuckBearingSourceWhenInactive() {
        interpolatedLocationProducer.location = .random()
        style.sourceExistsStub.defaultReturnValue = false
        style.layerExistsStub.defaultReturnValue = false
        puck3D.isActive = false

        puck3D.puckBearingSource = [.heading, .course].randomElement()!

        XCTAssertEqual(style.addSourceStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
    }

    func testSettingPuckBearingSourceWhenActive() {
        interpolatedLocationProducer.location = .random()
        puck3D.isActive = true
        style.sourceExistsStub.defaultReturnValue = true
        style.layerExistsStub.defaultReturnValue = true
        style.addSourceStub.reset()
        style.setSourcePropertiesStub.reset()
        style.addPersistentLayerStub.reset()

        puck3D.puckBearingSource = [.heading, .course].randomElement()!

        XCTAssertEqual(style.addSourceStub.invocations.count, 0)
        XCTAssertEqual(style.setSourcePropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
    }

    func testLocationUpdateWhenActive() throws {
        interpolatedLocationProducer.location = .random()
        puck3D.isActive = true
        style.sourceExistsStub.defaultReturnValue = true
        style.layerExistsStub.defaultReturnValue = true
        style.addSourceStub.reset()
        style.setSourcePropertiesStub.reset()
        style.addPersistentLayerStub.reset()
        let handler = try XCTUnwrap(interpolatedLocationProducer.observeStub.invocations.first?.parameters)

        let wantsMoreUpdates = handler(interpolatedLocationProducer.location!)

        XCTAssertTrue(wantsMoreUpdates)
        XCTAssertEqual(style.addSourceStub.invocations.count, 0)
        XCTAssertEqual(style.setSourcePropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
    }
}
