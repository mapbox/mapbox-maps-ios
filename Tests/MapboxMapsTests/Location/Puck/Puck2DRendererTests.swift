import XCTest
@testable import MapboxMaps

final class Puck2DRendererTests: XCTestCase {
    var style: MockStyle!
    var puck2D: Puck2DRenderer!
    var mapboxMap: MockMapboxMap!
    var timeProvider: MockTimeProvider!
    @TestSignal var displayLink: Signal<Void>

    override func setUp() {
        super.setUp()
        style = MockStyle()
        mapboxMap = MockMapboxMap()
        timeProvider = MockTimeProvider()
        recreatePuck()
    }

    func recreatePuck() {
        puck2D = Puck2DRenderer(
            style: style,
            mapboxMap: mapboxMap,
            displayLink: displayLink,
            timeProvider: timeProvider
        )
    }

    override func tearDown() {
        puck2D = nil
        style = nil
        mapboxMap = nil
        timeProvider = nil
        super.tearDown()
    }

    @discardableResult
    func updateState(
        with accuracyAuthorization: CLAccuracyAuthorization = .random(),
        course: CLLocationDirection? = .random(.random(in: 0..<360)),
        heading: CLLocationDirection? = .random(.random(in: 0..<360)),
        coordinate: CLLocationCoordinate2D = .random(),
        horizontalAccuracy: CLLocationAccuracy = .random(in: 0...100),
        puckBearingEnabled: Bool = false,
        puckBearing: PuckBearing = .course,
        configuration: Puck2DConfiguration = .makeDefault(showBearing: true)
    ) -> PuckRendererState<Puck2DConfiguration> {
        let state = PuckRendererState(
            coordinate: coordinate,
            horizontalAccuracy: horizontalAccuracy,
            accuracyAuthorization: accuracyAuthorization,
            bearing: course,
            heading: heading.map { Heading(direction: $0, accuracy: .random(in: 0..<360)) },
            configuration: configuration,
            bearingEnabled: puckBearingEnabled,
            bearingType: puckBearing
        )
        puck2D.state = state
        return state
    }

    func testDefaultPropertyValues() {
        XCTAssertEqual(puck2D.state, nil)
    }

