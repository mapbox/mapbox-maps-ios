import XCTest
@testable import MapboxMaps

final class Puck3DTests: XCTestCase {

    var configuration: Puck3DConfiguration!
    var style: MockStyle!
    var locationProducer: MockLocationProducer!
    var puck3D: Puck3D!

    override func setUp() {
        super.setUp()
        configuration = Puck3DConfiguration(model: Model())
        style = MockStyle()
        locationProducer = MockLocationProducer()
        recreatePuck()
    }

    override func tearDown() {
        puck3D = nil
        locationProducer = nil
        style = nil
        configuration = nil
        super.tearDown()
    }

    func recreatePuck() {
        puck3D = Puck3D(
            configuration: configuration,
            style: style,
            locationProducer: locationProducer)
    }

    func testDefaultPropertyValues() {
        XCTAssertFalse(puck3D.isActive)
        XCTAssertEqual(puck3D.puckBearingSource, .heading)
    }

    func testLocationConsumerIsNotAddedAtInitialization() {
        XCTAssertEqual(locationProducer.addStub.invocations.count, 0)
        XCTAssertEqual(locationProducer.removeStub.invocations.count, 0)
    }

    func testActivatingPuckAddsLocationConsumer() {
        puck3D.isActive = true

        XCTAssertEqual(locationProducer.addStub.invocations.count, 1)
        XCTAssertTrue(locationProducer.addStub.parameters.first === puck3D)
        XCTAssertEqual(locationProducer.removeStub.invocations.count, 0)

        // activating again should have no effect
        puck3D.isActive = true

        XCTAssertEqual(locationProducer.addStub.invocations.count, 1)
        XCTAssertEqual(locationProducer.removeStub.invocations.count, 0)
    }

    func testDeactivatingPuckRemovesLocationConsumer() {
        puck3D.isActive = true
        locationProducer.addStub.reset()
        locationProducer.removeStub.reset()

        puck3D.isActive = false

        XCTAssertEqual(locationProducer.addStub.invocations.count, 0)
        XCTAssertEqual(locationProducer.removeStub.invocations.count, 1)
        XCTAssertTrue(locationProducer.removeStub.parameters.first === puck3D)

        // deactivating again should have no effect
        puck3D.isActive = false

        XCTAssertEqual(locationProducer.addStub.invocations.count, 0)
        XCTAssertEqual(locationProducer.removeStub.invocations.count, 1)
    }

