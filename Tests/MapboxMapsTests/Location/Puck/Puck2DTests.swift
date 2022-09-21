import XCTest
@testable import MapboxMaps

final class Puck2DTests: XCTestCase {
    var configuration: Puck2DConfiguration!
    var style: MockStyle!
    var interpolatedLocationProducer: MockInterpolatedLocationProducer!
    var puck2D: Puck2D!
    var mapboxMap: MockMapboxMap!
    var displayLinkCoordinator: MockDisplayLinkCoordinator!
    var timeProvider: MockTimeProvider!

    override func setUp() {
        super.setUp()
        configuration = Puck2DConfiguration(
            topImage: UIImage(),
            bearingImage: UIImage(),
            shadowImage: UIImage(),
            scale: .constant(.random(in: 1..<10)),
            opacity: .random(in: 0.0...1.0))
        style = MockStyle()
        interpolatedLocationProducer = MockInterpolatedLocationProducer()
        mapboxMap = MockMapboxMap()
        displayLinkCoordinator = MockDisplayLinkCoordinator()
        timeProvider = MockTimeProvider()
        recreatePuck()
    }

    override func tearDown() {
        puck2D = nil
        displayLinkCoordinator = nil
        interpolatedLocationProducer = nil
        style = nil
        mapboxMap = nil
        configuration = nil
        timeProvider = nil
        super.tearDown()
    }

    func recreatePuck() {
        puck2D = Puck2D(
            configuration: configuration,
            style: style,
            interpolatedLocationProducer: interpolatedLocationProducer,
            mapboxMap: mapboxMap,
            displayLinkCoordinator: displayLinkCoordinator,
            timeProvider: timeProvider)
    }

    @discardableResult
    func updateLocation(with accuracyAuthorization: CLAccuracyAuthorization = .random(),
                        course: CLLocationDirection? = .random(.random(in: 0..<360)),
                        heading: CLLocationDirection? = .random(.random(in: 0..<360)),
                        coordinate: CLLocationCoordinate2D = .random(),
                        horizontalAccuracy: CLLocationAccuracy = .random(in: 0...100)) -> InterpolatedLocation {
        var location = InterpolatedLocation.random()
        location.coordinate = coordinate
        location.accuracyAuthorization = accuracyAuthorization
        location.course = course
        location.heading = heading
        location.horizontalAccuracy = horizontalAccuracy
        interpolatedLocationProducer.location = location
        // invoke handler synchronously to mimic the actual implementation
        interpolatedLocationProducer.observeStub.defaultSideEffect = {
            let handler = $0.parameters
            XCTAssertTrue(handler(location))
        }
        // invoke handlers that haven't been canceled
        for observeInvocation in interpolatedLocationProducer.observeStub.invocations {
            if let cancelable = observeInvocation.returnValue as? MockCancelable,
               cancelable.cancelStub.invocations.isEmpty {
                let handler = observeInvocation.parameters
                XCTAssertTrue(handler(location))
            }
        }
        return location
    }

    func testDefaultPropertyValues() {
        XCTAssertFalse(puck2D.isActive)
        XCTAssertEqual(puck2D.puckBearingSource, .heading)
        XCTAssertEqual(puck2D.puckBearingEnabled, true)
    }

    func testLocationConsumerIsNotAddedAtInitialization() {
        XCTAssertEqual(interpolatedLocationProducer.observeStub.invocations.count, 0)
    }

    func testActivatingPuckAddsLocationConsumer() throws {
        puck2D.isActive = true

        XCTAssertEqual(interpolatedLocationProducer.observeStub.invocations.count, 1)
        let cancelable = try XCTUnwrap(interpolatedLocationProducer.observeStub.invocations.first?.returnValue as? MockCancelable)
        XCTAssertEqual(cancelable.cancelStub.invocations.count, 0)

        // activating again should have no effect
        puck2D.isActive = true

        XCTAssertEqual(interpolatedLocationProducer.observeStub.invocations.count, 1)
        XCTAssertEqual(cancelable.cancelStub.invocations.count, 0)
    }

