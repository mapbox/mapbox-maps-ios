@testable import TestsSupport
import CoreLocation
@testable import MapboxMaps
@_spi(Experimental) @testable import MapboxMapsSwiftUI

import XCTest

@available(iOS 13.0, *)
final class MapCoordinatorTests: XCTestCase {
    var mapView: MockMapView!
    var setCameraStub: Stub<CameraState, Void>!
    var me: MapCoordinator!
    var mainQueue: MockMainQueue!

    override func setUpWithError() throws {
        mapView = MockMapView()
        setCameraStub = Stub()
        mainQueue = MockMainQueue()
        me = MapCoordinator(setCamera: setCameraStub.call(with:), mainQueue: mainQueue)
        me.setMapView(mapView.facade)
    }

    override func tearDownWithError() throws {
        me = nil
        setCameraStub = nil
        mapView = nil
    }

    func testUpstreamCameraUpdate() {
        mapView.mapboxMap.simulateEvent(event: .cameraChanged)
        XCTAssertEqual(setCameraStub.invocations.count, 1)

        mapView.mapboxMap.simulateEvent(event: .cameraChanged)
        mapView.mapboxMap.simulateEvent(event: .cameraChanged)
        XCTAssertEqual(setCameraStub.invocations.count, 3)
    }

    func testDownstreamCameraUpdate() {
        me.update(
            camera: nil,
            deps: MapDependencies(),
            colorScheme: .light)
        XCTAssertEqual(mapView.mapboxMap.setCameraStub.invocations.count, 0)

        let cameraState = CameraState.random()
        me.update(
            camera: cameraState,
            deps: MapDependencies(),
            colorScheme: .light)
        XCTAssertEqual(mapView.mapboxMap.setCameraStub.invocations.count, 1)
        XCTAssertEqual(mapView.mapboxMap.setCameraStub.invocations.first?.parameters, CameraOptions(cameraState: cameraState))
    }

    func testDownstreamCameraUpdateWithFollowingSync() {
        let cameraState = CameraState.random()
        let sideEffectCamera = CameraState.random()

        let mapboxMap = mapView.mapboxMap
        mapView.mapboxMap.setCameraStub.sideEffectQueue.append {
            mapboxMap.cameraState = CameraState(options: $0.parameters)
        }
        mapView.mapboxMap.setCameraBoundsStub.sideEffectQueue.append {  _ in
            mapboxMap.cameraState = sideEffectCamera
        }

        me.update(
            camera: cameraState,
            deps: MapDependencies(),
            colorScheme: .light)

        mainQueue.asyncClosureStub.invocations.first?.parameters.work()

        XCTAssertEqual(mapboxMap.cameraState, sideEffectCamera)
        XCTAssertEqual(setCameraStub.invocations.count, 1)
        XCTAssertEqual(setCameraStub.invocations.first?.parameters, sideEffectCamera)
    }

    func testCameraBounds() {
        let cameraBounds = CameraBoundsOptions(bounds: CoordinateBounds(southwest: .random(), northeast: .random()))
        me.update(
            camera: nil,
            deps: MapDependencies(cameraBounds: cameraBounds),
            colorScheme: .light)
        XCTAssertEqual(mapView.mapboxMap.setCameraBoundsStub.invocations.count, 1)
        XCTAssertEqual(mapView.mapboxMap.setCameraBoundsStub.invocations.first?.parameters, cameraBounds)
    }

    func testStyleURI() {
        let uris = MapDependencies.StyleURIs(default: .light, darkMode: .dark)

        me.update(
            camera: nil,
            deps: MapDependencies(styleURIs: uris),
            colorScheme: .light)
        var invocations = mapView.style.$uri.setStub.invocations
        XCTAssertEqual(invocations.count, 1)
        XCTAssertEqual(invocations.first?.parameters, .light)

        me.update(
            camera: nil,
            deps: MapDependencies(styleURIs: uris),
            colorScheme: .light)
        invocations = mapView.style.$uri.setStub.invocations
        XCTAssertEqual(invocations.count, 1, "Setting same style URI doesn't change it")

        me.update(
            camera: nil,
            deps: MapDependencies(styleURIs: uris),
            colorScheme: .dark)
        invocations = mapView.style.$uri.setStub.invocations
        XCTAssertEqual(invocations.count, 2)
        XCTAssertEqual(invocations[1].parameters, .dark)
    }