    func testSourceAndLayerAreNotAddedAtInitialization() {
        XCTAssertEqual(style.addSourceStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
    }

    func testActivatingPuckDoesNotAddSourceAndLayerIfLatestLocationIsNil() {
        locationProducer.latestLocation = nil

        puck3D.isActive = true

        XCTAssertEqual(style.addSourceStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
    }

    func testActivatingPuckAddsSourceAndLayerIfLatestLocationIsNonNil() throws {
        let coordinate = CLLocationCoordinate2D.random()
        locationProducer.latestLocation = Location(
            location: CLLocation(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude),
            heading: nil,
            accuracyAuthorization: .fullAccuracy)
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
        let location = CLLocation(
            coordinate: .random(),
            altitude: 0,
            horizontalAccuracy: 0,
            verticalAccuracy: 0,
            course: .random(in: 0..<360),
            speed: 0,
            timestamp: Date())
        let heading = MockHeading()
        heading.trueHeadingStub.defaultReturnValue = .random(in: 0..<360)
        locationProducer.latestLocation = Location(
            location: location,
            heading: heading,
            accuracyAuthorization: .fullAccuracy)
        style.sourceExistsStub.defaultReturnValue = false
        puck3D.puckBearingSource = .heading

        puck3D.isActive = true

        var expectedOrientation = configuration.model.orientation!
        expectedOrientation[2] += heading.trueHeadingStub.defaultReturnValue
        let actualSource = try XCTUnwrap(style.addSourceStub.parameters.first?.source as? ModelSource)
        XCTAssertEqual(actualSource.models?["puck-model"]?.orientation, expectedOrientation)
    }

    func testModelOrientationBasedOnCourse() throws {
        configuration.model.orientation = [
            .random(in: 0..<360),
            .random(in: 0..<360),
            .random(in: 0..<360)]
        recreatePuck()
        let location = CLLocation(
            coordinate: .random(),
            altitude: 0,
            horizontalAccuracy: 0,
            verticalAccuracy: 0,
            course: .random(in: 0..<360),
            speed: 0,
            timestamp: Date())
        let heading = MockHeading()
        heading.trueHeadingStub.defaultReturnValue = .random(in: 0..<360)
        locationProducer.latestLocation = Location(
            location: location,
            heading: heading,
            accuracyAuthorization: .fullAccuracy)
        style.sourceExistsStub.defaultReturnValue = false
        puck3D.puckBearingSource = .course

        puck3D.isActive = true

        var expectedOrientation = configuration.model.orientation!
        expectedOrientation[2] += location.course
        let actualSource = try XCTUnwrap(style.addSourceStub.parameters.first?.source as? ModelSource)
        XCTAssertEqual(actualSource.models?["puck-model"]?.orientation, expectedOrientation)
    }

    func testModelScaleAndRotation() throws {
        configuration.modelScale = .constant(.random(withLength: 3, generator: { .random(in: 1..<10) }))
        configuration.modelRotation = .constant(.random(withLength: 3, generator: { .random(in: 0..<360) }))
        recreatePuck()
        locationProducer.latestLocation = Location(
            location: CLLocation(),
            heading: nil,
            accuracyAuthorization: .fullAccuracy)
        style.layerExistsStub.defaultReturnValue = false

        puck3D.isActive = true

        let actualLayer = try XCTUnwrap(style.addPersistentLayerStub.parameters.first?.layer as? ModelLayer)
        XCTAssertEqual(actualLayer.paint?.modelScale, configuration.modelScale)
        XCTAssertEqual(actualLayer.paint?.modelRotation, configuration.modelRotation)
    }

    func testUpdateExistingSource() throws {
        let coordinate = CLLocationCoordinate2D.random()
        locationProducer.latestLocation = Location(
            location: CLLocation(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude),
            heading: nil,
            accuracyAuthorization: .fullAccuracy)
        style.sourceExistsStub.defaultReturnValue = true
        style.layerExistsStub.defaultReturnValue = true

        puck3D.isActive = true

        var expectedModel = configuration.model
        expectedModel.position = [coordinate.longitude, coordinate.latitude]
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
        locationProducer.latestLocation = Location(
            location: CLLocation(),
            heading: nil,
            accuracyAuthorization: .fullAccuracy)
        style.sourceExistsStub.defaultReturnValue = false
        style.layerExistsStub.defaultReturnValue = false
        puck3D.isActive = false

        puck3D.puckBearingSource = [.heading, .course].randomElement()!

        XCTAssertEqual(style.addSourceStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
    }

    func testSettingPuckBearingSourceWhenActive() {
        locationProducer.latestLocation = Location(
            location: CLLocation(),
            heading: nil,
            accuracyAuthorization: .fullAccuracy)
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

    func testLocationUpdateWhenInactive() {
        locationProducer.latestLocation = Location(
            location: CLLocation(),
            heading: nil,
            accuracyAuthorization: .fullAccuracy)
        style.sourceExistsStub.defaultReturnValue = false
        style.layerExistsStub.defaultReturnValue = false
        puck3D.isActive = false

        puck3D.locationUpdate(newLocation: locationProducer.latestLocation!)

        XCTAssertEqual(style.addSourceStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
    }

    func testLocationUpdateWhenActive() {
        locationProducer.latestLocation = Location(
            location: CLLocation(),
            heading: nil,
            accuracyAuthorization: .fullAccuracy)
        puck3D.isActive = true
        style.sourceExistsStub.defaultReturnValue = true
        style.layerExistsStub.defaultReturnValue = true
        style.addSourceStub.reset()
        style.setSourcePropertiesStub.reset()
        style.addPersistentLayerStub.reset()

        puck3D.locationUpdate(newLocation: locationProducer.latestLocation!)

        XCTAssertEqual(style.addSourceStub.invocations.count, 0)
        XCTAssertEqual(style.setSourcePropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
    }
}
