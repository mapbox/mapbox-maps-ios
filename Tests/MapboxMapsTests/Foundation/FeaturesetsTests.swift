@testable @_spi(Experimental) import MapboxMaps
import XCTest

final class FeaturesetsTests: IntegrationTestCase {
    private var mapView: MapView!
    private var map: MapboxMap { mapView.mapboxMap }

    override func setUpWithError() throws {
        try super.setUpWithError()
        try guardForMetalDevice()

        let rootView = try XCTUnwrap(rootViewController?.view)
        let size = CGSize(width: 200, height: 200)
        mapView = MapView(frame: .init(origin: CGPoint(x: 100, y: 100), size: size))
        rootView.addSubview(mapView)

        map.setCamera(to: CameraOptions(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), zoom: 10))

        let expectation = expectation(description: "Load style")
        map.load(mapStyle: .featuresetTestsStyle) { res in
            switch res {
            case .none:
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    expectation.fulfill()
                }
            case .some(let error):
                XCTFail("Failed to load style: \(error)")
            }
        }

        wait(for: [expectation], timeout: 10.0)

    }

    override func tearDownWithError() throws {
        mapView?.removeFromSuperview()
        mapView = nil

        try super.tearDownWithError()
    }

    func testFeaturesetQRF() {
        var coord = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        var point = CGPoint(x: 0, y: 0)

        coord = CLLocationCoordinate2D(latitude: 0.01, longitude: 0.01)
        point = map.point(for: coord)

        let poiQRFExp = expectation(description: "POI qrf")
        mapView.mapboxMap.queryRenderedFeatures(with: point, featureset: .standardPoi(importId: "nested")) { res in
            switch res {
            case .success(let features):
                XCTAssertEqual(features.count, 2)
                XCTAssertEqual(features[safe: 0]?.name, "nest2")
                XCTAssertEqual(features[safe: 1]?.name, "nest1")
                XCTAssertEqual(features[safe: 0]?.class, "poi")
            case .failure:
                XCTFail("shouldn't fail")
            }
            poiQRFExp.fulfill()
        }

        let poiFilteredExp = expectation(description: "POI qrf filtered")
        mapView.mapboxMap.queryRenderedFeatures(
            with: point,
            featureset: .standardPoi(importId: "nested"),
            filter: Exp(.eq) {
                Exp(.get) { "type" }
                "A"
            }) { res in

            switch res {
            case .success(let features):
                XCTAssertEqual(features.count, 1)
                XCTAssertEqual(features[safe: 0]?.name, "nest1")
                XCTAssertEqual(features[safe: 0]?.class, "poi")
            case .failure:
                XCTFail("shouldn't fail")
            }

            poiFilteredExp.fulfill()
        }

        let poiQRFViewportExp = expectation(description: "POI qrf whole viewport")
        mapView.mapboxMap.queryRenderedFeatures(
            featureset: .standardPoi(importId: "nested")) { res in

            switch res {
            case .success(let features):
                XCTAssertEqual(features.count, 3)
                XCTAssertEqual(features[safe: 0]?.name, "nest2")
                XCTAssertEqual(features[safe: 1]?.name, "nest1")
                XCTAssertEqual(features[safe: 2]?.name, "nest3")
                XCTAssertEqual(features[safe: 2]?.class, "poi")
            case .failure:
                XCTFail("shouldn't fail")
            }

            poiQRFViewportExp.fulfill()
        }

        wait(for: [poiQRFExp, poiFilteredExp, poiQRFViewportExp], timeout: 10.0)
    }

    func testFeatureStateMethods() throws {
        let geoJsonFeature = Feature(geometry: Point(CLLocationCoordinate2D(latitude: 0.01, longitude: 0.01)))
        let feature = FeaturesetFeature(
            id: FeaturesetFeatureId(id: "11", namespace: "A"),
            featureset: .featureset("poi", importId: "nested"),
            geoJsonFeature: geoJsonFeature,
            state: .init())
        let poiFeature = try XCTUnwrap(StandardPoiFeature(from: feature))

        let setStateExp = expectation(description: "state exp")

        let map = mapView.mapboxMap!
        map.setFeatureState(poiFeature, state: .init(hide: true)) { error in
            XCTAssertNil(error)
            setStateExp.fulfill()
        }

        wait(for: [setStateExp], timeout: 10.0)

        let getFsExp = expectation(description: "get fs exp")
        map.getFeatureState(poiFeature) { res in
            switch res {
            case .success(let state):
                XCTAssertEqual(state, .init(hide: true))
            case .failure:
                XCTFail("shouldn't fail")
            }
            getFsExp.fulfill()
        }

        wait(for: [getFsExp], timeout: 10.0)

        let removeFsExp = expectation(description: "remove fs exp")
        map.removeFeatureState(poiFeature, stateKey: .hide) { error in
            XCTAssertNil(error)
            removeFsExp.fulfill()
        }
        wait(for: [removeFsExp], timeout: 10)

        let getFsExp2 = expectation(description: "get fs exp 2")
        map.getFeatureState(poiFeature) { res in
            switch res {
            case .success(let state):
                XCTAssertEqual(state, .init(hide: nil))
            case .failure:
                XCTFail("shouldn't fail")
            }
            getFsExp2.fulfill()
        }

        wait(for: [getFsExp2], timeout: 10)

        let resetStatesExp = expectation(description: "reset states exp")
        map.setFeatureState(poiFeature, state: .init(hide: true)) { [unowned map] error in
            XCTAssertNil(error)
            map.resetFeatureStates(featureset: poiFeature.featureset) { err in
                XCTAssertNil(err)

                map.getFeatureState(poiFeature) { res in
                    switch res {
                    case .success(let state):
                        XCTAssertEqual(state, .init(hide: nil))
                    case .failure:
                        XCTFail("shouldn't fail")
                    }
                    resetStatesExp.fulfill()
                }
            }
        }

        wait(for: [resetStatesExp], timeout: 10)
    }

    func testStateIsQueried() throws {
        let setStateExp = expectation(description: "set state exp")

        let map = mapView.mapboxMap!
        let id = FeaturesetFeatureId(id: "11", namespace: "A")
        map.setFeatureState(
            featureset: .standardPoi(importId: "nested"),
            featureId: id,
            state: .init(hide: true)
        ) { error in
            XCTAssertNil(error)
            setStateExp.fulfill()
        }

        wait(for: [setStateExp], timeout: 10.0)

        let queryExp = expectation(description: "state exp")
        let filter = Exp(.eq) {
            Exp(.get) { "type" }
            "A"
        }
        map.queryRenderedFeatures(featureset: .standardPoi(importId: "nested"),
                                  filter: filter) { result in
            switch result {
            case .success(let features):
                XCTAssertEqual(features.count, 1)
                guard let poi = features.first, let point = poi.geometry.point else {
                    XCTFail("expected poi")
                    queryExp.fulfill()
                    return
                }
                XCTAssertEqual(poi.id, id)
                XCTAssertEqual(poi.state, StandardPoiFeature.State(hide: true))
                XCTAssertEqual(point.coordinates.latitude, 0.01, accuracy: 0.05)
                XCTAssertEqual(point.coordinates.longitude, 0.01, accuracy: 0.05)
                XCTAssertEqual(point.coordinates, poi.coordinate)
                XCTAssertEqual(poi.group, nil)
                XCTAssertEqual(poi.properties, JSONObject(turfRawValue: [
                    "name": "nest1",
                    "type": "A",
                    "class": "poi"
                ]))
            case .failure(let err):
                XCTFail("error: \(err)")
            }
            queryExp.fulfill()
        }

        wait(for: [queryExp], timeout: 10.0)
    }

    func testGetFeaturesets() throws {
        XCTAssertEqual(mapView.mapboxMap.featuresets.count, 1)

        let featureset = try XCTUnwrap(mapView.mapboxMap.featuresets.first)
        XCTAssertEqual(FeaturesetDescriptor.standardPoi(importId: "nested"), featureset.converted())
    }
}
