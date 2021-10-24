import XCTest
@testable import MapboxMaps

final class Puck2DTests: XCTestCase {
    var configuration: Puck2DConfiguration!
    var style: MockStyle!
    var locationSource: MockLocationSource!
    var puck2D: Puck2D!
    var location: CLLocation!

    override func setUp() {
        super.setUp()
        configuration = Puck2DConfiguration(
            topImage: UIImage(),
            bearingImage: UIImage(),
            shadowImage: UIImage(),
            scale: .constant(.random(in: 1..<10)))
        style = MockStyle()
        locationSource = MockLocationSource()
        recreatePuck()
        location = CLLocation(
            coordinate: .random(),
            altitude: .random(in: 0..<100),
            horizontalAccuracy: 0,
            verticalAccuracy: 0,
            course: .random(in: 0..<360),
            speed: 0,
            timestamp: Date())
    }

    override func tearDown() {
        location = nil
        puck2D = nil
        locationSource = nil
        style = nil
        configuration = nil
        super.tearDown()
    }

    func recreatePuck() {
        puck2D = Puck2D(
            configuration: configuration,
            style: style,
            locationSource: locationSource)
    }

    func testDefaultPropertyValues() {
        XCTAssertFalse(puck2D.isActive)
        XCTAssertEqual(puck2D.puckBearingSource, .heading)
    }

    func testLocationConsumerIsNotAddedAtInitialization() {
        XCTAssertEqual(locationSource.addStub.invocations.count, 0)
        XCTAssertEqual(locationSource.removeStub.invocations.count, 0)
    }

    func testActivatingPuckAddsLocationConsumer() {
        puck2D.isActive = true

        XCTAssertEqual(locationSource.addStub.invocations.count, 1)
        XCTAssertTrue(locationSource.addStub.parameters.first === puck2D)
        XCTAssertEqual(locationSource.removeStub.invocations.count, 0)

        // activating again should have no effect
        puck2D.isActive = true

        XCTAssertEqual(locationSource.addStub.invocations.count, 1)
        XCTAssertEqual(locationSource.removeStub.invocations.count, 0)
    }

    func testDeactivatingPuckRemovesLocationConsumer() {
        puck2D.isActive = true
        locationSource.addStub.reset()
        locationSource.removeStub.reset()

        puck2D.isActive = false

        XCTAssertEqual(locationSource.addStub.invocations.count, 0)
        XCTAssertEqual(locationSource.removeStub.invocations.count, 1)
        XCTAssertTrue(locationSource.removeStub.parameters.first === puck2D)

        // deactivating again should have no effect
        puck2D.isActive = false

        XCTAssertEqual(locationSource.addStub.invocations.count, 0)
        XCTAssertEqual(locationSource.removeStub.invocations.count, 1)
    }

    func testLayerAndImagesAreNotAddedAtInitialization() {
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
        XCTAssertEqual(style.addImageStub.invocations.count, 0)
    }

    func testActivatingPuckDoesNotAddLayerIfLatestLocationIsNil() {
        locationSource.latestLocation = nil

        puck2D.isActive = true

        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
    }

    func verifyAddImages(line: UInt = #line) {
        XCTAssertEqual(style.addImageStub.invocations.count, 3, line: line)
        let parameters = style.addImageStub.parameters
        for p in parameters {
            XCTAssertFalse(p.sdf, line: line)
            XCTAssertEqual(p.stretchX, [], line: line)
            XCTAssertEqual(p.stretchY, [], line: line)
            XCTAssertNil(p.content, line: line)
        }
        guard parameters.count == 3 else {
            return
        }
        XCTAssertEqual(style.addImageStub.parameters[0].id, "locationIndicatorLayerTopImage", line: line)
        XCTAssertTrue(style.addImageStub.parameters[0].image === configuration.topImage, line: line)

        XCTAssertEqual(style.addImageStub.parameters[1].id, "locationIndicatorLayerBearingImage", line: line)
        XCTAssertTrue(style.addImageStub.parameters[1].image === configuration.bearingImage, line: line)

        XCTAssertEqual(style.addImageStub.parameters[2].id, "locationIndicatorLayerShadowImage", line: line)
        XCTAssertTrue(style.addImageStub.parameters[2].image === configuration.shadowImage, line: line)
    }

    func testActivatingPuckAddsImagesIfLatestLocationIsNil() {
        locationSource.latestLocation = nil

        puck2D.isActive = true

        verifyAddImages()
    }

    func testActivatingPuckAddsImagesIfLatestLocationIsNonNil() {
        locationSource.latestLocation = Location(
            location: CLLocation(),
            heading: nil,
            accuracyAuthorization: .fullAccuracy)

        puck2D.isActive = true

        verifyAddImages()
    }

