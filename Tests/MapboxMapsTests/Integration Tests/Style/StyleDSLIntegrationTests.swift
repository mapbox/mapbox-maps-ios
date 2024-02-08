import XCTest
@_spi(Experimental) @testable import MapboxMaps

internal class StyleDSLIntegrationTests: MapViewIntegrationTestCase {

    internal func testLayerOrder() {
        let expectation = self.expectation(description: "Wait for mapStyle to load")
        expectation.expectedFulfillmentCount = 1

        mapView.mapboxMap.mapStyle = .standard {
            FillLayer(id: "first", source: "test-source")
            LineLayer(id: "second", source: "test-source")
            SymbolLayer(id: "third", source: "test-source")
            CircleLayer(id: "fourth", source: "test-source")
            HeatmapLayer(id: "fifth", source: "test-source")
            FillExtrusionLayer(id: "sixth", source: "test-source")
            RasterLayer(id: "seventh", source: "test-source")
            HillshadeLayer(id: "eighth", source: "test-source")
            ModelLayer(id: "ninth", source: "test-source")
        }

        didFinishLoadingStyle = { mapView in
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers.count, 9)
            // New layers should be added in order to the top of the layer stack
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[0].id, "first")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[1].id, "second")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[2].id, "third")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[3].id, "fourth")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[4].id, "fifth")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[5].id, "sixth")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[6].id, "seventh")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[7].id, "eighth")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[8].id, "ninth")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

    internal func testLayerOrderStreets() {
        let expectation = self.expectation(description: "Wait for mapStyle to load")
        expectation.expectedFulfillmentCount = 1

        mapView.mapboxMap.mapStyle = .streets {
            FillLayer(id: "first", source: "test-source")
            LineLayer(id: "second", source: "test-source")
            SymbolLayer(id: "third", source: "test-source")
            CircleLayer(id: "fourth", source: "test-source")
            HeatmapLayer(id: "fifth", source: "test-source")
            FillExtrusionLayer(id: "sixth", source: "test-source")
            RasterLayer(id: "seventh", source: "test-source")
            HillshadeLayer(id: "eighth", source: "test-source")
            ModelLayer(id: "ninth", source: "test-source")
        }

        didFinishLoadingStyle = { mapView in
            let layerCount = mapView.mapboxMap.allLayerIdentifiers.count
            XCTAssertEqual(layerCount, 143)
            // New layers should be added in order to the top of the layer stack
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[layerCount-9].id, "first")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[layerCount-8].id, "second")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[layerCount-7].id, "third")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[layerCount-6].id, "fourth")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[layerCount-5].id, "fifth")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[layerCount-4].id, "sixth")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[layerCount-3].id, "seventh")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[layerCount-2].id, "eighth")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[layerCount-1].id, "ninth")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

    internal func testStableLayerOrder() {
        let expectation = self.expectation(description: "Wait for mapStyle to load")
        expectation.expectedFulfillmentCount = 1

        let boolean = false

        mapView.mapboxMap.mapStyle = .standard {
            FillLayer(id: "first", source: "test-source")
            LineLayer(id: "second", source: "test-source")
            SymbolLayer(id: "third", source: "test-source")
            CircleLayer(id: "fourth", source: "test-source")
            HeatmapLayer(id: "fifth", source: "test-source")
            if boolean {
                FillExtrusionLayer(id: "sixth", source: "test-source")
            }
            RasterLayer(id: "seventh", source: "test-source")
            HillshadeLayer(id: "eighth", source: "test-source")
            ModelLayer(id: "ninth", source: "test-source")
        }

        didBecomeIdle = { mapView in
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers.count, 8)
            // New layers should be added in order to the top of the layer stack
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[0].id, "first")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[1].id, "second")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[2].id, "third")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[3].id, "fourth")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[4].id, "fifth")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[5].id, "seventh")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[6].id, "eighth")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[7].id, "ninth")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

    internal func testBuildEitherAndOptional() {
        let expectation = self.expectation(description: "Wait for mapStyle to load")
        expectation.expectedFulfillmentCount = 1

        enum TestValue {
            case one
            case two
            case three
        }

        let boolean = true
        let enumTestValue = TestValue.two

        mapView.mapboxMap.mapStyle = .standard {
            FillLayer(id: "first", source: "test-source")
            switch enumTestValue {
            case .one:
                LineLayer(id: "second", source: "test-source")
            case .two:
                SymbolLayer(id: "third", source: "test-source")
            case .three:
                CircleLayer(id: "fourth", source: "test-source")
            }
            if boolean {
                HeatmapLayer(id: "fifth", source: "test-source")
            }
        }

        didBecomeIdle = { mapView in
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers.count, 3)
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[0].id, "first")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[1].id, "third")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[2].id, "fifth")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

    internal func testAddRemoveSourceAndLayer() {
        let expectation = self.expectation(description: "Wait for mapStyle to load")
        expectation.expectedFulfillmentCount = 2

        let features = [
            Feature(geometry: Point(CLLocationCoordinate2D(latitude: 0, longitude: 0)))
        ]

        let source = GeoJSONSource(id: "test-source")
            .data(.featureCollection(FeatureCollection(features: features)))
        let layer = LineLayer(id: "line", source: "test-source")

        var boolean = true

        mapView.mapboxMap.mapStyle = .standard {
            if boolean {
                source
                layer
            }
        }

        didFinishLoadingStyle = { mapView in
            XCTAssertEqual(mapView.mapboxMap.allSourceIdentifiers.count, 1)
            XCTAssertEqual(mapView.mapboxMap.allSourceIdentifiers[0].id, "test-source")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers.count, 1)
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[0].id, "line")

            boolean = false

            mapView.mapboxMap.mapStyle = .standard {
                if boolean {
                    source
                    layer
                }
            }
            expectation.fulfill()
        }

        didBecomeIdle = { mapView in
            XCTAssertEqual(mapView.mapboxMap.allSourceIdentifiers.count, 0)
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers.count, 0)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }
}