    func testDeactivatingPuckRemovesLocationConsumer() throws {
        puck2D.isActive = true
        let cancelable = try XCTUnwrap(interpolatedLocationProducer.observeStub.invocations.first?.returnValue as? MockCancelable)
        interpolatedLocationProducer.observeStub.reset()

        puck2D.isActive = false

        XCTAssertEqual(interpolatedLocationProducer.observeStub.invocations.count, 0)
        XCTAssertEqual(cancelable.cancelStub.invocations.count, 1)

        // deactivating again should have no effect
        puck2D.isActive = false

        XCTAssertEqual(interpolatedLocationProducer.observeStub.invocations.count, 0)
        XCTAssertEqual(cancelable.cancelStub.invocations.count, 1)
    }

    func testLayerAndImagesAreNotAddedAtInitialization() {
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
        XCTAssertEqual(style.addImageStub.invocations.count, 0)
    }

    func testActivatingPuckDoesNotAddLayerIfLatestLocationIsNil() {
        puck2D.isActive = true

        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
    }

    func testActivatingPuckAddsDisplayLinkParticipant() {
        configuration = Puck2DConfiguration(pulsing: .default)
        recreatePuck()

        puck2D.isActive = true

        XCTAssertEqual(displayLinkCoordinator.addStub.invocations.count, 1)
        XCTAssertEqual(displayLinkCoordinator.removeStub.invocations.count, 0)
    }

    func testActivatingPuckDoesnNotAddDisplayLinkParticipant() {
        var pulsing = Puck2DConfiguration.Pulsing.default
        pulsing.isEnabled = false
        configuration = Puck2DConfiguration(pulsing: pulsing)
        recreatePuck()

        puck2D.isActive = true

        XCTAssertEqual(displayLinkCoordinator.addStub.invocations.count, 0)
        XCTAssertEqual(displayLinkCoordinator.removeStub.invocations.count, 0)
    }

    func testDectivatingPuckRemovesDisplayLinkParticipant() {
        puck2D.isActive = true

        puck2D.isActive = false

        XCTAssertEqual(displayLinkCoordinator.removeStub.invocations.count, 1)
    }

    func verifyAddImages(line: UInt = #line) {
        XCTAssertEqual(style.addImageStub.invocations.count, 3, line: line)
        let parameters = style.addImageStub.invocations.map(\.parameters)
        for p in parameters {
            XCTAssertFalse(p.sdf, line: line)
            XCTAssertEqual(p.stretchX, [], line: line)
            XCTAssertEqual(p.stretchY, [], line: line)
            XCTAssertNil(p.content, line: line)
        }
        guard parameters.count == 3 else {
            return
        }
        XCTAssertEqual(parameters[0].id, "locationIndicatorLayerTopImage", line: line)
        XCTAssertTrue(parameters[0].image === configuration.topImage, line: line)

        XCTAssertEqual(parameters[1].id, "locationIndicatorLayerBearingImage", line: line)
        XCTAssertTrue(parameters[1].image === configuration.bearingImage, line: line)

        XCTAssertEqual(parameters[2].id, "locationIndicatorLayerShadowImage", line: line)
        XCTAssertTrue(parameters[2].image === configuration.shadowImage, line: line)
    }

    func testActivatingPuckDoesNotAddImagesIfLatestLocationIsNil() throws {
        puck2D.isActive = true

        XCTAssertEqual(style.addImageStub.invocations.count, 0)

        // When the location becomes non-nil, then the images get added
        updateLocation()

        verifyAddImages()
    }

    func testActivatingPuckAddsImagesIfLatestLocationIsNonNil() {
        updateLocation()

        puck2D.isActive = true

        verifyAddImages()
    }