    func testAddsDefaultImagesWhenConfigurationImagesAreNil() {
        configuration = Puck2DConfiguration(
            topImage: nil,
            bearingImage: nil,
            shadowImage: nil)
        recreatePuck()

        puck2D.isActive = true

        XCTAssertEqual(style.addImageStub.invocations.count, 2)
        let parameters = style.addImageStub.parameters
        guard parameters.count >= 2 else {
            return
        }
        XCTAssertEqual(style.addImageStub.parameters[0].id, "locationIndicatorLayerTopImage")
        let expectedTopImage = UIImage(named: "location-dot-inner", in: .mapboxMaps, compatibleWith: nil)!
        XCTAssertTrue(style.addImageStub.parameters[0].image.isEqual(expectedTopImage))

        XCTAssertEqual(style.addImageStub.parameters[1].id, "locationIndicatorLayerBearingImage")
        let expectedBearingImage = UIImage(named: "location-dot-outer", in: .mapboxMaps, compatibleWith: nil)!
        XCTAssertTrue(style.addImageStub.parameters[1].image.isEqual(expectedBearingImage))
    }

    func makeExpectedLayer() -> LocationIndicatorLayer {
        var expectedLayer = LocationIndicatorLayer(id: "puck")
        expectedLayer.topImage = .constant(.name("locationIndicatorLayerTopImage"))
        expectedLayer.bearingImage = .constant(.name("locationIndicatorLayerBearingImage"))
        expectedLayer.shadowImage = .constant(.name("locationIndicatorLayerShadowImage"))
        expectedLayer.location = .constant([location.coordinate.latitude, location.coordinate.longitude, location.altitude])
        expectedLayer.locationTransition = StyleTransition(duration: 0.5, delay: 0)
        expectedLayer.topImageSize = configuration.scale ?? .constant(1)
        expectedLayer.bearingImageSize = configuration.scale ?? .constant(1)
        expectedLayer.shadowImageSize = configuration.scale ?? .constant(1)
        expectedLayer.emphasisCircleRadiusTransition = StyleTransition(duration: 0, delay: 0)
        expectedLayer.bearingTransition = StyleTransition(duration: 0, delay: 0)
        expectedLayer.bearing = .constant(0)
        return expectedLayer
    }