    func testLayerAndImagesAreNotAddedAtInitialization() {
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 0)
        XCTAssertEqual(style.addImageStub.invocations.count, 0)
    }

    func verifyAddImages(
        from configuration: Puck2DConfiguration,
        file: StaticString = #file,
        line: UInt = #line
    ) {
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

    func testAddsDefaultImagesWhenConfigurationImagesAreNil() {
        updateState(configuration: Puck2DConfiguration(topImage: nil, bearingImage: nil, shadowImage: nil))

        XCTAssertEqual(style.addImageStub.invocations.count, 1)

        XCTAssertEqual(style.addImageStub.invocations[0].parameters.id, "locationIndicatorLayerTopImage")
        let expectedTopImage = UIImage(named: "location-dot-inner", in: .mapboxMaps, compatibleWith: nil)!
        XCTAssertTrue(style.addImageStub.invocations[0].parameters.image.isEqual(expectedTopImage))
    }

    func testUpdateImages() {
        var configuration = Puck2DConfiguration(topImage: .empty, bearingImage: .empty, shadowImage: .empty)
        updateState(configuration: configuration)

        verifyAddImages(from: configuration)

        style.addImageStub.reset()
        style.imageExistsStub.defaultReturnValue = true
        let newTopImage = UIImage.empty
        configuration.topImage = newTopImage
        configuration.bearingImage = nil

        updateState(configuration: configuration)

        XCTAssertEqual(style.addImageStub.invocations.count, 1)
        XCTAssertEqual(style.addImageStub.invocations[0].parameters.id, "locationIndicatorLayerTopImage")
        XCTAssertTrue(style.addImageStub.invocations[0].parameters.image.isEqual(newTopImage))

        XCTAssertEqual(style.removeImageStub.invocations.count, 2)
        XCTAssertEqual(style.removeImageStub.invocations[0].parameters, "locationIndicatorLayerTopImage")
        XCTAssertEqual(style.removeImageStub.invocations[1].parameters, "locationIndicatorLayerBearingImage")
    }

    func makeExpectedLayerProperties(
        with state: PuckRendererState<Puck2DConfiguration>,
        bearing: Double? = nil
    ) -> [String: Any] {
        var expectedLayoutLayerProperties = [LocationIndicatorLayer.LayoutCodingKeys: Any]()
        expectedLayoutLayerProperties[.topImage] = "locationIndicatorLayerTopImage"
        if state.configuration.bearingImage != nil {
            expectedLayoutLayerProperties[.bearingImage] = "locationIndicatorLayerBearingImage"
        }
        if state.configuration.shadowImage != nil {
            expectedLayoutLayerProperties[.shadowImage] = "locationIndicatorLayerShadowImage"
        }

        let resolvedScale = state.configuration.scale ?? .constant(1)
        let scale = try! resolvedScale.toJSON()

        var expectedPaintLayerProperties = [LocationIndicatorLayer.PaintCodingKeys: Any]()
        expectedPaintLayerProperties[.location] = [state.coordinate.latitude, state.coordinate.longitude, 0]
        expectedPaintLayerProperties[.locationTransition] = ["duration": 0, "delay": 0]
        expectedPaintLayerProperties[.topImageSize] = scale
        expectedPaintLayerProperties[.bearingImageSize] = scale
        expectedPaintLayerProperties[.shadowImageSize] = scale
        expectedPaintLayerProperties[.emphasisCircleRadiusTransition] = ["duration": 0, "delay": 0]
        expectedPaintLayerProperties[.bearingTransition] = ["duration": 0, "delay": 0]
        expectedPaintLayerProperties[.bearing] = bearing
        expectedPaintLayerProperties[.locationIndicatorOpacity] = state.configuration.opacity
        expectedPaintLayerProperties[.locationIndicatorOpacityTransition] = ["duration": 0, "delay": 0]

        var expectedProperties = expectedLayoutLayerProperties
            .mapKeys(\.rawValue)
            .merging(
                expectedPaintLayerProperties.mapKeys(\.rawValue),
                uniquingKeysWith: { $1 })

        expectedProperties["id"] = "puck"
        expectedProperties["type"] = "location-indicator"

        if let slot = state.configuration.slot?.rawValue {
            expectedProperties["slot"] = slot
        }

        return expectedProperties
    }

    func testActivatingPuckAddsLayerIfLatestLocationIsNonNil() throws {
        let state = updateState(with: .fullAccuracy, heading: nil)
        style.layerExistsStub.defaultReturnValue = false

        let expectedProperties = makeExpectedLayerProperties(with: state)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 1)
        let actualProperties = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.invocations.first?.parameters.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.first?.parameters.layerPosition, nil)
    }

    func testReactivatingPuckDoesNotTakeFastPath() throws {
        style.layerExistsStub.defaultReturnValue = false

        let state = updateState(with: .fullAccuracy, heading: nil)
        puck2D.state = nil

        style.addPersistentLayerWithPropertiesStub.reset()
        style.setLayerPropertiesStub.reset()

        puck2D.state = state

        let expectedProperties = makeExpectedLayerProperties(with: state)
        XCTAssertEqual(style.addPersistentLayerStub.invocations.count, 0)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.count, 1)
        let actualProperties = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.invocations.first).parameters.properties
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
        XCTAssertEqual(style.addPersistentLayerWithPropertiesStub.invocations.first?.parameters.layerPosition, nil)
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 0)
    }

    func testActivatingPuckWithNilImages() throws {
        style.layerExistsStub.defaultReturnValue = false
        let state = updateState(with: .fullAccuracy, heading: nil, configuration: .init(topImage: nil, bearingImage: nil, shadowImage: nil))

        var expectedProperties = makeExpectedLayerProperties(with: state)
        expectedProperties.removeValue(forKey: LocationIndicatorLayer.LayoutCodingKeys.bearingImage.rawValue)
        let actualProperties = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.invocations.first?.parameters.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
    }

    func testActivatingPuckWithNilScale() throws {
        style.layerExistsStub.defaultReturnValue = false
        let state = updateState(with: .fullAccuracy, heading: nil, configuration: .init(scale: nil))

        let expectedProperties = makeExpectedLayerProperties(with: state)
        let actualProperties = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.invocations.first?.parameters.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
    }

    func testActivatingPuckWithShowsAccuracyRingTrue() throws {
        style.layerExistsStub.defaultReturnValue = false
        let state = updateState(with: .fullAccuracy, heading: nil, configuration: .init(showsAccuracyRing: true))

        var expectedProperties = makeExpectedLayerProperties(with: state)
        expectedProperties["accuracy-radius"] = state.horizontalAccuracy
        expectedProperties["accuracy-radius-color"] = StyleColor(UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)).rawValue
        expectedProperties["accuracy-radius-border-color"] = StyleColor(UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)).rawValue
        let actualProperties = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.invocations.first?.parameters.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
    }

    func testActivatingPuckWithBearingDisabledForHeading() throws {
        style.layerExistsStub.defaultReturnValue = false
        let state = updateState(with: .fullAccuracy, heading: .random(in: 0..<360), puckBearingEnabled: false)

        let expectedProperties = makeExpectedLayerProperties(with: state)
        let actualProperties = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.invocations.first?.parameters.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
    }

    func testActivatingPuckWithBearingDisabledForCourse() throws {
        style.layerExistsStub.defaultReturnValue = false
        let state = updateState(with: .fullAccuracy, course: .random(in: 0..<360), puckBearingEnabled: false)

        let expectedProperties = makeExpectedLayerProperties(with: state)
        let actualProperties = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.invocations.first?.parameters.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
    }

    func testActivatingPuckWithPuckBearingSetToCourse() throws {
        style.layerExistsStub.defaultReturnValue = false
        let state = updateState(with: .fullAccuracy, course: .random(in: 0..<360), puckBearingEnabled: true, puckBearing: .course)

        let expectedProperties = makeExpectedLayerProperties(with: state, bearing: state.bearing)
        let actualProperties = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.invocations.first?.parameters.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
    }

    func testActivatingPuckWithPuckBearingSetToCourseWithNilCourse() throws {
        style.layerExistsStub.defaultReturnValue = false
        updateState(with: .fullAccuracy, course: .random(in: 0..<360), puckBearing: .course)
        let state = updateState(with: .fullAccuracy, course: nil, puckBearing: .course)

        let expectedProperties: [LocationIndicatorLayer.PaintCodingKeys: Any] = [
            .location: [state.coordinate.latitude, state.coordinate.longitude, 0]
        ]

        let actualProperties = try XCTUnwrap(style.setLayerPropertiesStub.invocations.last?.parameters.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties.mapKeys(\.rawValue) as NSDictionary)
    }

    func testActivatingPuckWithPuckBearingSetToHeadingWithNilHeading() throws {
        style.layerExistsStub.defaultReturnValue = false
        updateState(with: .fullAccuracy, heading: .random(in: 0..<360), puckBearing: .heading)
        let state = updateState(with: .fullAccuracy, heading: nil, puckBearing: .heading)

        let expectedProperties: [LocationIndicatorLayer.PaintCodingKeys: Any] = [
            .location: [
                state.coordinate.latitude,
                state.coordinate.longitude,
                0]
        ]

        let actualProperties = try XCTUnwrap(style.setLayerPropertiesStub.invocations.last?.parameters.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties.mapKeys(\.rawValue) as NSDictionary)
    }

    func testActivatingPuckWithReducedAccuracy() throws {
        style.layerExistsStub.defaultReturnValue = false
        let coordinate: CLLocationCoordinate2D = .random()
        let accuracy: CLLocationAccuracy = .random(in: 1_000..<20_000)
        let zoomCutoffRange: ClosedRange<Double> = 4.0...7.5
        let accuracyRange: ClosedRange<CLLocationDistance> = 1000...20_000
        let cutoffZoomLevel = zoomCutoffRange.upperBound - (zoomCutoffRange.magnitude * (accuracy - accuracyRange.lowerBound) / accuracyRange.magnitude)
        let minPuckRadiusInPoints = 11.0
        let minPuckRadiusInMeters = minPuckRadiusInPoints * Projection.metersPerPoint(for: coordinate.latitude, zoom: cutoffZoomLevel)
        let state = updateState(
            with: .reducedAccuracy,
            heading: .random(in: 0..<360),
            coordinate: coordinate,
            horizontalAccuracy: accuracy
        )

        var expectedProperties = [String: Any]()
        expectedProperties["id"] = "puck"
        expectedProperties["type"] = "location-indicator"
        expectedProperties["location"] = [state.coordinate.latitude, state.coordinate.longitude, 0]
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
            StyleColor(UIColor.clear).rawValue,
            cutoffZoomLevel,
            StyleColor(UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)).rawValue
        ] as [Any]
        expectedProperties["accuracy-radius-border-color"] = [
            "step",
            ["zoom"],
            StyleColor(UIColor.clear).rawValue,
            cutoffZoomLevel,
            StyleColor(UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)).rawValue
        ] as [Any]
        expectedProperties["emphasis-circle-color"] = [
            "step",
            ["zoom"],
            StyleColor(UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)).rawValue,
            cutoffZoomLevel,
            StyleColor(UIColor.clear).rawValue
        ] as [Any]
        expectedProperties["emphasis-circle-radius"] = 11
        expectedProperties["emphasis-circle-color"] = [
            "step",
            ["zoom"],
            StyleColor(UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)).rawValue,
            cutoffZoomLevel,
            StyleColor(UIColor.clear).rawValue
        ] as [Any]
        let actualProperties = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.invocations.first?.parameters.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
    }

    func testResetsPropertiesToDefaultValues() throws {
        let original = updateState(with: .fullAccuracy, heading: nil)
        style.layerExistsStub.defaultReturnValue = true
        var originalKeys = Set(makeExpectedLayerProperties(with: original).keys)
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
        let state = updateState(
            with: .reducedAccuracy,
            heading: nil,
            coordinate: coordinate,
            horizontalAccuracy: accuracy
        )

        var expectedProperties = [String: Any]()
        expectedProperties["location"] = [
            state.coordinate.latitude,
            state.coordinate.longitude,
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
            StyleColor(UIColor.clear).rawValue,
            cutoffZoomLevel,
            StyleColor(UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)).rawValue
        ] as [Any]
        expectedProperties["accuracy-radius-border-color"] = [
            "step",
            ["zoom"],
            StyleColor(UIColor.clear).rawValue,
            cutoffZoomLevel,
            StyleColor(UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)).rawValue
        ] as [Any]
        expectedProperties["emphasis-circle-color"] = [
            "step",
            ["zoom"],
            StyleColor(UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)).rawValue,
            cutoffZoomLevel,
            StyleColor(UIColor.clear).rawValue
        ] as [Any]
        expectedProperties["emphasis-circle-radius"] = 11
        expectedProperties["emphasis-circle-color"] = [
            "step",
            ["zoom"],
            StyleColor(UIColor(red: 0.537, green: 0.812, blue: 0.941, alpha: 0.3)).rawValue,
            cutoffZoomLevel,
            StyleColor(UIColor.clear).rawValue
        ] as [Any]
        for key in originalKeys where expectedProperties[key] == nil {
            expectedProperties[key] = StyleManager.layerPropertyDefaultValue(for: .locationIndicator, property: key).value
        }
        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        let actualProperties = try XCTUnwrap(style.setLayerPropertiesStub.invocations.first?.parameters.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
    }

    func testFastPathFullAccuracyWithAccuracyRingNilHeading() throws {
        updateState(with: .fullAccuracy, puckBearing: .heading, configuration: .init(showsAccuracyRing: true))
        let state = updateState(with: .fullAccuracy, heading: nil, puckBearing: .heading, configuration: .init(showsAccuracyRing: true))

        let expectedProperties: [LocationIndicatorLayer.PaintCodingKeys: Any] = [
            .location: [state.coordinate.latitude, state.coordinate.longitude, 0],
            .accuracyRadius: state.horizontalAccuracy ?? 0
        ]

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        let invocation = try XCTUnwrap(style.setLayerPropertiesStub.invocations.first)
        XCTAssertEqual(invocation.parameters.layerId, "puck")
        XCTAssertEqual(invocation.parameters.properties as NSDictionary, expectedProperties.mapKeys(\.rawValue) as NSDictionary)
    }

    func testFastPathFullAccuracyWithoutAccuracyRingNilHeading() throws {
        updateState(with: .fullAccuracy, puckBearing: .heading, configuration: .init(showsAccuracyRing: false))
        let state = updateState(with: .fullAccuracy, heading: nil, puckBearing: .heading, configuration: .init(showsAccuracyRing: false))

        let expectedProperties: [LocationIndicatorLayer.PaintCodingKeys: Any] = [
            .location: [state.coordinate.latitude, state.coordinate.longitude, 0]
        ]

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        let invocation = try XCTUnwrap(style.setLayerPropertiesStub.invocations.first)
        XCTAssertEqual(invocation.parameters.layerId, "puck")
        XCTAssertEqual(invocation.parameters.properties as NSDictionary, expectedProperties.mapKeys(\.rawValue) as NSDictionary)
    }

    func testFastPathFullAccuracyWithoutAccuracyRingNonNilHeading() throws {
        let heading = CLLocationDirection.random(in: 0..<360)
        updateState(with: .fullAccuracy, puckBearingEnabled: true, puckBearing: .heading)
        let state = updateState(with: .fullAccuracy, heading: heading, puckBearingEnabled: true, puckBearing: .heading)

        let expectedProperties: [LocationIndicatorLayer.PaintCodingKeys: Any] = [
            .location: [state.coordinate.latitude, state.coordinate.longitude, 0],
            .bearing: heading
        ]

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        let invocation = try XCTUnwrap(style.setLayerPropertiesStub.invocations.first)
        XCTAssertEqual(invocation.parameters.layerId, "puck")
        XCTAssertEqual(invocation.parameters.properties as NSDictionary, expectedProperties.mapKeys(\.rawValue) as NSDictionary)
    }

    func testFastPathFullAccuracyWithoutAccuracyRingUsingCourse() throws {
        updateState(with: .fullAccuracy, puckBearingEnabled: true, puckBearing: .course, configuration: .init(showsAccuracyRing: false))
        let state = updateState(with: .fullAccuracy, course: .random(in: 0..<360), puckBearingEnabled: true, puckBearing: .course, configuration: .init(showsAccuracyRing: false))

        let expectedProperties: [LocationIndicatorLayer.PaintCodingKeys: Any] = [
            .location: [state.coordinate.latitude, state.coordinate.longitude, 0],
            .bearing: state.bearing!
        ]

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        let invocation = try XCTUnwrap(style.setLayerPropertiesStub.invocations.first)
        XCTAssertEqual(invocation.parameters.layerId, "puck")
        XCTAssertEqual(invocation.parameters.properties as NSDictionary, expectedProperties.mapKeys(\.rawValue) as NSDictionary)
    }

    func testFastPathReducedAccuracy() throws {
        updateState(with: .reducedAccuracy)
        let state = updateState(with: .reducedAccuracy)

        let expectedProperties: [LocationIndicatorLayer.PaintCodingKeys: Any] = [
            .location: [state.coordinate.latitude, state.coordinate.longitude, 0]
        ]

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        let invocation = try XCTUnwrap(style.setLayerPropertiesStub.invocations.first)
        XCTAssertEqual(invocation.parameters.layerId, "puck")
        XCTAssertEqual(invocation.parameters.properties as NSDictionary, expectedProperties.mapKeys(\.rawValue) as NSDictionary)
    }

    func testPulsingAnimationDuration() throws {
        let expectedColor: UIColor = .random()
        let expectedRadius: Double = 100
        let configuration = Puck2DConfiguration(pulsing: .init(color: expectedColor, radius: .constant(expectedRadius)))
        updateState(configuration: configuration)
        style.setLayerPropertiesStub.reset()

        timeProvider.currentStub.defaultReturnValue = 0
        $displayLink.send()

        timeProvider.currentStub.defaultReturnValue = 3
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        let radius = try XCTUnwrap(
            style.setLayerPropertiesStub.invocations.last?
                .parameters.properties[LocationIndicatorLayer.PaintCodingKeys.emphasisCircleRadius.rawValue] as? Double
        )
        let color = try XCTUnwrap(
            style.setLayerPropertiesStub.invocations.last?
                .parameters.properties[LocationIndicatorLayer.PaintCodingKeys.emphasisCircleColor.rawValue] as? String
        )
        XCTAssertEqual(StyleColor(expectedColor.withAlphaComponent(0)).rawValue, color)
        XCTAssertEqual(expectedRadius, radius)
    }

    func testPulsingAnimationMidway() throws {
        let curve = UnitBezier(p1: .zero, p2: CGPoint(x: 0.25, y: 1))
        let curvedProgress = curve.solve(0.5, 1e-6)
        let expectedColor: UIColor = .random()
        let expectedRadius: Double = 30
        let configuration = Puck2DConfiguration(pulsing: .init(color: expectedColor, radius: .constant(expectedRadius)))
        updateState(configuration: configuration)
        style.setLayerPropertiesStub.reset()

        timeProvider.currentStub.defaultReturnValue = 0
        $displayLink.send()

        timeProvider.currentStub.defaultReturnValue = 1.5
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        let radius = try XCTUnwrap(
            style.setLayerPropertiesStub.invocations.last?
                .parameters.properties[LocationIndicatorLayer.PaintCodingKeys.emphasisCircleRadius.rawValue] as? Double
        )
        let color = try XCTUnwrap(
            style.setLayerPropertiesStub.invocations.last?
                .parameters.properties[LocationIndicatorLayer.PaintCodingKeys.emphasisCircleColor.rawValue] as? String
        )
        XCTAssertEqual(StyleColor(expectedColor.withAlphaComponent(1 - curvedProgress)).rawValue, color)
        XCTAssertEqual(expectedRadius * curvedProgress, radius)
    }

    func testPulsingCyclesOver() throws {
        let expectedColor: UIColor = .random()
        let expectedRadius: Double = 100
        let curve = UnitBezier(p1: .zero, p2: CGPoint(x: 0.25, y: 1))
        let curvedProgress = curve.solve(0.5, 1e-6)
        let configuration = Puck2DConfiguration(pulsing: .init(color: expectedColor, radius: .constant(expectedRadius)))
        updateState(configuration: configuration)
        style.setLayerPropertiesStub.reset()

        timeProvider.currentStub.defaultReturnValue = 0
        $displayLink.send()

        timeProvider.currentStub.defaultReturnValue = 3
        $displayLink.send()

        timeProvider.currentStub.defaultReturnValue = 4.5
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 2)
        let radius = try XCTUnwrap(
            style.setLayerPropertiesStub.invocations.last?
                .parameters.properties[LocationIndicatorLayer.PaintCodingKeys.emphasisCircleRadius.rawValue] as? Double
        )
        let color = try XCTUnwrap(
            style.setLayerPropertiesStub.invocations.last?
                .parameters.properties[LocationIndicatorLayer.PaintCodingKeys.emphasisCircleColor.rawValue] as? String
        )
        XCTAssertEqual(StyleColor(expectedColor.withAlphaComponent(1 - curvedProgress)).rawValue, color)
        XCTAssertEqual(expectedRadius * curvedProgress, radius)
    }

    func testPulsingAnimationUsesAccuracyRadius() throws {
        let expectedColor: UIColor = .random()
        let coordinate: CLLocationCoordinate2D = .random()
        let horizontalAccuracy: CLLocationAccuracy = .random(in: 500...10000)
        let expectedRadius: Double = horizontalAccuracy / Projection.metersPerPoint(for: coordinate.latitude, zoom: mapboxMap.cameraState.zoom)
        let configuration = Puck2DConfiguration(pulsing: .init(color: expectedColor, radius: .accuracy))
        style.layerExistsStub.defaultReturnValue = true
        updateState(coordinate: coordinate, horizontalAccuracy: horizontalAccuracy, configuration: configuration)
        style.setLayerPropertiesStub.reset()

        timeProvider.currentStub.defaultReturnValue = 0
        $displayLink.send()

        timeProvider.currentStub.defaultReturnValue = 3
        $displayLink.send()

        XCTAssertEqual(style.setLayerPropertiesStub.invocations.count, 1)
        let radius = try XCTUnwrap(
            style.setLayerPropertiesStub.invocations.last?
                .parameters.properties[LocationIndicatorLayer.PaintCodingKeys.emphasisCircleRadius.rawValue] as? Double
        )
        let color = try XCTUnwrap(
            style.setLayerPropertiesStub.invocations.last?
                .parameters.properties[LocationIndicatorLayer.PaintCodingKeys.emphasisCircleColor.rawValue] as? String
        )
        XCTAssertEqual(StyleColor(expectedColor.withAlphaComponent(0)).rawValue, color)
        XCTAssertEqual(expectedRadius, radius)
    }

    func testSlot() throws {
        style.layerExistsStub.defaultReturnValue = false

        var config = Puck2DConfiguration()
        config.slot = "some-slot"
        let state = updateState(with: .fullAccuracy, heading: nil, configuration: config)

        let expectedProperties = makeExpectedLayerProperties(with: state)
        let actualProperties = try XCTUnwrap(style.addPersistentLayerWithPropertiesStub.invocations.first?.parameters.properties)
        XCTAssertEqual(actualProperties as NSDictionary, expectedProperties as NSDictionary)
    }
}
