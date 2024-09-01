@testable @_spi(Experimental) import MapboxMaps
import XCTest

final class InteractionsTests: IntegrationTestCase {
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
            map.load(mapStyle: .init(json: style)) { res in
                switch res {
                case .none:
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                        expectation.fulfill()
                    }
                case .some(let error):
                    XCTFail("Failed to load style: \(error)")
                }
            }

        wait(for: [expectation], timeout: 3.0)

    }

    override func tearDownWithError() throws {
        mapView?.removeFromSuperview()
        mapView = nil

        try super.tearDownWithError()
    }

    func testTapInteraction() {
        var coord = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        var point = CGPoint(x: 0, y: 0)

        let layerExpectation = expectation(description: "Layer tapped")
        map.addInteraction(TapInteraction(.layer("circle-1")) { feature, ctx in
            XCTAssertEqual(feature.featureset, .layer("circle-1"))
            XCTAssertEqual(feature.id, FeaturesetFeatureId(id: "1"))
            XCTAssertEqual(feature.properties?["foo"]?.map(\.number), 1.0)

            XCTAssertEqual(ctx.point.x, point.x)
            XCTAssertEqual(ctx.point.y, point.y)
            XCTAssertEqual(ctx.coordinate.latitude, coord.latitude, accuracy: 1e-6)
            XCTAssertEqual(ctx.coordinate.longitude, coord.longitude, accuracy: 1e-6)

            layerExpectation.fulfill()
            return true
        })

        let poiExpectation = expectation(description: "POI tapped")
        map.addInteraction(TapInteraction(.featureset("poi", importId: "nested")) { feature, ctx in
            XCTAssertEqual(feature.featureset, .featureset("poi", importId: "nested"))
            XCTAssertEqual(feature.id, FeaturesetFeatureId(id: "12", namespace: "A"))
            XCTAssertEqual(feature.properties?["name"]?.map(\.string), "nest2")
            XCTAssertEqual(feature.properties?["type"]?.map(\.string), "B")
            XCTAssertEqual(feature.properties?["filter"], nil)

            XCTAssertEqual(ctx.point.x, point.x)
            XCTAssertEqual(ctx.point.y, point.y)
            XCTAssertEqual(ctx.coordinate.latitude, coord.latitude, accuracy: 1e-6)
            XCTAssertEqual(ctx.coordinate.longitude, coord.longitude, accuracy: 1e-6)

            poiExpectation.fulfill()
            return true
        })

        let mapExpectation = expectation(description: "Map tapped")
        map.addInteraction(TapInteraction { ctx in
            XCTAssertEqual(ctx.point.x, point.x)
            XCTAssertEqual(ctx.point.y, point.y)
            XCTAssertEqual(ctx.coordinate.latitude, coord.latitude, accuracy: 1e-6)
            XCTAssertEqual(ctx.coordinate.longitude, coord.longitude, accuracy: 1e-6)

            mapExpectation.fulfill()

            XCTAssertEqual(ctx.point.x, point.x)
            XCTAssertEqual(ctx.point.y, point.y)
            XCTAssertEqual(ctx.coordinate.latitude, coord.latitude, accuracy: 1e-6)
            XCTAssertEqual(ctx.coordinate.longitude, coord.longitude, accuracy: 1e-6)
            return true
        })

        let anyLongPressExpectation = expectation(description: "Any Long press")
        anyLongPressExpectation.expectedFulfillmentCount = 1
        anyLongPressExpectation.isInverted = true

        map.addInteraction(LongPressInteraction { _ in
            anyLongPressExpectation.fulfill()
            return false
        })

        map.addInteraction(LongPressInteraction(.layer("circle-1")) { _, _ in
            anyLongPressExpectation.fulfill()
            return false
        })

        map.addInteraction(LongPressInteraction(.featureset("poi", importId: "nested")) { _, _ in
            anyLongPressExpectation.fulfill()
            return false
        })

        // Layer tap
        coord = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        point = map.point(for: coord)
        map.dispatch(event: CorePlatformEventInfo(type: .click, screenCoordinate: point.screenCoordinate))
        wait(for: [layerExpectation], timeout: 2.0)

        // POI tap
        coord = CLLocationCoordinate2D(latitude: 0.01, longitude: 0.01)
        point = map.point(for: coord)
        map.dispatch(event: CorePlatformEventInfo(type: .click, screenCoordinate: point.screenCoordinate))
        wait(for: [poiExpectation], timeout: 2.0)

        // Map tap
        coord = CLLocationCoordinate2D(latitude: -0.01, longitude: -0.01)
        point = map.point(for: coord)
        map.dispatch(event: CorePlatformEventInfo(type: .click, screenCoordinate: point.screenCoordinate))
        wait(for: [mapExpectation], timeout: 2.0)

        // No long press invoked
        wait(for: [anyLongPressExpectation], timeout: 2.0)
    }

    func testTapWithFilter() {
        let coord = CLLocationCoordinate2D(latitude: 0.01, longitude: 0.01)
        let point = map.point(for: coord)

        let poiExpectation = expectation(description: "filtered POI clicked")

        let filter = Exp(.eq) {
            Exp(.get) { "type" }
            "A"
        }
        map.addInteraction(TapInteraction(.featureset("poi", importId: "nested"), filter: filter) { feature, ctx in
            XCTAssertEqual(feature.featureset, .featureset("poi", importId: "nested"))
            XCTAssertEqual(feature.id, FeaturesetFeatureId(id: "11", namespace: "A"))
            XCTAssertEqual(feature.properties?["name"]?.map(\.string), "nest1")
            XCTAssertEqual(feature.properties?["type"]?.map(\.string), "A")
            XCTAssertEqual(feature.properties?["filter"], nil)

            XCTAssertEqual(ctx.point.x, point.x)
            XCTAssertEqual(ctx.point.y, point.y)
            XCTAssertEqual(ctx.coordinate.latitude, coord.latitude, accuracy: 1e-6)
            XCTAssertEqual(ctx.coordinate.longitude, coord.longitude, accuracy: 1e-6)

            poiExpectation.fulfill()
            return true
        })

        // POI click
        map.dispatch(event: CorePlatformEventInfo(type: .click, screenCoordinate: point.screenCoordinate))
        wait(for: [poiExpectation], timeout: 2.0)
    }

    func testLongPressInteraction() {
        var coord = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        var point = CGPoint(x: 0, y: 0)

        let layerExpectation = expectation(description: "Layer long-pressed")
        map.addInteraction(LongPressInteraction(.layer("circle-1")) { feature, ctx in
            XCTAssertEqual(feature.featureset, .layer("circle-1"))
            XCTAssertEqual(feature.id, FeaturesetFeatureId(id: "1"))
            XCTAssertEqual(feature.properties?["foo"]?.map(\.number), 1.0)

            XCTAssertEqual(ctx.point.x, point.x)
            XCTAssertEqual(ctx.point.y, point.y)
            XCTAssertEqual(ctx.coordinate.latitude, coord.latitude, accuracy: 1e-6)
            XCTAssertEqual(ctx.coordinate.longitude, coord.longitude, accuracy: 1e-6)

            layerExpectation.fulfill()
            return true
        })

        let poiExpectation = expectation(description: "POI long-pressed")
        map.addInteraction(LongPressInteraction(.featureset("poi", importId: "nested")) { feature, ctx in
            XCTAssertEqual(feature.featureset, .featureset("poi", importId: "nested"))
            XCTAssertEqual(feature.id, FeaturesetFeatureId(id: "12", namespace: "A"))
            XCTAssertEqual(feature.properties?["name"]?.map(\.string), "nest2")
            XCTAssertEqual(feature.properties?["type"]?.map(\.string), "B")
            XCTAssertEqual(feature.properties?["filter"], nil)

            XCTAssertEqual(ctx.point.x, point.x)
            XCTAssertEqual(ctx.point.y, point.y)
            XCTAssertEqual(ctx.coordinate.latitude, coord.latitude, accuracy: 1e-6)
            XCTAssertEqual(ctx.coordinate.longitude, coord.longitude, accuracy: 1e-6)

            poiExpectation.fulfill()
            return true
        })

        let mapExpectation = expectation(description: "Map long-pressed")
        map.addInteraction(LongPressInteraction { ctx in
            XCTAssertEqual(ctx.point.x, point.x)
            XCTAssertEqual(ctx.point.y, point.y)
            XCTAssertEqual(ctx.coordinate.latitude, coord.latitude, accuracy: 1e-6)
            XCTAssertEqual(ctx.coordinate.longitude, coord.longitude, accuracy: 1e-6)

            mapExpectation.fulfill()

            XCTAssertEqual(ctx.point.x, point.x)
            XCTAssertEqual(ctx.point.y, point.y)
            XCTAssertEqual(ctx.coordinate.latitude, coord.latitude, accuracy: 1e-6)
            XCTAssertEqual(ctx.coordinate.longitude, coord.longitude, accuracy: 1e-6)
            return true
        })

        let anyTapExpectation = expectation(description: "Any Long press")
        anyTapExpectation.expectedFulfillmentCount = 1
        anyTapExpectation.isInverted = true

        map.addInteraction(TapInteraction { _ in
            anyTapExpectation.fulfill()
            return false
        })

        map.addInteraction(TapInteraction(.layer("circle-1")) { _, _ in
            anyTapExpectation.fulfill()
            return false
        })

        map.addInteraction(TapInteraction(.featureset("poi", importId: "nested")) { _, _ in
            anyTapExpectation.fulfill()
            return false
        })

        // Layer long press
        coord = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        point = map.point(for: coord)
        map.dispatch(event: CorePlatformEventInfo(type: .longClick, screenCoordinate: point.screenCoordinate))
        wait(for: [layerExpectation], timeout: 2.0)

        // POI long press
        coord = CLLocationCoordinate2D(latitude: 0.01, longitude: 0.01)
        point = map.point(for: coord)
        map.dispatch(event: CorePlatformEventInfo(type: .longClick, screenCoordinate: point.screenCoordinate))
        wait(for: [poiExpectation], timeout: 2.0)

        // Map long press
        coord = CLLocationCoordinate2D(latitude: -0.01, longitude: -0.01)
        point = map.point(for: coord)
        map.dispatch(event: CorePlatformEventInfo(type: .longClick, screenCoordinate: point.screenCoordinate))
        wait(for: [mapExpectation], timeout: 2.0)

        // No tap is invoked
        wait(for: [anyTapExpectation], timeout: 2.0)
    }
}