    func testAddsDefaultImagesWhenConfigurationImagesAreNil() {
        configuration = Puck2DConfiguration(
            topImage: nil,
            bearingImage: nil,
            shadowImage: nil)
        recreatePuck()
        updateLocation()

        puck2D.isActive = true

        XCTAssertEqual(style.addImageStub.invocations.count, 2)
        let parameters = style.addImageStub.invocations.map(\.parameters)
        guard parameters.count >= 2 else {
            return
        }
        XCTAssertEqual(parameters[0].id, "locationIndicatorLayerTopImage")
        let expectedTopImage = UIImage(named: "location-dot-inner", in: .mapboxMaps, compatibleWith: nil)!
        XCTAssertTrue(parameters[0].image.isEqual(expectedTopImage))

        XCTAssertEqual(parameters[1].id, "locationIndicatorLayerShadowImage")
        let expectedBearingImage = UIImage(named: "location-dot-outer", in: .mapboxMaps, compatibleWith: nil)!
        XCTAssertTrue(parameters[1].image.isEqual(expectedBearingImage))
    }

    func makeExpectedLayerProperties(with location: InterpolatedLocation) -> [String: Any] {
        var expectedLayoutLayerProperties = [LocationIndicatorLayer.LayoutCodingKeys: Any]()
        expectedLayoutLayerProperties[.topImage] = "locationIndicatorLayerTopImage"
        expectedLayoutLayerProperties[.bearingImage] = "locationIndicatorLayerBearingImage"
        expectedLayoutLayerProperties[.shadowImage] = "locationIndicatorLayerShadowImage"

        let resolvedScale = configuration.scale ?? .constant(1)
        let scale = try! resolvedScale.toJSON()

        var expectedPaintLayerProperties = [LocationIndicatorLayer.PaintCodingKeys: Any]()
        expectedPaintLayerProperties[.location] = [location.coordinate.latitude, location.coordinate.longitude, location.altitude]
        expectedPaintLayerProperties[.locationTransition] = ["duration": 0, "delay": 0]
        expectedPaintLayerProperties[.topImageSize] = scale
        expectedPaintLayerProperties[.bearingImageSize] = scale
        expectedPaintLayerProperties[.shadowImageSize] = scale
        expectedPaintLayerProperties[.emphasisCircleRadiusTransition] = ["duration": 0, "delay": 0]
        expectedPaintLayerProperties[.bearingTransition] = ["duration": 0, "delay": 0]
        expectedPaintLayerProperties[.bearing] = 0
        expectedPaintLayerProperties[.locationIndicatorOpacity] = configuration.opacity
        expectedPaintLayerProperties[.locationIndicatorOpacityTransition] = ["duration": 0, "delay": 0]

        var expectedProperties = expectedLayoutLayerProperties
            .mapKeys(\.rawValue)
            .merging(
                expectedPaintLayerProperties.mapKeys(\.rawValue),
                uniquingKeysWith: { $1 })

        expectedProperties["id"] = "puck"
        expectedProperties["type"] = "location-indicator"

        return expectedProperties
    }

