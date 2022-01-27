import XCTest
@testable import MapboxMaps

final class Puck2DTests: XCTestCase {
    var configuration: Puck2DConfiguration!
    var style: MockStyle!
    var locationProducer: MockLocationProducer!
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
        locationProducer = MockLocationProducer()
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
        locationProducer = nil
        style = nil
        configuration = nil
        super.tearDown()
    }

    func recreatePuck() {
        puck2D = Puck2D(
            configuration: configuration,
            style: style,
            locationProducer: locationProducer)
    }

    func testDefaultPropertyValues() {
        XCTAssertFalse(puck2D.isActive)
        XCTAssertEqual(puck2D.puckBearingSource, .heading)
    }

    func testLocationConsumerIsNotAddedAtInitialization() {
        XCTAssertEqual(locationProducer.addStub.invocations.count, 0)
        XCTAssertEqual(locationProducer.removeStub.invocations.count, 0)
    }

    func testMakeDefault() {
        let puck2D = Puck2DConfiguration.makeDefault()
        XCTAssertEqual(puck2D.topImage, UIImage(named: "location-dot-inner", in: .mapboxMaps, compatibleWith: nil)!)
        XCTAssertNil(puck2D.bearingImage)
        XCTAssertEqual(puck2D.shadowImage, UIImage(named: "location-dot-outer", in: .mapboxMaps, compatibleWith: nil)!)
    }

    func testMakeDefaultWithBearing() {
        let puck2D = Puck2DConfiguration.makeDefault(showBearing: true)
        XCTAssertEqual(puck2D.topImage, UIImage(named: "location-dot-inner", in: .mapboxMaps, compatibleWith: nil)!)
        XCTAssertNotNil(puck2D.bearingImage)
        XCTAssertEqual(puck2D.shadowImage, UIImage(named: "location-dot-outer", in: .mapboxMaps, compatibleWith: nil)!)
    }

    func testActivatingPuckAddsLocationConsumer() {
        puck2D.isActive = true

        XCTAssertEqual(locationProducer.addStub.invocations.count, 1)
        XCTAssertTrue(locationProducer.addStub.parameters.first === puck2D)
        XCTAssertEqual(locationProducer.removeStub.invocations.count, 0)

        // activating again should have no effect
        puck2D.isActive = true

        XCTAssertEqual(locationProducer.addStub.invocations.count, 1)
        XCTAssertEqual(locationProducer.removeStub.invocations.count, 0)
    }

    func testDeactivatingPuckRemovesLocationConsumer() {
        puck2D.isActive = true
        locationProducer.addStub.reset()
        locationProducer.removeStub.reset()

        puck2D.isActive = false

        XCTAssertEqual(locationProducer.addStub.invocations.count, 0)
        XCTAssertEqual(locationProducer.removeStub.invocations.count, 1)
        XCTAssertTrue(locationProducer.removeStub.parameters.first === puck2D)

        // deactivating again should have no effect
        puck2D.isActive = false

        XCTAssertEqual(locationProducer.addStub.invocations.count, 0)
        XCTAssertEqual(locationProducer.removeStub.invocations.count, 1)
    }

    func testLayerAndImagesAreNotAddedAtInitialization() {
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
        XCTAssertEqual(style.addImageStub.invocations.count, 0)
    }

    func testActivatingPuckDoesNotAddLayerIfLatestLocationIsNil() {
        locationProducer.latestLocation = nil

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

    func testActivatingPuckDoesNotAddImagesIfLatestLocationIsNil() {
        locationProducer.latestLocation = nil

        puck2D.isActive = true

        XCTAssertEqual(style.addImageStub.invocations.count, 0)

        // When the location becomes non-nil, then the images get added
        let location = Location(
            location: CLLocation(),
            heading: nil,
            accuracyAuthorization: .fullAccuracy)
        locationProducer.latestLocation = location

        puck2D.locationUpdate(newLocation: location)

        verifyAddImages()
    }

    func testActivatingPuckAddsImagesIfLatestLocationIsNonNil() {
        locationProducer.latestLocation = Location(
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
        locationProducer.latestLocation = Location(
            location: CLLocation(),
            heading: nil,
            accuracyAuthorization: .fullAccuracy)

        puck2D.isActive = true

        XCTAssertEqual(style.addImageStub.invocations.count, 2)
        let parameters = style.addImageStub.parameters
        guard parameters.count >= 2 else {
            return
        }
        XCTAssertEqual(style.addImageStub.parameters[0].id, "locationIndicatorLayerTopImage")
        let expectedTopImage = UIImage(named: "location-dot-inner", in: .mapboxMaps, compatibleWith: nil)!
        XCTAssertTrue(style.addImageStub.parameters[0].image.isEqual(expectedTopImage))

        XCTAssertEqual(style.addImageStub.parameters[1].id, "locationIndicatorLayerShadowImage")
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
        locationProducer.latestLocation = Location(
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

    func testActivatingPuckWithNilImages() throws {
        configuration.shadowImage = nil
        configuration.topImage = nil
        configuration.bearingImage = nil
        recreatePuck()
        locationProducer.latestLocation = Location(
            location: location,
            heading: nil,
            accuracyAuthorization: .fullAccuracy)
        style.layerExistsStub.defaultReturnValue = false

        puck2D.isActive = true

        var expectedLayer = makeExpectedLayer()
        expectedLayer.bearingImage = nil
        let expectedProperties = try expectedLayer.jsonObject()
        let actualProperties = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.parameters.first?.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
    }

    func testActivatingPuckWithNilScale() throws {
        configuration.scale = nil
        recreatePuck()
        locationProducer.latestLocation = Location(
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
        locationProducer.latestLocation = Location(
            location: location,
            heading: nil,
            accuracyAuthorization: .fullAccuracy)
        style.layerExistsStub.defaultReturnValue = false

        puck2D.isActive = true

        var expectedLayer = makeExpectedLayer()
        expectedLayer.accuracyRadius = .constant(location.horizontalAccuracy)
        expectedLayer.accuracyRadiusColor = .constant(StyleColor(UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)))
        expectedLayer.accuracyRadiusBorderColor = .constant(StyleColor(UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)))
        let expectedProperties = try expectedLayer.jsonObject()
        let actualProperties = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.parameters.first?.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
    }

    func testActivatingPuckWithNonNilHeading() throws {
        let heading = MockHeading()
        heading.trueHeadingStub.defaultReturnValue = .random(in: 0..<360)
        locationProducer.latestLocation = Location(
            location: location,
            heading: heading,
            accuracyAuthorization: .fullAccuracy)
        style.layerExistsStub.defaultReturnValue = false

        puck2D.isActive = true

        var expectedLayer = makeExpectedLayer()
        expectedLayer.bearing = .constant(locationProducer.latestLocation!.headingDirection!)
        let expectedProperties = try expectedLayer.jsonObject()
        let actualProperties = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.parameters.first?.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
    }

    func testActivatingPuckWithPuckBearingSourceSetToCourse() throws {
        let heading = MockHeading()
        heading.trueHeadingStub.defaultReturnValue = .random(in: 0..<360)
        locationProducer.latestLocation = Location(
            location: location,
            heading: heading,
            accuracyAuthorization: .fullAccuracy)
        style.layerExistsStub.defaultReturnValue = false
        puck2D.puckBearingSource = .course

        puck2D.isActive = true

        var expectedLayer = makeExpectedLayer()
        expectedLayer.bearing = .constant(locationProducer.latestLocation!.course)
        let expectedProperties = try expectedLayer.jsonObject()
        let actualProperties = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.parameters.first?.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
    }

    func testActivatingPuckWithReducedAccuracy() throws {
        locationProducer.latestLocation = Location(
            location: location,
            heading: nil,
            accuracyAuthorization: .reducedAccuracy)
        style.layerExistsStub.defaultReturnValue = false

        puck2D.isActive = true

        var expectedLayer = LocationIndicatorLayer(id: "puck")
        expectedLayer.location = .constant([
            location.coordinate.latitude,
            location.coordinate.longitude,
            location.altitude
        ])
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
        expectedLayer.accuracyRadiusBorderColor = .constant(StyleColor(UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)))
        let expectedProperties = try expectedLayer.jsonObject()
        let actualProperties = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.parameters.first?.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
    }

    func testResetsPropertiesToDefaultValues() throws {
        locationProducer.latestLocation = Location(
            location: location,
            heading: nil,
            accuracyAuthorization: .fullAccuracy)
        puck2D.isActive = true
        style.layerExistsStub.defaultReturnValue = true

        // there are a bunch of properties that aren't used in "reduced" mode
        // and they should be reset to their default values if the layer already
        // existed
        locationProducer.latestLocation = Location(
            location: location,
            heading: nil,
            accuracyAuthorization: .reducedAccuracy)
        puck2D.locationUpdate(newLocation: locationProducer.latestLocation!)

        let originalLayer = makeExpectedLayer()
        let originalKeys = try originalLayer.jsonObject().keys

        var expectedLayer = LocationIndicatorLayer(id: "puck")
        expectedLayer.location = .constant([
            location.coordinate.latitude,
            location.coordinate.longitude,
            location.altitude
        ])
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
        expectedLayer.accuracyRadiusBorderColor = .constant(StyleColor(UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)))
        var expectedProperties = try expectedLayer.jsonObject()
        for key in originalKeys where expectedProperties[key] == nil {
            expectedProperties[key] = Style.layerPropertyDefaultValue(for: .locationIndicator, property: key)
        }
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        let actualProperties = try XCTUnwrap(style.setLayerPropertiesStub.parameters.first?.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
    }

    func testSettingPuckBearingSourceWhenInactive() {
        locationProducer.latestLocation = Location(
            location: CLLocation(),
            heading: nil,
            accuracyAuthorization: .fullAccuracy)
        style.layerExistsStub.defaultReturnValue = false
        puck2D.isActive = false

        puck2D.puckBearingSource = [.heading, .course].randomElement()!

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 0)
    }

    func testSettingPuckBearingSourceWhenActive() {
        locationProducer.latestLocation = Location(
            location: CLLocation(),
            heading: nil,
            accuracyAuthorization: .fullAccuracy)
        puck2D.isActive = true
        style.layerExistsStub.defaultReturnValue = true

        puck2D.puckBearingSource = [.heading, .course].randomElement()!

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
    }

    func testLocationUpdateWhenInactive() {
        locationProducer.latestLocation = Location(
            location: CLLocation(),
            heading: nil,
            accuracyAuthorization: .fullAccuracy)
        style.layerExistsStub.defaultReturnValue = false
        puck2D.isActive = false

        puck2D.locationUpdate(newLocation: locationProducer.latestLocation!)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 0)
    }

    func testLocationUpdateWhenActive() {
        locationProducer.latestLocation = Location(
            location: CLLocation(),
            heading: nil,
            accuracyAuthorization: .fullAccuracy)
        puck2D.isActive = true
        style.layerExistsStub.defaultReturnValue = true

        puck2D.locationUpdate(newLocation: locationProducer.latestLocation!)

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
    }
}
