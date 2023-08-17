import XCTest
@testable import MapboxMaps

final class Puck2DRendererTests: XCTestCase {
    var configuration: Puck2DConfiguration!
    var style: MockStyle!
    var puckRenderDataSubject: CurrentValueSignalSubject<PuckRenderingData?>!
    var puck2D: Puck2DRenderer!
    var mapboxMap: MockMapboxMap!
    var renderDataObserved = false
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
        puckRenderDataSubject = .init()
        puckRenderDataSubject.onObserved = { [weak self] in self?.renderDataObserved = $0 }
        mapboxMap = MockMapboxMap()
        timeProvider = MockTimeProvider()
        recreatePuck()
    }

    override func tearDown() {
        puck2D = nil
        puckRenderDataSubject = nil
        style = nil
        mapboxMap = nil
        configuration = nil
        timeProvider = nil
        renderDataObserved = false
        super.tearDown()
    }

    private func triggerRendering() {
        // Setting value will result in new data event which triggers rendering.
        puckRenderDataSubject.value = puckRenderDataSubject.value
    }

    func recreatePuck() {
        puck2D = Puck2DRenderer(
            configuration: configuration,
            style: style,
            renderingData: puckRenderDataSubject.signal.skipNil(),
            mapboxMap: mapboxMap,
            timeProvider: timeProvider)
    }

    @discardableResult
    func updateRenderingData(with accuracyAuthorization: CLAccuracyAuthorization = .random(),
                             course: CLLocationDirection? = .random(.random(in: 0..<360)),
                             heading: CLLocationDirection? = .random(.random(in: 0..<360)),
                             coordinate: CLLocationCoordinate2D = .random(),
                             horizontalAccuracy: CLLocationAccuracy = .random(in: 0...100)
    ) -> PuckRenderingData {
        let location = Location(
            coordinate: coordinate,
            timestamp: Date(),
            altitude: .random(in: 0..<360),
            horizontalAccuracy: horizontalAccuracy,
            verticalAccuracy: .random(in: 0...100),
            speed: 0,
            speedAccuracy: 0,
            bearing: course,
            bearingAccuracy: .random(in: 0..<360),
            floor: 0,
            source: nil,
            extra: Location.makeExtra(for: accuracyAuthorization))
        let data = PuckRenderingData(
            location: location,
            heading: heading.map { Heading(direction: $0,
                                           accuracy: .random(in: 0..<360)) }
        )
        puckRenderDataSubject.value = data
        return data
    }

    func testDefaultPropertyValues() {
        XCTAssertFalse(puck2D.isActive)
        XCTAssertEqual(puck2D.puckBearing, .heading)
        XCTAssertEqual(puck2D.puckBearingEnabled, true)
    }

    func testActivatingPuckBeginsAndsStopsObserving() throws {
        XCTAssertEqual(renderDataObserved, false, "no observing by default")

        puck2D.isActive = true
        XCTAssertEqual(renderDataObserved, true, "starts observing upon activation")

        puck2D.isActive = false
        XCTAssertEqual(renderDataObserved, false, "stops observing upon deactivation")
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
        updateRenderingData()

        verifyAddImages()
    }

    func testActivatingPuckAddsImagesIfLatestLocationIsNonNil() {
        updateRenderingData()

        puck2D.isActive = true

        verifyAddImages()
    }

    func testAddsDefaultImagesWhenConfigurationImagesAreNil() {
        configuration = Puck2DConfiguration(
            topImage: nil,
            bearingImage: nil,
            shadowImage: nil)
        recreatePuck()
        updateRenderingData()

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

    func makeExpectedLayerProperties(with data: PuckRenderingData) -> [String: Any] {
        var expectedLayoutLayerProperties = [LocationIndicatorLayer.LayoutCodingKeys: Any]()
        expectedLayoutLayerProperties[.topImage] = "locationIndicatorLayerTopImage"
        expectedLayoutLayerProperties[.bearingImage] = "locationIndicatorLayerBearingImage"
        expectedLayoutLayerProperties[.shadowImage] = "locationIndicatorLayerShadowImage"

        let resolvedScale = configuration.scale ?? .constant(1)
        let scale = try! resolvedScale.toJSON()

        var expectedPaintLayerProperties = [LocationIndicatorLayer.PaintCodingKeys: Any]()
        expectedPaintLayerProperties[.location] = [data.location.coordinate.latitude, data.location.coordinate.longitude, 0]
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
        let data = updateRenderingData(with: .fullAccuracy, heading: nil)
        style.layerExistsStub.defaultReturnValue = false

        puck2D.isActive = true

        let expectedProperties = makeExpectedLayerProperties(with: data)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 1)
        let actualProperties = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.invocations.first?.parameters.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.first?.parameters.layerPosition, nil)
    }

    func testReactivatingPuckDoesNotTakeFastPath() throws {
        let data = updateRenderingData(with: .fullAccuracy, heading: nil)
        style.layerExistsStub.defaultReturnValue = false
        puck2D.isActive = true
        puck2D.isActive = false
        style.addPersistentLayerWithPropertiesStub.reset()
        style.setLayerPropertiesStub.reset()

        puck2D.isActive = true

        let expectedProperties = makeExpectedLayerProperties(with: data)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 1)
        let actualProperties = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.invocations.first).parameters.properties
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.first?.parameters.layerPosition, nil)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 0)
    }

    func testActivatingPuckWithNilImages() throws {
        configuration.shadowImage = nil
        configuration.topImage = nil
        configuration.bearingImage = nil
        recreatePuck()
        let data = updateRenderingData(with: .fullAccuracy, heading: nil)
        style.layerExistsStub.defaultReturnValue = false

        puck2D.isActive = true

        var expectedProperties = makeExpectedLayerProperties(with: data)
        expectedProperties.removeValue(forKey: LocationIndicatorLayer.LayoutCodingKeys.bearingImage.rawValue)
        let actualProperties = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.invocations.first?.parameters.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
    }

    func testActivatingPuckWithNilScale() throws {
        configuration.scale = nil
        recreatePuck()
        let data = updateRenderingData(with: .fullAccuracy, heading: nil)
        style.layerExistsStub.defaultReturnValue = false

        puck2D.isActive = true

        let expectedProperties = makeExpectedLayerProperties(with: data)
        let actualProperties = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.invocations.first?.parameters.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
    }

    func testActivatingPuckWithShowsAccuracyRingTrue() throws {
        configuration.showsAccuracyRing = true
        recreatePuck()
        let data = updateRenderingData(with: .fullAccuracy, heading: nil)
        style.layerExistsStub.defaultReturnValue = false

        puck2D.isActive = true

        var expectedProperties = makeExpectedLayerProperties(with: data)
        expectedProperties["accuracy-radius"] = data.location.horizontalAccuracy
        expectedProperties["accuracy-radius-color"] = StyleColor(UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)).rgbaString
        expectedProperties["accuracy-radius-border-color"] = StyleColor(UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)).rgbaString
        let actualProperties = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.invocations.first?.parameters.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
    }

    func testActivatingPuckWithNonNilHeading() throws {
        let data = updateRenderingData(with: .fullAccuracy, heading: .random(in: 0..<360))
        style.layerExistsStub.defaultReturnValue = false

        puck2D.isActive = true

        var expectedProperties = makeExpectedLayerProperties(with: data)
        expectedProperties["bearing"] = data.heading!.direction
        let actualProperties = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.invocations.first?.parameters.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
    }

    func testActivatingPuckWithBearingDisabledForHeading() throws {
        let data = updateRenderingData(with: .fullAccuracy, heading: .random(in: 0..<360))
        style.layerExistsStub.defaultReturnValue = false
        puck2D.puckBearingEnabled = false
        puck2D.isActive = true

        var expectedProperties = makeExpectedLayerProperties(with: data)
        expectedProperties.removeValue(forKey: "bearing")
        let actualProperties = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.invocations.first?.parameters.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
    }

    func testActivatingPuckWithBearingDisabledForCourse() throws {
        let data = updateRenderingData(with: .fullAccuracy, course: .random(in: 0..<360))
        style.layerExistsStub.defaultReturnValue = false
        puck2D.puckBearingEnabled = false

        puck2D.isActive = true

        var expectedProperties = makeExpectedLayerProperties(with: data)
        expectedProperties.removeValue(forKey: "bearing")
        let actualProperties = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.invocations.first?.parameters.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
    }

    func testActivatingPuckWithPuckBearingSetToCourse() throws {
        let data = updateRenderingData(with: .fullAccuracy, course: .random(in: 0..<360))
        style.layerExistsStub.defaultReturnValue = false
        puck2D.puckBearing = .course

        puck2D.isActive = true

        var expectedProperties = makeExpectedLayerProperties(with: data)
        expectedProperties["bearing"] = data.location.bearing
        let actualProperties = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.invocations.first?.parameters.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
    }

    func testActivatingPuckWithPuckBearingSetToCourseWithNilCourse() throws {
        updateRenderingData(with: .fullAccuracy, course: .random(in: 0..<360))
        style.layerExistsStub.defaultReturnValue = false
        puck2D.puckBearing = .course

        puck2D.isActive = true
        let data = updateRenderingData(with: .fullAccuracy, course: nil)

        let expectedProperties: [LocationIndicatorLayer.PaintCodingKeys: Any] = [
            .location: [
                data.location.coordinate.latitude,
                data.location.coordinate.longitude,
                0],
            .bearing: 0
        ]

        let actualProperties = try XCTUnwrap(style.setLayerPropertiesStub.invocations.last?.parameters.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties.mapKeys(\.rawValue) as NSDictionary)
    }

    func testActivatingPuckWithPuckBearingSetToHeadingWithNilHeading() throws {
        updateRenderingData(with: .fullAccuracy, heading: .random(in: 0..<360))
        style.layerExistsStub.defaultReturnValue = false
        puck2D.puckBearing = .heading

        puck2D.isActive = true
        let data = updateRenderingData(with: .fullAccuracy, heading: nil)

        let expectedProperties: [LocationIndicatorLayer.PaintCodingKeys: Any] = [
            .location: [
                data.location.coordinate.latitude,
                data.location.coordinate.longitude,
                0],
            .bearing: 0
        ]

        let actualProperties = try XCTUnwrap(style.setLayerPropertiesStub.invocations.last?.parameters.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties.mapKeys(\.rawValue) as NSDictionary)
    }

    func testActivatingPuckWithReducedAccuracy() throws {
        let coordinate: CLLocationCoordinate2D = .random()
        let accuracy: CLLocationAccuracy = .random(in: 1_000..<20_000)
        let zoomCutoffRange: ClosedRange<Double> = 4.0...7.5
        let accuracyRange: ClosedRange<CLLocationDistance> = 1000...20_000
        let cutoffZoomLevel = zoomCutoffRange.upperBound - (zoomCutoffRange.magnitude * (accuracy - accuracyRange.lowerBound) / accuracyRange.magnitude)
        let minPuckRadiusInPoints = 11.0
        let minPuckRadiusInMeters = minPuckRadiusInPoints * Projection.metersPerPoint(for: coordinate.latitude, zoom: cutoffZoomLevel)
        let data = updateRenderingData(
            with: .reducedAccuracy,
            heading: .random(in: 0..<360),
            coordinate: coordinate,
            horizontalAccuracy: accuracy
        )
        style.layerExistsStub.defaultReturnValue = false

        puck2D.isActive = true

        var expectedProperties = [String: Any]()
        expectedProperties["id"] = "puck"
        expectedProperties["type"] = "location-indicator"
        expectedProperties["location"] = [
            data.location.coordinate.latitude,
            data.location.coordinate.longitude,
            0
        ]
        expectedProperties["accuracy-radius"] = [
            "interpolate",
            ["linear"],
            ["zoom"],
            cutoffZoomLevel,
            minPuckRadiusInMeters,
            cutoffZoomLevel + 1,
            accuracy] as [Any]
        expectedProperties["accuracy-radius-color"] = [
            "step",
            ["zoom"],
            StyleColor(UIColor.clear).rgbaString,
            cutoffZoomLevel,
            StyleColor(UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)).rgbaString
        ] as [Any]
        expectedProperties["accuracy-radius-border-color"] = [
            "step",
            ["zoom"],
            StyleColor(UIColor.clear).rgbaString,
            cutoffZoomLevel,
            StyleColor(UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)).rgbaString
        ] as [Any]
        expectedProperties["emphasis-circle-color"] = [
            "step",
            ["zoom"],
            StyleColor(UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)).rgbaString,
            cutoffZoomLevel,
            StyleColor(UIColor.clear).rgbaString
        ] as [Any]
        expectedProperties["emphasis-circle-radius"] = 11
        expectedProperties["emphasis-circle-color"] = [
            "step",
            ["zoom"],
            StyleColor(UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)).rgbaString,
            cutoffZoomLevel,
            StyleColor(UIColor.clear).rgbaString
        ] as [Any]
        let actualProperties = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.invocations.first?.parameters.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
    }

    func testResetsPropertiesToDefaultValues() throws {
        let originalLocation = updateRenderingData(with: .fullAccuracy, heading: nil)
        puck2D.isActive = true
        style.layerExistsStub.defaultReturnValue = true
        var originalKeys = Set(makeExpectedLayerProperties(with: originalLocation).keys)
        originalKeys.remove("id")
        originalKeys.remove("type")

        // there are a bunch of properties that aren't used in "reduced" mode
        // and they should be reset to their default values if the layer already
        // existed
        let coordinate: CLLocationCoordinate2D = .random()
        let accuracy: CLLocationAccuracy = .random(in: 1_000..<20_000)
        let zoomCutoffRange: ClosedRange<Double> = 4.0...7.5
        let accuracyRange: ClosedRange<CLLocationDistance> = 1000...20_000
        let cutoffZoomLevel = zoomCutoffRange.upperBound - (zoomCutoffRange.magnitude * (accuracy - accuracyRange.lowerBound) / accuracyRange.magnitude)
        let minPuckRadiusInPoints = 11.0
        let minPuckRadiusInMeters = minPuckRadiusInPoints * Projection.metersPerPoint(for: coordinate.latitude, zoom: cutoffZoomLevel)
        let data = updateRenderingData(
            with: .reducedAccuracy,
            heading: nil,
            coordinate: coordinate,
            horizontalAccuracy: accuracy
        )

        var expectedProperties = [String: Any]()
        expectedProperties["location"] = [
            data.location.coordinate.latitude,
            data.location.coordinate.longitude,
            0
        ]
        expectedProperties["accuracy-radius"] = [
            "interpolate",
            ["linear"],
            ["zoom"],
            cutoffZoomLevel,
            minPuckRadiusInMeters,
            cutoffZoomLevel + 1,
            accuracy] as [Any]
        expectedProperties["accuracy-radius-color"] = [
            "step",
            ["zoom"],
            StyleColor(UIColor.clear).rgbaString,
            cutoffZoomLevel,
            StyleColor(UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)).rgbaString
        ] as [Any]
        expectedProperties["accuracy-radius-border-color"] = [
            "step",
            ["zoom"],
            StyleColor(UIColor.clear).rgbaString,
            cutoffZoomLevel,
            StyleColor(UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)).rgbaString
        ] as [Any]
        expectedProperties["emphasis-circle-color"] = [
            "step",
            ["zoom"],
            StyleColor(UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)).rgbaString,
            cutoffZoomLevel,
            StyleColor(UIColor.clear).rgbaString
        ] as [Any]
        expectedProperties["emphasis-circle-radius"] = 11
        expectedProperties["emphasis-circle-color"] = [
            "step",
            ["zoom"],
            StyleColor(UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)).rgbaString,
            cutoffZoomLevel,
            StyleColor(UIColor.clear).rgbaString
        ] as [Any]
        for key in originalKeys where expectedProperties[key] == nil {
            expectedProperties[key] = StyleManager.layerPropertyDefaultValue(for: .locationIndicator, property: key).value
        }
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        let actualProperties = try XCTUnwrap(style.setLayerPropertiesStub.invocations.first?.parameters.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
    }

    func testSettingPuckBearingWhenInactive() {
        updateRenderingData()
        style.layerExistsStub.defaultReturnValue = false
        puck2D.isActive = false

        puck2D.puckBearing = [.heading, .course].randomElement()!

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 0)
    }

    func testLocationUpdateWhenActive() {
        updateRenderingData()
        puck2D.isActive = true
        style.layerExistsStub.defaultReturnValue = true

        updateRenderingData()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
    }

    func testFastPathFullAccuracyWithAccuracyRingNilHeading() throws {
        configuration.showsAccuracyRing = true
        recreatePuck()
        puck2D.puckBearing = .heading
        puck2D.isActive = true
        updateRenderingData(with: .fullAccuracy)

        let data = updateRenderingData(with: .fullAccuracy, heading: nil)

        let expectedProperties: [LocationIndicatorLayer.PaintCodingKeys: Any] = [
            .location: [
                data.location.coordinate.latitude,
                data.location.coordinate.longitude,
                0],
            .accuracyRadius: data.location.horizontalAccuracy ?? 0,
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
        puck2D.puckBearing = .heading
        puck2D.isActive = true
        updateRenderingData(with: .fullAccuracy)

        let data = updateRenderingData(with: .fullAccuracy, heading: nil)

        let expectedProperties: [LocationIndicatorLayer.PaintCodingKeys: Any] = [
            .location: [
                data.location.coordinate.latitude,
                data.location.coordinate.longitude,
                0],
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
        puck2D.puckBearing = .heading
        puck2D.isActive = true
        updateRenderingData(with: .fullAccuracy)

        let heading = CLLocationDirection.random(in: 0..<360)
        let data = updateRenderingData(with: .fullAccuracy, heading: heading)

        let expectedProperties: [LocationIndicatorLayer.PaintCodingKeys: Any] = [
            .location: [
                data.location.coordinate.latitude,
                data.location.coordinate.longitude,
                0],
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
        puck2D.puckBearing = .course
        puck2D.isActive = true
        updateRenderingData(with: .fullAccuracy)

        let data = updateRenderingData(with: .fullAccuracy, course: .random(in: 0..<360))

        let expectedProperties: [LocationIndicatorLayer.PaintCodingKeys: Any] = [
            .location: [
                data.location.coordinate.latitude,
                data.location.coordinate.longitude,
                0],
            .bearing: data.location.bearing!
        ]

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        let invocation = try XCTUnwrap(style.setLayerPropertiesStub.invocations.first)
        XCTAssertEqual(invocation.parameters.layerId, "puck")
        XCTAssertEqual(invocation.parameters.properties as NSDictionary,
                       expectedProperties.mapKeys(\.rawValue) as NSDictionary)
    }

    func testFastPathReducedAccuracy() throws {
        puck2D.isActive = true
        updateRenderingData(with: .reducedAccuracy)

        let data = updateRenderingData(with: .reducedAccuracy)

        let expectedProperties: [LocationIndicatorLayer.PaintCodingKeys: Any] = [
            .location: [
                data.location.coordinate.latitude,
                data.location.coordinate.longitude,
                0]
        ]

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        let invocation = try XCTUnwrap(style.setLayerPropertiesStub.invocations.first)
        XCTAssertEqual(invocation.parameters.layerId, "puck")
        XCTAssertEqual(invocation.parameters.properties as NSDictionary,
                       expectedProperties.mapKeys(\.rawValue) as NSDictionary)
    }

    func testPulsingAnimationDuration() throws {
        let expectedColor: UIColor = .random()
        let expectedRadius: Double = 100
        configuration = Puck2DConfiguration(pulsing: .init(color: expectedColor, radius: .constant(expectedRadius)))
        style.layerExistsStub.defaultReturnValue = true
        recreatePuck()
        puck2D.isActive = true
        updateRenderingData()
        style.setLayerPropertiesStub.reset()

        timeProvider.currentStub.defaultReturnValue = 3
        triggerRendering()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        let radius = try XCTUnwrap(
            style.setLayerPropertiesStub.invocations.last?
                .parameters.properties[LocationIndicatorLayer.PaintCodingKeys.emphasisCircleRadius.rawValue] as? Double
        )
        let color = try XCTUnwrap(
            style.setLayerPropertiesStub.invocations.last?
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
        recreatePuck()
        puck2D.isActive = true
        updateRenderingData()

        style.setLayerPropertiesStub.reset()

        timeProvider.currentStub.defaultReturnValue = 1.5
        triggerRendering()

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

    func testPulsingCyclesOver() throws {
        let expectedColor: UIColor = .random()
        let expectedRadius: Double = 100
        let curve = UnitBezier(p1: .zero, p2: CGPoint(x: 0.25, y: 1))
        let curvedProgress = curve.solve(0.5, 1e-6)
        configuration = Puck2DConfiguration(pulsing: .init(color: expectedColor, radius: .constant(expectedRadius)))
        style.layerExistsStub.defaultReturnValue = true
        recreatePuck()
        puck2D.isActive = true
        updateRenderingData()

        style.setLayerPropertiesStub.reset()

        timeProvider.currentStub.defaultReturnValue = 3
        triggerRendering()

        timeProvider.currentStub.defaultReturnValue = 4.5
        triggerRendering()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 4)
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
        recreatePuck()
        puck2D.isActive = true
        updateRenderingData(coordinate: coordinate, horizontalAccuracy: horizontalAccuracy)

        style.setLayerPropertiesStub.reset()

        timeProvider.currentStub.defaultReturnValue = 3
        triggerRendering()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        let radius = try XCTUnwrap(
            style.setLayerPropertiesStub.invocations.last?
                .parameters.properties[LocationIndicatorLayer.PaintCodingKeys.emphasisCircleRadius.rawValue] as? Double
        )
        let color = try XCTUnwrap(
            style.setLayerPropertiesStub.invocations.last?
                .parameters.properties[LocationIndicatorLayer.PaintCodingKeys.emphasisCircleColor.rawValue] as? String
        )
        XCTAssertEqual(StyleColor(expectedColor.withAlphaComponent(0)).rgbaString, color)
        XCTAssertEqual(expectedRadius, radius)
    }
}