    func testActivatingPuckAddsLayerIfLatestLocationIsNonNil() throws {
        let location = updateLocation(with: .fullAccuracy, heading: nil)
        style.layerExistsStub.defaultReturnValue = false

        puck2D.isActive = true

        let expectedProperties = makeExpectedLayerProperties(with: location)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 1)
        let actualProperties = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.invocations.first?.parameters.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.first?.parameters.layerPosition, nil)
    }

    func testReactivatingPuckDoesNotTakeFastPath() throws {
        let location = updateLocation(with: .fullAccuracy, heading: nil)
        style.layerExistsStub.defaultReturnValue = false
        puck2D.isActive = true
        puck2D.isActive = false
        style.addPersistentLayerWithPropertiesStub.reset()
        style.setLayerPropertiesStub.reset()

        puck2D.isActive = true

        let expectedProperties = makeExpectedLayerProperties(with: location)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 1)
        let actualProperties = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.invocations.first?.parameters.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.first?.parameters.layerPosition, nil)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 0)
    }

    func testActivatingPuckWithNilImages() throws {
        configuration.shadowImage = nil
        configuration.topImage = nil
        configuration.bearingImage = nil
        recreatePuck()
        let location = updateLocation(with: .fullAccuracy, heading: nil)
        style.layerExistsStub.defaultReturnValue = false

        puck2D.isActive = true

        var expectedProperties = makeExpectedLayerProperties(with: location)
        expectedProperties.removeValue(forKey: LocationIndicatorLayer.LayoutCodingKeys.bearingImage.rawValue)
        let actualProperties = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.invocations.first?.parameters.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
    }

    func testActivatingPuckWithNilScale() throws {
        configuration.scale = nil
        recreatePuck()
        let location = updateLocation(with: .fullAccuracy, heading: nil)
        style.layerExistsStub.defaultReturnValue = false

        puck2D.isActive = true

        let expectedProperties = makeExpectedLayerProperties(with: location)
        let actualProperties = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.invocations.first?.parameters.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
    }

    func testActivatingPuckWithShowsAccuracyRingTrue() throws {
        configuration.showsAccuracyRing = true
        recreatePuck()
        let location = updateLocation(with: .fullAccuracy, heading: nil)
        style.layerExistsStub.defaultReturnValue = false

        puck2D.isActive = true

        var expectedProperties = makeExpectedLayerProperties(with: location)
        expectedProperties["accuracy-radius"] = location.horizontalAccuracy
        expectedProperties["accuracy-radius-color"] = StyleColor(UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)).rgbaString
        expectedProperties["accuracy-radius-border-color"] = StyleColor(UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)).rgbaString
        let actualProperties = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.invocations.first?.parameters.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
    }

    func testActivatingPuckWithNonNilHeading() throws {
        let location = updateLocation(with: .fullAccuracy, heading: .random(in: 0..<360))
        style.layerExistsStub.defaultReturnValue = false

        puck2D.isActive = true

        var expectedProperties = makeExpectedLayerProperties(with: location)
        expectedProperties["bearing"] = interpolatedLocationProducer.location!.heading!
        let actualProperties = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.invocations.first?.parameters.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
    }

    func testActivatingPuckWithBearingDisabledForHeading() throws {
        let location = updateLocation(with: .fullAccuracy, heading: .random(in: 0..<360))
        style.layerExistsStub.defaultReturnValue = false
        puck2D.puckBearingEnabled = false
        puck2D.isActive = true

        var expectedProperties = makeExpectedLayerProperties(with: location)
        expectedProperties.removeValue(forKey: "bearing")
        let actualProperties = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.invocations.first?.parameters.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
    }

    func testActivatingPuckWithBearingDisabledForCourse() throws {
        let location = updateLocation(with: .fullAccuracy, course: .random(in: 0..<360))
        style.layerExistsStub.defaultReturnValue = false
        puck2D.puckBearingEnabled = false

        puck2D.isActive = true

        var expectedProperties = makeExpectedLayerProperties(with: location)
        expectedProperties.removeValue(forKey: "bearing")
        let actualProperties = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.invocations.first?.parameters.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
    }

    func testActivatingPuckWithPuckBearingSourceSetToCourse() throws {
        let location = updateLocation(with: .fullAccuracy, course: .random(in: 0..<360))
        style.layerExistsStub.defaultReturnValue = false
        puck2D.puckBearingSource = .course

        puck2D.isActive = true

        var expectedProperties = makeExpectedLayerProperties(with: location)
        expectedProperties["bearing"] = interpolatedLocationProducer.location!.course!
        let actualProperties = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.invocations.first?.parameters.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
    }

    func testActivatingPuckWithPuckBearingSourceSetToCourseWithNilCourse() throws {
        updateLocation(with: .fullAccuracy, course: .random(in: 0..<360))
        style.layerExistsStub.defaultReturnValue = false
        puck2D.puckBearingSource = .course

        puck2D.isActive = true
        let location = updateLocation(with: .fullAccuracy, course: nil)

        let expectedProperties: [LocationIndicatorLayer.PaintCodingKeys: Any] = [
            .location: [
                location.coordinate.latitude,
                location.coordinate.longitude,
                location.altitude],
            .bearing: 0
        ]

        let actualProperties = try XCTUnwrap(style.setLayerPropertiesStub.invocations.last?.parameters.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties.mapKeys(\.rawValue) as NSDictionary)
    }

    func testActivatingPuckWithPuckBearingSourceSetToHeadingWithNilHeading() throws {
        updateLocation(with: .fullAccuracy, heading: .random(in: 0..<360))
        style.layerExistsStub.defaultReturnValue = false
        puck2D.puckBearingSource = .heading

        puck2D.isActive = true
        let location = updateLocation(with: .fullAccuracy, heading: nil)

        let expectedProperties: [LocationIndicatorLayer.PaintCodingKeys: Any] = [
            .location: [
                location.coordinate.latitude,
                location.coordinate.longitude,
                location.altitude],
            .bearing: 0
        ]

        let actualProperties = try XCTUnwrap(style.setLayerPropertiesStub.invocations.last?.parameters.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties.mapKeys(\.rawValue) as NSDictionary)
    }

    func testActivatingPuckWithReducedAccuracy() throws {
        let location = updateLocation(with: .reducedAccuracy, heading: .random(in: 0..<360))
        style.layerExistsStub.defaultReturnValue = false

        puck2D.isActive = true

        var expectedProperties = [String: Any]()
        expectedProperties["id"] = "puck"
        expectedProperties["type"] = "location-indicator"
        expectedProperties["location"] = [
            location.coordinate.latitude,
            location.coordinate.longitude,
            location.altitude
        ]
        expectedProperties["accuracy-radius"] = [
            "interpolate",
            ["linear"],
            ["zoom"],
            0,
            400000,
            4,
            200000,
            8,
            5000]
        expectedProperties["accuracy-radius-color"] = StyleColor(UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)).rgbaString
        expectedProperties["accuracy-radius-border-color"] = StyleColor(UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)).rgbaString
        let actualProperties = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.invocations.first?.parameters.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
    }

    func testResetsPropertiesToDefaultValues() throws {
        let originalLocation = updateLocation(with: .fullAccuracy, heading: nil)
        puck2D.isActive = true
        style.layerExistsStub.defaultReturnValue = true
        var originalKeys = Set(makeExpectedLayerProperties(with: originalLocation).keys)
        originalKeys.remove("id")
        originalKeys.remove("type")

        // there are a bunch of properties that aren't used in "reduced" mode
        // and they should be reset to their default values if the layer already
        // existed
        let location = updateLocation(with: .reducedAccuracy, heading: nil)

        var expectedProperties = [String: Any]()
        expectedProperties["location"] = [
            location.coordinate.latitude,
            location.coordinate.longitude,
            location.altitude
        ]
        expectedProperties["accuracy-radius"] = [
            "interpolate",
            ["linear"],
            ["zoom"],
            0,
            400000,
            4,
            200000,
            8,
            5000]
        expectedProperties["accuracy-radius-color"] = StyleColor(UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)).rgbaString
        expectedProperties["accuracy-radius-border-color"] = StyleColor(UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)).rgbaString
        for key in originalKeys where expectedProperties[key] == nil {
            expectedProperties[key] = Style.layerPropertyDefaultValue(for: .locationIndicator, property: key).value
        }
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        let actualProperties = try XCTUnwrap(style.setLayerPropertiesStub.invocations.first?.parameters.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
    }

    func testSettingPuckBearingSourceWhenInactive() {
        updateLocation()
        style.layerExistsStub.defaultReturnValue = false
        puck2D.isActive = false

        puck2D.puckBearingSource = [.heading, .course].randomElement()!

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 0)
    }

    func testSettingPuckBearingSourceWhenActive() {
        updateLocation()
        puck2D.isActive = true
        style.layerExistsStub.defaultReturnValue = true

        puck2D.puckBearingSource = [.heading, .course].randomElement()!

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
    }

    func testLocationUpdateWhenActive() {
        updateLocation()
        puck2D.isActive = true
        style.layerExistsStub.defaultReturnValue = true

        updateLocation()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
    }

    func testFastPathFullAccuracyWithAccuracyRingNilHeading() throws {
        configuration.showsAccuracyRing = true
        recreatePuck()
        puck2D.puckBearingSource = .heading
        puck2D.isActive = true
        updateLocation(with: .fullAccuracy)

        let newLocation = updateLocation(with: .fullAccuracy, heading: nil)

        let expectedProperties: [LocationIndicatorLayer.PaintCodingKeys: Any] = [
            .location: [
                newLocation.coordinate.latitude,
                newLocation.coordinate.longitude,
                newLocation.altitude],
            .accuracyRadius: newLocation.horizontalAccuracy,
            .bearing: 0
        ]

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        let invocation = try XCTUnwrap(style.setLayerPropertiesStub.invocations.first)
        XCTAssertEqual(invocation.parameters.layerId, "puck")
        XCTAssertEqual(invocation.parameters.properties as NSDictionary,
                       expectedProperties.mapKeys(\.rawValue) as NSDictionary)
    }

    func testFastPathFullAccuracyWithoutAccuracyRingNilHeading() throws {
        configuration.showsAccuracyRing = false
        recreatePuck()
        puck2D.puckBearingSource = .heading
        puck2D.isActive = true
        updateLocation(with: .fullAccuracy)

        let newLocation = updateLocation(with: .fullAccuracy, heading: nil)

        let expectedProperties: [LocationIndicatorLayer.PaintCodingKeys: Any] = [
            .location: [
                newLocation.coordinate.latitude,
                newLocation.coordinate.longitude,
                newLocation.altitude],
            .bearing: 0
        ]

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        let invocation = try XCTUnwrap(style.setLayerPropertiesStub.invocations.first)
        XCTAssertEqual(invocation.parameters.layerId, "puck")
        XCTAssertEqual(invocation.parameters.properties as NSDictionary,
                       expectedProperties.mapKeys(\.rawValue) as NSDictionary)
    }

    func testFastPathFullAccuracyWithoutAccuracyRingNonNilHeading() throws {
        configuration.showsAccuracyRing = false
        recreatePuck()
        puck2D.puckBearingSource = .heading
        puck2D.isActive = true
        updateLocation(with: .fullAccuracy)

        let heading = CLLocationDirection.random(in: 0..<360)
        let newLocation = updateLocation(with: .fullAccuracy, heading: heading)

        let expectedProperties: [LocationIndicatorLayer.PaintCodingKeys: Any] = [
            .location: [
                newLocation.coordinate.latitude,
                newLocation.coordinate.longitude,
                newLocation.altitude],
            .bearing: heading
        ]

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        let invocation = try XCTUnwrap(style.setLayerPropertiesStub.invocations.first)
        XCTAssertEqual(invocation.parameters.layerId, "puck")
        XCTAssertEqual(invocation.parameters.properties as NSDictionary,
                       expectedProperties.mapKeys(\.rawValue) as NSDictionary)
    }

    func testFastPathFullAccuracyWithoutAccuracyRingUsingCourse() throws {
        configuration.showsAccuracyRing = false
        recreatePuck()
        puck2D.puckBearingSource = .course
        puck2D.isActive = true
        updateLocation(with: .fullAccuracy)

        let newLocation = updateLocation(with: .fullAccuracy, course: .random(in: 0..<360))

        let expectedProperties: [LocationIndicatorLayer.PaintCodingKeys: Any] = [
            .location: [
                newLocation.coordinate.latitude,
                newLocation.coordinate.longitude,
                newLocation.altitude],
            .bearing: newLocation.course!
        ]

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        let invocation = try XCTUnwrap(style.setLayerPropertiesStub.invocations.first)
        XCTAssertEqual(invocation.parameters.layerId, "puck")
        XCTAssertEqual(invocation.parameters.properties as NSDictionary,
                       expectedProperties.mapKeys(\.rawValue) as NSDictionary)
    }

    func testFastPathReducedAccuracy() throws {
        puck2D.isActive = true
        updateLocation(with: .reducedAccuracy)

        let newLocation = updateLocation(with: .reducedAccuracy)

        let expectedProperties: [LocationIndicatorLayer.PaintCodingKeys: Any] = [
            .location: [
                newLocation.coordinate.latitude,
                newLocation.coordinate.longitude,
                newLocation.altitude]
        ]

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        let invocation = try XCTUnwrap(style.setLayerPropertiesStub.invocations.first)
        XCTAssertEqual(invocation.parameters.layerId, "puck")
        XCTAssertEqual(invocation.parameters.properties as NSDictionary,
                       expectedProperties.mapKeys(\.rawValue) as NSDictionary)
    }

    func testInitialDisplayLinkCallbackNotUpdatingLayer() {
        configuration = Puck2DConfiguration(pulsing: .default)
        style.layerExistsStub.defaultReturnValue = true
        displayLinkCoordinator = MockDisplayLinkCoordinator()
        recreatePuck()
        puck2D.isActive = true
        updateLocation()
        style.setLayerPropertiesStub.reset()

        puck2D.participate()

        XCTAssertTrue(style.setLayerPropertiesStub.invocations.isEmpty)
    }

    func testPulsingAnimationDuration() throws {
        let expectedColor: UIColor = .random()
        let expectedRadius: Double = 100
        configuration = Puck2DConfiguration(pulsing: .init(color: expectedColor, radius: .constant(expectedRadius)))
        style.layerExistsStub.defaultReturnValue = true
        displayLinkCoordinator = MockDisplayLinkCoordinator()
        recreatePuck()
        puck2D.isActive = true
        updateLocation()
        puck2D.participate()
        style.setLayerPropertiesStub.reset()

        timeProvider.currentStub.defaultReturnValue = 3
        puck2D.participate()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        let radius = try XCTUnwrap(
            style.setLayerPropertiesStub.invocations.first?
                .parameters.properties[LocationIndicatorLayer.PaintCodingKeys.emphasisCircleRadius.rawValue] as? Double
        )
        let color = try XCTUnwrap(
            style.setLayerPropertiesStub.invocations.first?
                .parameters.properties[LocationIndicatorLayer.PaintCodingKeys.emphasisCircleColor.rawValue] as? String
        )
        XCTAssertEqual(StyleColor(expectedColor.withAlphaComponent(0)).rgbaString, color)
        XCTAssertEqual(expectedRadius, radius)
    }

    func testPulsingAnimationMidway() throws {
        let curve = UnitBezier(p1: .zero, p2: CGPoint(x: 0.25, y: 1))
        let curvedProgress = curve.solve(0.5, 1e-6)
        let expectedColor: UIColor = .random()
        let expectedRadius: Double = 30
        configuration = Puck2DConfiguration(pulsing: .init(color: expectedColor, radius: .constant(expectedRadius)))
        style.layerExistsStub.defaultReturnValue = true
        displayLinkCoordinator = MockDisplayLinkCoordinator()
        recreatePuck()
        puck2D.isActive = true
        updateLocation()
        puck2D.participate()
        style.setLayerPropertiesStub.reset()

        timeProvider.currentStub.defaultReturnValue = 1.5
        puck2D.participate()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        let radius = try XCTUnwrap(
            style.setLayerPropertiesStub.invocations.first?
                .parameters.properties[LocationIndicatorLayer.PaintCodingKeys.emphasisCircleRadius.rawValue] as? Double
        )
        let color = try XCTUnwrap(
            style.setLayerPropertiesStub.invocations.first?
                .parameters.properties[LocationIndicatorLayer.PaintCodingKeys.emphasisCircleColor.rawValue] as? String
        )
        XCTAssertEqual(StyleColor(expectedColor.withAlphaComponent(1 - curvedProgress)).rgbaString, color)
        XCTAssertEqual(expectedRadius * curvedProgress, radius)
    }

    func testPulsingCyclesOver() throws {
        let expectedColor: UIColor = .random()
        let expectedRadius: Double = 100
        let curve = UnitBezier(p1: .zero, p2: CGPoint(x: 0.25, y: 1))
        let curvedProgress = curve.solve(0.5, 1e-6)
        configuration = Puck2DConfiguration(pulsing: .init(color: expectedColor, radius: .constant(expectedRadius)))
        style.layerExistsStub.defaultReturnValue = true
        displayLinkCoordinator = MockDisplayLinkCoordinator()
        recreatePuck()
        puck2D.isActive = true
        updateLocation()
        puck2D.participate()
        style.setLayerPropertiesStub.reset()

        timeProvider.currentStub.defaultReturnValue = 3
        puck2D.participate()

        timeProvider.currentStub.defaultReturnValue = 4.5
        puck2D.participate()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        let radius = try XCTUnwrap(
            style.setLayerPropertiesStub.invocations.last?
                .parameters.properties[LocationIndicatorLayer.PaintCodingKeys.emphasisCircleRadius.rawValue] as? Double
        )
        let color = try XCTUnwrap(
            style.setLayerPropertiesStub.invocations.last?
                .parameters.properties[LocationIndicatorLayer.PaintCodingKeys.emphasisCircleColor.rawValue] as? String
        )
        XCTAssertEqual(StyleColor(expectedColor.withAlphaComponent(1 - curvedProgress)).rgbaString, color)
        XCTAssertEqual(expectedRadius * curvedProgress, radius)
    }

    func testPulsingAnimationUsesAccuracyRadius() throws {
        let expectedColor: UIColor = .random()
        let coordinate: CLLocationCoordinate2D = .random()
        let horizontalAccuracy: CLLocationAccuracy = .random(in: 500...10000)
        let expectedRadius: Double = horizontalAccuracy / Projection.metersPerPoint(for: coordinate.latitude, zoom: mapboxMap.cameraState.zoom)
        configuration = Puck2DConfiguration(pulsing: .init(color: expectedColor, radius: .accuracy))
        style.layerExistsStub.defaultReturnValue = true
        displayLinkCoordinator = MockDisplayLinkCoordinator()
        recreatePuck()
        puck2D.isActive = true
        updateLocation(coordinate: coordinate, horizontalAccuracy: horizontalAccuracy)
        puck2D.participate()
        style.setLayerPropertiesStub.reset()

        timeProvider.currentStub.defaultReturnValue = 3
        puck2D.participate()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        let radius = try XCTUnwrap(
            style.setLayerPropertiesStub.invocations.first?
                .parameters.properties[LocationIndicatorLayer.PaintCodingKeys.emphasisCircleRadius.rawValue] as? Double
        )
        let color = try XCTUnwrap(
            style.setLayerPropertiesStub.invocations.first?
                .parameters.properties[LocationIndicatorLayer.PaintCodingKeys.emphasisCircleColor.rawValue] as? String
        )
        XCTAssertEqual(StyleColor(expectedColor.withAlphaComponent(0)).rgbaString, color)
        XCTAssertEqual(expectedRadius, radius)
    }
}
