@testable import MapboxMaps
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

        let expectation = expectation(description: "Load the map")

        map.load(mapStyle: .featuresetTestsStyle)

        map.onMapLoaded.observeNext { _ in
            expectation.fulfill()
        }.store(in: &cancelables)

        wait(for: [expectation], timeout: 10.0)

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
            XCTAssertEqual(feature.properties["foo"]?.map(\.number), 1.0)

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
            XCTAssertEqual(feature.properties["name"]?.map(\.string), "nest2")
            XCTAssertEqual(feature.properties["type"]?.map(\.string), "B")
            XCTAssertEqual(feature.properties["filter"], nil)

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

        map.addInteraction(LongPressInteraction { _ in
            XCTFail("Long press handler should not be called for tap events")
            return false
        })

        map.addInteraction(LongPressInteraction(.layer("circle-1")) { _, _ in
            XCTFail("Long press handler should not be called for tap events")
            return false
        })

        map.addInteraction(LongPressInteraction(.featureset("poi", importId: "nested")) { _, _ in
            XCTFail("Long press handler should not be called for tap events")
            return false
        })

        // Layer tap
        coord = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        point = map.point(for: coord)
        map.dispatch(event: CorePlatformEventInfo(type: .click, screenCoordinate: point.screenCoordinate))
        wait(for: [layerExpectation], timeout: 5.0)

        // POI tap
        coord = CLLocationCoordinate2D(latitude: 0.01, longitude: 0.01)
        point = map.point(for: coord)
        map.dispatch(event: CorePlatformEventInfo(type: .click, screenCoordinate: point.screenCoordinate))
        wait(for: [poiExpectation], timeout: 5.0)

        // Map tap
        coord = CLLocationCoordinate2D(latitude: -0.01, longitude: -0.01)
        point = map.point(for: coord)
        map.dispatch(event: CorePlatformEventInfo(type: .click, screenCoordinate: point.screenCoordinate))
        wait(for: [mapExpectation], timeout: 5.0)

        // Verify no long press was invoked - give events time to process
        let verifyExpectation = expectation(description: "verify no long press")
        DispatchQueue.main.async {
            verifyExpectation.fulfill()
        }
        wait(for: [verifyExpectation], timeout: 2.0)
    }

    func testTapInteractionWithRadius() {
        let tap1 = expectation(description: "tap 1")
        let tap2 = expectation(description: "tap 2")

        var tapCount = 0

        map.addInteraction(TapInteraction(.featureset("poi", importId: "nested"), radius: 5) { _, _ in
            tapCount += 1
            if tapCount == 1 {
                tap1.fulfill()
            } else if tapCount == 2 {
                tap2.fulfill()
            }
            return true
        })

        let coord = CLLocationCoordinate2D(latitude: 0.01, longitude: 0.01)
        var point = map.point(for: coord)

        // First tap: directly on feature (should trigger)
        map.dispatch(event: CorePlatformEventInfo(type: .click, screenCoordinate: point.screenCoordinate))
        wait(for: [tap1], timeout: 5.0)

        // Second tap: 8 pixels away (within radius of 5 + feature size, should trigger)
        point.x += 8
        map.dispatch(event: CorePlatformEventInfo(type: .click, screenCoordinate: point.screenCoordinate))
        wait(for: [tap2], timeout: 5.0)

        // Third tap: 5 additional pixels away (13 total, outside radius, should NOT trigger)
        point.x += 5
        let initialTapCount = tapCount

        // Dispatch the event
        map.dispatch(event: CorePlatformEventInfo(type: .click, screenCoordinate: point.screenCoordinate))

        // Wait for any pending main queue operations to complete
        let verifyExpectation = expectation(description: "verify no tap")
        // Give event processing one full runloop cycle to complete
        DispatchQueue.main.async {
            XCTAssertEqual(tapCount, initialTapCount, "Handler should not be called for tap outside radius")
            verifyExpectation.fulfill()
        }
        wait(for: [verifyExpectation], timeout: 2.0)
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
            XCTAssertEqual(feature.properties["name"]?.map(\.string), "nest1")
            XCTAssertEqual(feature.properties["type"]?.map(\.string), "A")
            XCTAssertEqual(feature.properties["filter"], nil)

            XCTAssertEqual(ctx.point.x, point.x)
            XCTAssertEqual(ctx.point.y, point.y)
            XCTAssertEqual(ctx.coordinate.latitude, coord.latitude, accuracy: 1e-6)
            XCTAssertEqual(ctx.coordinate.longitude, coord.longitude, accuracy: 1e-6)

            poiExpectation.fulfill()
            return true
        })

        // POI click
        map.dispatch(event: CorePlatformEventInfo(type: .click, screenCoordinate: point.screenCoordinate))
        wait(for: [poiExpectation], timeout: 5.0)
    }

    func testLongPressInteraction() {
        var coord = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        var point = CGPoint(x: 0, y: 0)

        let layerExpectation = expectation(description: "Layer long-pressed")
        map.addInteraction(LongPressInteraction(.layer("circle-1")) { feature, ctx in
            XCTAssertEqual(feature.featureset, .layer("circle-1"))
            XCTAssertEqual(feature.id, FeaturesetFeatureId(id: "1"))
            XCTAssertEqual(feature.properties["foo"]?.map(\.number), 1.0)

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
            XCTAssertEqual(feature.properties["name"]?.map(\.string), "nest2")
            XCTAssertEqual(feature.properties["type"]?.map(\.string), "B")
            XCTAssertEqual(feature.properties["filter"], nil)

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

        map.addInteraction(TapInteraction { _ in
            XCTFail("Tap handler should not be called for long press events")
            return false
        })

        map.addInteraction(TapInteraction(.layer("circle-1")) { _, _ in
            XCTFail("Tap handler should not be called for long press events")
            return false
        })

        map.addInteraction(TapInteraction(.featureset("poi", importId: "nested")) { _, _ in
            XCTFail("Tap handler should not be called for long press events")
            return false
        })

        // Layer long press
        coord = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        point = map.point(for: coord)
        map.dispatch(event: CorePlatformEventInfo(type: .longClick, screenCoordinate: point.screenCoordinate))
        wait(for: [layerExpectation], timeout: 5.0)

        // POI long press
        coord = CLLocationCoordinate2D(latitude: 0.01, longitude: 0.01)
        point = map.point(for: coord)
        map.dispatch(event: CorePlatformEventInfo(type: .longClick, screenCoordinate: point.screenCoordinate))
        wait(for: [poiExpectation], timeout: 5.0)

        // Map long press
        coord = CLLocationCoordinate2D(latitude: -0.01, longitude: -0.01)
        point = map.point(for: coord)
        map.dispatch(event: CorePlatformEventInfo(type: .longClick, screenCoordinate: point.screenCoordinate))
        wait(for: [mapExpectation], timeout: 5.0)

        // Verify no tap was invoked - give events time to process
        let verifyExpectation = expectation(description: "verify no tap")
        DispatchQueue.main.async {
            verifyExpectation.fulfill()
        }
        wait(for: [verifyExpectation], timeout: 2.0)
    }
}
