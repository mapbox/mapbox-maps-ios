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

    func testTapInteractionWithRadius() {
        let tap1 = expectation(description: "tap 1")
        let tap2 = expectation(description: "tap 2")
        let tap3 = expectation(description: "tap 3")
        tap3.isInverted = true

        var queue = [tap3, tap2, tap1]

        map.addInteraction(TapInteraction(.featureset("poi", importId: "nested"), radius: 5) { _, _ in
            queue.popLast()?.fulfill()
            return true
        })

        let coord = CLLocationCoordinate2D(latitude: 0.01, longitude: 0.01)
        var point = map.point(for: coord)
        map.dispatch(event: CorePlatformEventInfo(type: .click, screenCoordinate: point.screenCoordinate))
        wait(for: [tap1], timeout: 2.0)

        // circle radius is 5, adding 3 to check tap with the radius
        point.x += 8
        map.dispatch(event: CorePlatformEventInfo(type: .click, screenCoordinate: point.screenCoordinate))
        wait(for: [tap2], timeout: 2.0)

        point.x += 5
        map.dispatch(event: CorePlatformEventInfo(type: .click, screenCoordinate: point.screenCoordinate))
        wait(for: [tap3], timeout: 2.0)
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
        wait(for: [poiExpectation], timeout: 2.0)
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