    func testMapOptions() {
        me.update(
            camera: nil,
            deps: MapDependencies(),
            colorScheme: .light)

        let mapboxMap = mapView.mapboxMap
        // Setting to already existing valuesa doesn't change it
        XCTAssertEqual(mapboxMap.northOrientationStub.invocations.count, 0)
        XCTAssertEqual(mapboxMap.setConstraintModeStub.invocations.count, 0)
        XCTAssertEqual(mapboxMap.setViewportModeStub.invocations.count, 0)

        me.update(
            camera: nil,
            deps: MapDependencies(
                constrainMode: .none,
                viewportMode: .flippedY,
                orientation: .downwards),
            colorScheme: .light)
        XCTAssertEqual(mapboxMap.setConstraintModeStub.invocations.count, 1)
        XCTAssertEqual(mapboxMap.setViewportModeStub.invocations.count, 1)
        XCTAssertEqual(mapboxMap.northOrientationStub.invocations.count, 1)

        XCTAssertEqual(mapboxMap.setConstraintModeStub.invocations.first?.parameters, ConstrainMode.none)
        XCTAssertEqual(mapboxMap.setViewportModeStub.invocations.first?.parameters, .flippedY)
        XCTAssertEqual(mapboxMap.northOrientationStub.invocations.first?.parameters, .downwards)
    }

    func testTapGesture() {
        let mockActions = MockActions()
        let deps = MapDependencies(actions: mockActions.actions)
        me.update(camera: nil, deps: deps,colorScheme: .light)

        let point = CGPoint.random()
        let coordinate = CLLocationCoordinate2D.random()

        let locStub = mapView.locationsStub
        locStub.defaultReturnValue = point
        mapView.mapboxMap.coordinateForPointStub.defaultReturnValue = coordinate

        mapView.gestures.singleTapGestureRecognizerMock.sendActions()

        XCTAssertEqual(locStub.invocations.count, 1)
        XCTAssertEqual(locStub.invocations.first?.parameters, mapView.gestures.singleTapGestureRecognizerMock)
        XCTAssertEqual(mockActions.onMapTapGesture.invocations.count, 1)
        XCTAssertEqual(mockActions.onMapTapGesture.invocations.first?.parameters, point)

        let qrfStub = mapView.mapboxMap.qrfStub
        XCTAssertEqual(qrfStub.invocations.count, 1)
        XCTAssertEqual(qrfStub.invocations.first?.parameters.point, point)
        XCTAssertEqual(qrfStub.invocations.first?.parameters.options?.layerIds, ["layer-foo"])


        let feature = Feature(geometry: Point(coordinate))
        let queriedFeature = QueriedFeature(
            __feature: MapboxCommon.Feature(feature),
            source: "src",
            sourceLayer: "src-layer",
            state: [String: Any]())
        qrfStub.invocations.first?.parameters.completion(.success([queriedFeature]))
        XCTAssertEqual(mockActions.onLayerTapAction.invocations.count, 1)
        XCTAssertEqual(mockActions.onLayerTapAction.invocations.first?.parameters.point, point)
        XCTAssertEqual(mockActions.onLayerTapAction.invocations.first?.parameters.features, [queriedFeature])
        XCTAssertEqual(mockActions.onLayerTapAction.invocations.first?.parameters.coordinate, coordinate)
    }

    func testTapGestureMissLayer() {
        let mockActions = MockActions()
        let deps = MapDependencies(actions: mockActions.actions)
        me.update(camera: nil, deps: deps,colorScheme: .light)

        mapView.gestures.singleTapGestureRecognizerMock.sendActions()

        mapView.mapboxMap.qrfStub.invocations.first?.parameters.completion(.success([]))
        XCTAssertEqual(mockActions.onLayerTapAction.invocations.count, 0)

        mapView.gestures.singleTapGestureRecognizerMock.sendActions()

        mapView.mapboxMap.qrfStub.invocations[1].parameters.completion(.failure(MapError(coreError: "foo")))
        XCTAssertEqual(mockActions.onLayerTapAction.invocations.count, 0)
    }

}

@available(iOS 13.0, *)
struct MockActions {
    var onMapTapGesture = Stub<CGPoint, Void>()
    var onLayerTapAction = Stub<MapboxMapsSwiftUI.Map.LayerTapPayload, Void>()

    var actions: MapDependencies.Actions {
        .init(
            onMapTapGesture: onMapTapGesture.call(with:),
            layerTapActions: [
                (["layer-foo"], onLayerTapAction.call(with:))
            ])
    }
}


extension CameraState {
    init(options: CameraOptions) {
        self.init(
            center: options.center ?? CLLocationCoordinate2D(latitude: 0, longitude: 0),
            padding: options.padding ?? .zero,
            zoom: options.zoom ?? 0,
            bearing: options.bearing ?? 0,
            pitch: options.pitch ?? 0)
    }
}
