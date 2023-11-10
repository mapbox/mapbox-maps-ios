import CoreLocation
@_spi(Experimental) @testable import MapboxMaps

import XCTest

@available(iOS 13.0, *)
final class MapBasicCoordinatorTests: XCTestCase {
    var mapView: MockMapView!
    var setViewportStub: Stub<Viewport, Void>!
    var me: MapBasicCoordinator!

    override func setUpWithError() throws {
        mapView = MockMapView()
        setViewportStub = Stub()
        me = MapBasicCoordinator(setViewport: setViewportStub.call(with:), mapView: mapView.facade)
    }

    override func tearDownWithError() throws {
        mapView = nil
        me = nil
        setViewportStub = nil
    }

    private func update(with deps: MapDependencies) {
        me.update(
            viewport: .constant(.idle),
            deps: deps,
            layoutDirection: .leftToRight,
            animationData: nil)
    }

    func testStyleURI() {
        update(with: MapDependencies(mapStyle: .light))
        XCTAssertEqual(mapView.style.mapStyle, .light)

        update(with: MapDependencies(mapStyle: .dark))
        XCTAssertEqual(mapView.style.mapStyle, .dark)
    }

    func testMapOptions() {
        update(with: MapDependencies())
        let mapboxMap = mapView.mapboxMap
        // Setting to already existing values doesn't change it
        XCTAssertEqual(mapboxMap.northOrientationStub.invocations.count, 0)
        XCTAssertEqual(mapboxMap.setConstraintModeStub.invocations.count, 0)
        XCTAssertEqual(mapboxMap.setViewportModeStub.invocations.count, 0)

        update(with: MapDependencies(
            constrainMode: .none,
            viewportMode: .flippedY,
            orientation: .downwards))
        XCTAssertEqual(mapboxMap.setConstraintModeStub.invocations.count, 1)
        XCTAssertEqual(mapboxMap.setViewportModeStub.invocations.count, 1)
        XCTAssertEqual(mapboxMap.northOrientationStub.invocations.count, 1)

        XCTAssertEqual(mapboxMap.setConstraintModeStub.invocations.first?.parameters, ConstrainMode.none)
        XCTAssertEqual(mapboxMap.setViewportModeStub.invocations.first?.parameters, .flippedY)
        XCTAssertEqual(mapboxMap.northOrientationStub.invocations.first?.parameters, .downwards)
    }

    func testOrnamentOptions() {
        let ornamentOptions = OrnamentOptions(
            scaleBar: ScaleBarViewOptions(margins: .random(), useMetricUnits: .random()),
            compass: CompassViewOptions(margins: .random()),
            logo: LogoViewOptions(margins: .random()),
            attributionButton: AttributionButtonOptions(margins: .random())
        )
        update(with: MapDependencies(ornamentOptions: ornamentOptions))

        let ornaments = mapView.ornaments
        XCTAssertEqual(ornaments.options, ornamentOptions)
    }

    func testDebugOptions() {
        XCTAssertEqual(mapView.facade.debugOptions, [])
        let debugOptions: MapViewDebugOptions = [.camera, .collision]
        update(with: MapDependencies(debugOptions: debugOptions))
        XCTAssertEqual(mapView.facade.debugOptions, debugOptions)
    }

    func testViewportOptions() {
        let options1 = ViewportOptions(
            transitionsToIdleUponUserInteraction: false,
            usesSafeAreaInsetsAsPadding: false)
        update(with: MapDependencies(viewportOptions: options1))
        XCTAssertEqual(mapView.facade.viewportManager.options, options1)

        let options2 = ViewportOptions(
            transitionsToIdleUponUserInteraction: true,
            usesSafeAreaInsetsAsPadding: true)
        update(with: MapDependencies(viewportOptions: options2))
        XCTAssertEqual(mapView.facade.viewportManager.options, options2)

    }

