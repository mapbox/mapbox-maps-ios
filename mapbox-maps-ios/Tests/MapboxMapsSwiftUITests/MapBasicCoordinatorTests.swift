import CoreLocation
@_spi(Package) @testable import MapboxMaps
@_spi(Experimental) @testable import MapboxMapsSwiftUI

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

    func testStyleURI() {
        me.update(
            viewport: .constant(.idle),
            deps: MapDependencies(styleURI: .light),
            layoutDirection: .leftToRight,
            animationData: nil)
        var invocations = mapView.style.$uri.setStub.invocations
        XCTAssertEqual(invocations.count, 1)
        XCTAssertEqual(invocations.last?.parameters, .light)

        me.update(
            viewport: .constant(.idle),
            deps: MapDependencies(styleURI: .light),
            layoutDirection: .leftToRight,
            animationData: nil)
        invocations = mapView.style.$uri.setStub.invocations
        XCTAssertEqual(invocations.count, 1, "Setting same style URI doesn't change it")

        me.update(
            viewport: .constant(.idle),
            deps: MapDependencies(styleURI: .dark),
            layoutDirection: .leftToRight,
            animationData: nil)
        invocations = mapView.style.$uri.setStub.invocations
        XCTAssertEqual(invocations.count, 2)
        XCTAssertEqual(invocations.last?.parameters, .dark)
    }

    func testMapOptions() {
        me.update(
            viewport: .constant(.idle),
            deps: MapDependencies(),
            layoutDirection: .leftToRight,
            animationData: nil)

        let mapboxMap = mapView.mapboxMap
        // Setting to already existing values doesn't change it
        XCTAssertEqual(mapboxMap.northOrientationStub.invocations.count, 0)
        XCTAssertEqual(mapboxMap.setConstraintModeStub.invocations.count, 0)
        XCTAssertEqual(mapboxMap.setViewportModeStub.invocations.count, 0)

        me.update(
            viewport: .constant(.idle),
            deps: MapDependencies(
                constrainMode: .none,
                viewportMode: .flippedY,
                orientation: .downwards),
            layoutDirection: .leftToRight,
            animationData: nil)
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
        me.update(
            viewport: .constant(.idle),
            deps: MapDependencies(ornamentOptions: ornamentOptions),
            layoutDirection: .leftToRight,
            animationData: nil)

        let ornaments = mapView.ornaments
        XCTAssertEqual(ornaments.options, ornamentOptions)
    }

    func testTapGesture() {
        let mockActions = MockActions()
        let deps = MapDependencies(actions: mockActions.actions)
        me.update(
            viewport: .constant(.idle),
            deps: deps,
            layoutDirection: .leftToRight,
            animationData: nil)

        let point = CGPoint.random()
        let coordinate = CLLocationCoordinate2D.random()

        mapView.gestures.singleTapGestureRecognizerMock.mockLocation = point
        mapView.mapboxMap.coordinateForPointStub.defaultReturnValue = coordinate

        mapView.gestures.singleTapGestureRecognizerMock.sendActions()

        XCTAssertEqual(mockActions.onMapTapGesture.invocations.count, 1)
        XCTAssertEqual(mockActions.onMapTapGesture.invocations.first?.parameters, point)

        let qrfStub = mapView.mapboxMap.qrfStub
        XCTAssertEqual(qrfStub.invocations.count, 1)
        XCTAssertEqual(qrfStub.invocations.first?.parameters.point, point)
        XCTAssertEqual(qrfStub.invocations.first?.parameters.options?.layerIds, ["layer-foo"])

        let feature = Feature(geometry: Point(coordinate))
        let queriedRenderedFeature = QueriedRenderedFeature(
            __queriedFeature: QueriedFeature(
                __feature: MapboxCommon.Feature(feature),
                source: "src",
                sourceLayer: "src-layer",
                state: [String: Any]()),
            layers: [])
        qrfStub.invocations.first?.parameters.completion(.success([queriedRenderedFeature]))
        XCTAssertEqual(mockActions.onLayerTapAction.invocations.count, 1)
        XCTAssertEqual(mockActions.onLayerTapAction.invocations.first?.parameters.point, point)
        XCTAssertEqual(mockActions.onLayerTapAction.invocations.first?.parameters.features, [queriedRenderedFeature])
        XCTAssertEqual(mockActions.onLayerTapAction.invocations.first?.parameters.coordinate, coordinate)
    }

    func testTapGestureMissLayer() {
        let mockActions = MockActions()
        let deps = MapDependencies(actions: mockActions.actions)
        me.update(
            viewport: .constant(.idle),
            deps: deps,
            layoutDirection: .leftToRight,
            animationData: nil)

        mapView.gestures.singleTapGestureRecognizerMock.sendActions()

        mapView.mapboxMap.qrfStub.invocations.first?.parameters.completion(.success([]))
        XCTAssertEqual(mockActions.onLayerTapAction.invocations.count, 0)

        mapView.gestures.singleTapGestureRecognizerMock.sendActions()

        mapView.mapboxMap.qrfStub.invocations[1].parameters.completion(.failure(MapError(coreError: "foo")))
        XCTAssertEqual(mockActions.onLayerTapAction.invocations.count, 0)
    }

    func testNotifyMapEventsToObservers() {
        var observedMapLoaded: MapLoaded?
        let subscription = AnyEventSubscription(keyPath: \.onMapLoaded) { event in
            observedMapLoaded = event
        }
        let deps = MapDependencies(eventsSubscriptions: [subscription])

        me.update(
            viewport: .constant(.idle),
            deps: deps,
            layoutDirection: .leftToRight,
            animationData: nil)
        let mapLoaded = MapLoaded(timeInterval: EventTimeInterval(begin: Date(), end: Date()))

        mapView.mapboxMap.events.onMapLoaded.send(mapLoaded)
        XCTAssertEqual(mapLoaded, observedMapLoaded)
    }
}

@available(iOS 13.0, *)
struct MockActions {
    var onMapTapGesture = Stub<CGPoint, Void>()
    var onLayerTapAction = Stub<MapLayerTapPayload, Void>()

    var actions: MapDependencies.Actions {
        .init(
            onMapTapGesture: onMapTapGesture.call(with:),
            layerTapActions: [
                (["layer-foo"], onLayerTapAction.call(with:))
            ])
    }
}