    func testActivatingPuckAddsLayerIfLatestLocationIsNonNil() throws {
        locationSource.latestLocation = Location(
            location: location,
            heading: nil,
            accuracyAuthorization: .fullAccuracy)
        style.layerExistsStub.defaultReturnValue = false

        puck2D.isActive = true

        let expectedLayer = makeExpectedLayer()
        let expectedProperties = try expectedLayer.jsonObject()
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 1)
        let actualProperties = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.parameters.first?.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.parameters.first?.layerPosition, nil)
    }

    func testActivatingPuckWithNilShadowImage() throws {
        configuration.shadowImage = nil
        recreatePuck()
        locationSource.latestLocation = Location(
            location: location,
            heading: nil,
            accuracyAuthorization: .fullAccuracy)
        style.layerExistsStub.defaultReturnValue = false

        puck2D.isActive = true

        var expectedLayer = makeExpectedLayer()
        expectedLayer.shadowImage = nil
        let expectedProperties = try expectedLayer.jsonObject()
        let actualProperties = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.parameters.first?.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
    }

    func testActivatingPuckWithNilScale() throws {
        configuration.scale = nil
        recreatePuck()
        locationSource.latestLocation = Location(
            location: location,
            heading: nil,
            accuracyAuthorization: .fullAccuracy)
        style.layerExistsStub.defaultReturnValue = false

        puck2D.isActive = true

        let expectedLayer = makeExpectedLayer()
        let expectedProperties = try expectedLayer.jsonObject()
        let actualProperties = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.parameters.first?.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
    }

    func testActivatingPuckWithShowsAccuracyRingTrue() throws {
        configuration.showsAccuracyRing = true
        recreatePuck()
        locationSource.latestLocation = Location(
            location: location,
            heading: nil,
            accuracyAuthorization: .fullAccuracy)
        style.layerExistsStub.defaultReturnValue = false

        puck2D.isActive = true

        var expectedLayer = makeExpectedLayer()
        expectedLayer.accuracyRadius = .constant(location.horizontalAccuracy)
        expectedLayer.accuracyRadiusColor = .constant(StyleColor(UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)))
        expectedLayer.accuracyRadiusBorderColor = .constant(StyleColor(.lightGray))
        let expectedProperties = try expectedLayer.jsonObject()
        let actualProperties = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.parameters.first?.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
    }

    func testActivatingPuckWithNonNilHeading() throws {
        let heading = MockHeading()
        heading.trueHeadingStub.defaultReturnValue = .random(in: 0..<360)
        locationSource.latestLocation = Location(
            location: location,
            heading: heading,
            accuracyAuthorization: .fullAccuracy)
        style.layerExistsStub.defaultReturnValue = false

        puck2D.isActive = true

        var expectedLayer = makeExpectedLayer()
        expectedLayer.bearing = .constant(locationSource.latestLocation!.headingDirection!)
        let expectedProperties = try expectedLayer.jsonObject()
        let actualProperties = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.parameters.first?.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
    }

    func testActivatingPuckWithPuckBearingSourceSetToCourse() throws {
        let heading = MockHeading()
        heading.trueHeadingStub.defaultReturnValue = .random(in: 0..<360)
        locationSource.latestLocation = Location(
            location: location,
            heading: heading,
            accuracyAuthorization: .fullAccuracy)
        style.layerExistsStub.defaultReturnValue = false
        puck2D.puckBearingSource = .course

        puck2D.isActive = true

        var expectedLayer = makeExpectedLayer()
        expectedLayer.bearing = .constant(locationSource.latestLocation!.course)
        let expectedProperties = try expectedLayer.jsonObject()
        let actualProperties = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.parameters.first?.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
    }

    func testActivatingPuckWithReducedAccuracy() throws {
        locationSource.latestLocation = Location(
            location: location,
            heading: nil,
            accuracyAuthorization: .reducedAccuracy)
        style.layerExistsStub.defaultReturnValue = false

        puck2D.isActive = true

        var expectedLayer = LocationIndicatorLayer(id: "puck")
        expectedLayer.accuracyRadius = .expression(Exp(.interpolate) {
            Exp(.linear)
            Exp(.zoom)
            0
            400000
            4
            200000
            8
            5000
        })
        expectedLayer.accuracyRadiusColor = .constant(StyleColor(UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)))
        expectedLayer.accuracyRadiusBorderColor = .constant(StyleColor(.lightGray))
        let expectedProperties = try expectedLayer.jsonObject()
        let actualProperties = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.parameters.first?.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
    }

    func testResetsPropertiesToDefaultValues() throws {
        locationSource.latestLocation = Location(
            location: location,
            heading: nil,
            accuracyAuthorization: .fullAccuracy)
        puck2D.isActive = true
        style.layerExistsStub.defaultReturnValue = true

        // there are a bunch of properties that aren't used in "reduced" mode
        // and they should be reset to their default values if the layer already
        // existed
        locationSource.latestLocation = Location(
            location: location,
            heading: nil,
            accuracyAuthorization: .reducedAccuracy)
        puck2D.locationUpdate(newLocation: locationSource.latestLocation!)

        let originalLayer = makeExpectedLayer()
        let originalKeys = try originalLayer.jsonObject().keys

        var expectedLayer = LocationIndicatorLayer(id: "puck")
        expectedLayer.accuracyRadius = .expression(Exp(.interpolate) {
            Exp(.linear)
            Exp(.zoom)
            0
            400000
            4
            200000
            8
            5000
        })
        expectedLayer.accuracyRadiusColor = .constant(StyleColor(UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)))
        expectedLayer.accuracyRadiusBorderColor = .constant(StyleColor(.lightGray))
        var expectedProperties = try expectedLayer.jsonObject()
        for key in originalKeys where expectedProperties[key] == nil {
            expectedProperties[key] = Style.layerPropertyDefaultValue(for: .locationIndicator, property: key)
        }
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        let actualProperties = try XCTUnwrap(style.setLayerPropertiesStub.parameters.first?.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
    }

    func testSettingPuckBearingSourceWhenInactive() {
        locationSource.latestLocation = Location(
            location: CLLocation(),
            heading: nil,
            accuracyAuthorization: .fullAccuracy)
        style.layerExistsStub.defaultReturnValue = false
        puck2D.isActive = false

        puck2D.puckBearingSource = [.heading, .course].randomElement()!

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 0)
    }

    func testSettingPuckBearingSourceWhenActive() {
        locationSource.latestLocation = Location(
            location: CLLocation(),
            heading: nil,
            accuracyAuthorization: .fullAccuracy)
        puck2D.isActive = true
        style.layerExistsStub.defaultReturnValue = true

        puck2D.puckBearingSource = [.heading, .course].randomElement()!

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
    }

    func testLocationUpdateWhenInactive() {
        locationSource.latestLocation = Location(
            location: CLLocation(),
            heading: nil,
            accuracyAuthorization: .fullAccuracy)
        style.layerExistsStub.defaultReturnValue = false
        puck2D.isActive = false

        puck2D.locationUpdate(newLocation: locationSource.latestLocation!)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 0)
    }

    func testLocationUpdateWhenActive() {
        locationSource.latestLocation = Location(
            location: CLLocation(),
            heading: nil,
            accuracyAuthorization: .fullAccuracy)
        puck2D.isActive = true
        style.layerExistsStub.defaultReturnValue = true

        puck2D.locationUpdate(newLocation: locationSource.latestLocation!)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
    }
}