    func testContentGestures() {
        let onTapGesture = Stub<MapContentGestureContext, Void>()
        let onLongPressGesture = Stub<MapContentGestureContext, Void>()
        let onLayerTapGesture = Stub<(QueriedFeature, MapContentGestureContext), Bool>(defaultReturnValue: true)
        let onLayerLongPressGesture = Stub<(QueriedFeature, MapContentGestureContext), Bool>(defaultReturnValue: true)

        let deps = MapDependencies(
            onMapTap: onTapGesture.call(with:),
            onMapLongPress: onLongPressGesture.call(with:),
            onLayerTap: ["layer1": { onLayerTapGesture.call(with: ($0, $1)) }],
            onLayerLongPress: ["layer1": { onLayerLongPressGesture.call(with: ($0, $1)) }]
        )
        update(with: deps)

        let contentGestures = mapView.gestures.contentManager
        let point = CGPoint(x: 10, y: 20)
        let coordinate = CLLocationCoordinate2D(latitude: 30, longitude: 40)
        let context = MapContentGestureContext(point: point, coordinate: coordinate)

        contentGestures.$onMapTap.send(context)
        XCTAssertEqual(onTapGesture.invocations.count, 1)
        XCTAssertEqual(onTapGesture.invocations.first?.parameters.point, point)
        XCTAssertEqual(onTapGesture.invocations.first?.parameters.coordinate, coordinate)

        contentGestures.$onMapLongPress.send(context)
        XCTAssertEqual(onLongPressGesture.invocations.count, 1)
        XCTAssertEqual(onLongPressGesture.invocations.first?.parameters.point, point)
        XCTAssertEqual(onLongPressGesture.invocations.first?.parameters.coordinate, coordinate)

        let feature = Feature(geometry: Point(coordinate))
        let queriedFeature = QueriedFeature(
            __feature: MapboxCommon.Feature(feature),
            source: "src",
            sourceLayer: "src-layer",
            state: [String: Any]())

        contentGestures.simulateLayerTap(layerId: "layer1", queriedFeature: queriedFeature, context: context)
        XCTAssertEqual(onLayerTapGesture.invocations.count, 1)
        XCTAssertEqual(onLayerTapGesture.invocations.first?.parameters.0, queriedFeature)
        XCTAssertEqual(onLayerTapGesture.invocations.first?.parameters.1.point, point)
        XCTAssertEqual(onLayerTapGesture.invocations.first?.parameters.1.coordinate, coordinate)

        contentGestures.simulateLayerLongPress(layerId: "layer1", queriedFeature: queriedFeature, context: context)
        XCTAssertEqual(onLayerLongPressGesture.invocations.count, 1)
        XCTAssertEqual(onLayerLongPressGesture.invocations.first?.parameters.0, queriedFeature)
        XCTAssertEqual(onLayerLongPressGesture.invocations.first?.parameters.1.point, point)
        XCTAssertEqual(onLayerLongPressGesture.invocations.first?.parameters.1.coordinate, coordinate)
    }

    func testNotifyMapEventsToObservers() {
        var observedMapLoaded: MapLoaded?
        let subscription = AnyEventSubscription(keyPath: \.onMapLoaded) { event in
            observedMapLoaded = event
        }
        let deps = MapDependencies(eventsSubscriptions: [subscription])

        update(with: deps)
        let mapLoaded = MapLoaded(timeInterval: EventTimeInterval(begin: Date(), end: Date()))

        mapView.mapboxMap.events.onMapLoaded.send(mapLoaded)
        XCTAssertEqual(mapLoaded, observedMapLoaded)
    }

    func testResetToIdleViewport() {
        let state1 = MockViewportState()
        mapView.viewportManager.simulateViewportStatusDidChange(from: .state(state1), to: .idle, reason: .userInteraction)
        XCTAssertEqual(setViewportStub.invocations.count, 1)
        XCTAssertEqual(setViewportStub.invocations.last?.parameters, .idle)

        mapView.viewportManager.simulateViewportStatusDidChange(from: .state(state1), to: .idle, reason: .transitionFailed)
        XCTAssertEqual(setViewportStub.invocations.count, 2)
        XCTAssertEqual(setViewportStub.invocations.last?.parameters, .idle)

        mapView.viewportManager.simulateViewportStatusDidChange(from: .state(state1), to: .idle, reason: .idleRequested)
        XCTAssertEqual(setViewportStub.invocations.count, 3)
        XCTAssertEqual(setViewportStub.invocations.last?.parameters, .idle)
    }
}
