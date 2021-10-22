import XCTest
@testable import MapboxMaps

final class Puck3DTests: XCTestCase {

    var configuration: Puck3DConfiguration!
    var style: MockStyle!
    var locationSource: MockLocationSource!
    var puck3D: Puck3D!

    override func setUp() {
        super.setUp()
        configuration = Puck3DConfiguration(model: Model())
        style = MockStyle()
        locationSource = MockLocationSource()
        recreatePuck()
    }

    override func tearDown() {
        puck3D = nil
        locationSource = nil
        style = nil
        configuration = nil
        super.tearDown()
    }

    func recreatePuck() {
        puck3D = Puck3D(
            configuration: configuration,
            style: style,
            locationSource: locationSource)
    }

    func testDefaultPropertyValues() {
        XCTAssertFalse(puck3D.isActive)
        XCTAssertEqual(puck3D.puckAccuracy, .full)
        XCTAssertEqual(puck3D.puckBearingSource, .heading)
    }

    func testLocationConsumerIsNotAddedAtInitialization() {
        XCTAssertEqual(locationSource.addStub.invocations.count, 0)
        XCTAssertEqual(locationSource.removeStub.invocations.count, 0)
    }

    func testActivatingPuckAddsLocationConsumer() {
        puck3D.isActive = true

        XCTAssertEqual(locationSource.addStub.invocations.count, 1)
        XCTAssertTrue(locationSource.addStub.parameters.first === puck3D)
        XCTAssertEqual(locationSource.removeStub.invocations.count, 0)

        // activating again should have no effect
        puck3D.isActive = true

        XCTAssertEqual(locationSource.addStub.invocations.count, 1)
        XCTAssertEqual(locationSource.removeStub.invocations.count, 0)
    }

    func testDeactivatingPuckRemovesLocationConsumer() {
        puck3D.isActive = true
        locationSource.addStub.reset()
        locationSource.removeStub.reset()

        puck3D.isActive = false

        XCTAssertEqual(locationSource.addStub.invocations.count, 0)
        XCTAssertEqual(locationSource.removeStub.invocations.count, 1)
        XCTAssertTrue(locationSource.removeStub.parameters.first === puck3D)

        // deactivating again should have no effect
        puck3D.isActive = false

        XCTAssertEqual(locationSource.addStub.invocations.count, 0)
        XCTAssertEqual(locationSource.removeStub.invocations.count, 1)
    }

    func testSourceAndLayerAreNotAddedAtInitialization() {
        XCTAssertEqual(style.addSourceStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
    }

    func testActivatingPuckDoesNotAddSourceAndLayerIfLatestLocationIsNil() {
        locationSource.latestLocation = nil

        puck3D.isActive = true

        XCTAssertEqual(style.addSourceStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
    }

    func testActivatingPuckAddsSourceAndLayerIfLatestLocationIsNonNil() throws {
        let coordinate = CLLocationCoordinate2D.random()
        locationSource.latestLocation = Location(
            with: CLLocation(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude),
            heading: nil)
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
        locationSource.latestLocation = Location(
            with: location,
            heading: heading)
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
        locationSource.latestLocation = Location(
            with: location,
            heading: heading)
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
        locationSource.latestLocation = Location(
            with: CLLocation(),
            heading: nil)
        style.layerExistsStub.defaultReturnValue = false

        puck3D.isActive = true

        let actualLayer = try XCTUnwrap(style.addPersistentLayerStub.parameters.first?.layer as? ModelLayer)
        XCTAssertEqual(actualLayer.paint?.modelScale, configuration.modelScale)
        XCTAssertEqual(actualLayer.paint?.modelRotation, configuration.modelRotation)
    }

    func testUpdateExistingSource() throws {
        let coordinate = CLLocationCoordinate2D.random()
        locationSource.latestLocation = Location(
            with: CLLocation(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude),
            heading: nil)
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
        locationSource.latestLocation = Location(
            with: CLLocation(),
            heading: nil)
        style.sourceExistsStub.defaultReturnValue = false
        style.layerExistsStub.defaultReturnValue = false
        puck3D.isActive = false

        puck3D.puckBearingSource = [.heading, .course].randomElement()!

        XCTAssertEqual(style.addSourceStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
    }

    func testSettingPuckBearingSourceWhenActive() {
        locationSource.latestLocation = Location(
            with: CLLocation(),
            heading: nil)
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

    func testSettingPuckAccuracySourceWhenInactive() {
        locationSource.latestLocation = Location(
            with: CLLocation(),
            heading: nil)
        style.sourceExistsStub.defaultReturnValue = false
        style.layerExistsStub.defaultReturnValue = false
        puck3D.isActive = false

        puck3D.puckAccuracy = [.full, .reduced].randomElement()!

        XCTAssertEqual(style.addSourceStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
    }

    func testSettingPuckAccuracySourceWhenActive() {
        locationSource.latestLocation = Location(
            with: CLLocation(),
            heading: nil)
        puck3D.isActive = true
        style.sourceExistsStub.defaultReturnValue = true
        style.layerExistsStub.defaultReturnValue = true
        style.addSourceStub.reset()
        style.setSourcePropertiesStub.reset()
        style.addPersistentLayerStub.reset()

        puck3D.puckAccuracy = [.full, .reduced].randomElement()!

        XCTAssertEqual(style.addSourceStub.invocations.count, 0)
        XCTAssertEqual(style.setSourcePropertiesStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
    }

    func testLocationUpdateWhenInactive() {
        locationSource.latestLocation = Location(
            with: CLLocation(),
            heading: nil)
        style.sourceExistsStub.defaultReturnValue = false
        style.layerExistsStub.defaultReturnValue = false
        puck3D.isActive = false

        puck3D.locationUpdate(newLocation: locationSource.latestLocation!)

        XCTAssertEqual(style.addSourceStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
    }

    func testLocationUpdateWhenActive() {
        locationSource.latestLocation = Location(
            with: CLLocation(),
            heading: nil)
        puck3D.isActive = true
        style.sourceExistsStub.defaultReturnValue = true
        style.layerExistsStub.defaultReturnValue = true
        style.addSourceStub.reset()
        style.setSourcePropertiesStub.reset()
        style.addPersistentLayerStub.reset()

        puck3D.locationUpdate(newLocation: locationSource.latestLocation!)

        XCTAssertEqual(style.addSourceStub.invocations.count, 0)
        XCTAssertEqual(style.setSourcePropertiesStub.invocations.count, 1)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
    }
}