private let style = """
{
    "version": 8,
    "imports": [
        {
            "id": "nested",
            "url": "",
            "config": {},
            "data": {
                "version": 8,
                "featuresets": {
                    "poi" : {
                        "selectors": [
                            {
                                "layer": "poi-label-1",
                                "properties": {
                                    "type": [ "get", "type" ],
                                    "name": [ "get", "name" ]
                                },
                                "featureNamespace": "A"
                            }
                        ]
                    }
                },
                "sources": {
                    "geojson": {
                        "type": "geojson",
                        "data": {
                            "type": "FeatureCollection",
                            "features": [
                                {
                                    "type": "Feature",
                                    "properties": {
                                        "filter": "true",
                                        "name": "nest1",
                                        "type": "A"
                                    },
                                    "geometry": {
                                        "type": "Point",
                                        "coordinates": [ 0.01, 0.01 ]
                                    },
                                    "id": 11
                                },
                                {
                                    "type": "Feature",
                                    "properties": {
                                        "name": "nest2",
                                        "type": "B"
                                    },
                                    "geometry": {
                                        "type": "Point",
                                        "coordinates": [ 0.01, 0.01 ]
                                    },
                                    "id": 12
                                }
                            ]
                        }
                    }
                },
                "layers": [
                    {
                        "id": "poi-label-1",
                        "type": "circle",
                        "source": "geojson",
                        "paint": {
                            "circle-radius": 5,
                            "circle-color": "red"
                        }
                    }
                ]
            }
        }
    ],
    "sources": {
        "geojson": {
            "type": "geojson",
            "promoteId": "foo",
            "data": {
                "type": "FeatureCollection",
                "features": [
                    {
                        "type": "Feature",
                        "properties": {
                            "foo": 1
                        },
                        "geometry": {
                            "type": "Point",
                            "coordinates": [
                                0,
                                0
                            ]
                        }
                    }
                ]
            }
        }
    },
    "layers": [
        {
            "id": "background",
            "type": "background",
            "background-color": "green"
        },
        {
            "id": "circle-1",
            "type": "circle",
            "source": "geojson",
            "paint": {
                "circle-radius": 5,
                "circle-color": "black"
            }
        }
    ]
}
"""
