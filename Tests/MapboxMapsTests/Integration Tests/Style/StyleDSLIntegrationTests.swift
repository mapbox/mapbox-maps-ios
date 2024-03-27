import XCTest
@_spi(Experimental) @testable import MapboxMaps

@available(iOS 13.0, *)
internal class StyleDSLIntegrationTests: MapViewIntegrationTestCase {

    internal func testLayerOrder() {
        let expectation = self.expectation(description: "Wait for mapStyle to load")
        expectation.expectedFulfillmentCount = 1

        mapView.mapboxMap.mapStyle = .standard
        mapView.mapboxMap.setMapStyleContent {
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
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: 0]?.id, "first")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: 1]?.id, "second")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: 2]?.id, "third")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: 3]?.id, "fourth")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: 4]?.id, "fifth")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: 5]?.id, "sixth")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: 6]?.id, "seventh")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: 7]?.id, "eighth")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: 8]?.id, "ninth")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

    internal func testLayerOrderStreets() {
        let expectation = self.expectation(description: "Wait for mapStyle to load")
        expectation.expectedFulfillmentCount = 1

        mapView.mapboxMap.mapStyle = .streets
        mapView.mapboxMap.setMapStyleContent {
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
            XCTAssertGreaterThan(layerCount, 9)
            // New layers should be added in order to the top of the layer stack
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: layerCount-9]?.id, "first")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: layerCount-8]?.id, "second")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: layerCount-7]?.id, "third")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: layerCount-6]?.id, "fourth")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: layerCount-5]?.id, "fifth")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: layerCount-4]?.id, "sixth")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: layerCount-3]?.id, "seventh")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: layerCount-2]?.id, "eighth")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: layerCount-1]?.id, "ninth")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

    internal func testStableLayerOrder() {
        let expectation = self.expectation(description: "Wait for mapStyle to load")
        expectation.expectedFulfillmentCount = 1

        let boolean = false

        mapView.mapboxMap.mapStyle = .standard
        mapView.mapboxMap.setMapStyleContent {
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
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: 0]?.id, "first")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: 1]?.id, "second")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: 2]?.id, "third")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: 3]?.id, "fourth")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: 4]?.id, "fifth")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: 5]?.id, "seventh")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: 6]?.id, "eighth")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: 7]?.id, "ninth")
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

        mapView.mapboxMap.mapStyle = .standard
        mapView.mapboxMap.setMapStyleContent {
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
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: 0]?.id, "first")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: 1]?.id, "third")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: 2]?.id, "fifth")
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

        mapView.mapboxMap.mapStyle = .standard
        mapView.mapboxMap.setMapStyleContent {
            if boolean {
                source
                layer
            }
        }

        didFinishLoadingStyle = { mapView in
            XCTAssertEqual(mapView.mapboxMap.allSourceIdentifiers.count, 1)
            XCTAssertEqual(mapView.mapboxMap.allSourceIdentifiers.first?.id, "test-source")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers.count, 1)
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers.first?.id, "line")

            boolean = false

            mapView.mapboxMap.setMapStyleContent {
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

        wait(for: [expectation], timeout: 10)
    }

    internal func testLayerPosition() {
        let expectation = self.expectation(description: "Wait for mapStyle to load")
        expectation.expectedFulfillmentCount = 2

        var layer = FillLayer(id: "test-fill", source: "test-source")
            .position(LayerPosition.above("poi-label"))

        mapView.mapboxMap.mapStyle = .streets
        mapView.mapboxMap.setMapStyleContent {
            layer
        }

        didFinishLoadingStyle = { mapView in
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers.count, 135)
            print(mapView.mapboxMap.allLayerIdentifiers)
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: 126]?.id, "test-fill")
            expectation.fulfill()

            layer.position = .below("poi-label")

            mapView.mapboxMap.mapStyle = .streets
            mapView.mapboxMap.setMapStyleContent {
                layer
            }
        }

        didBecomeIdle = { mapView in
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers.count, 135)
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: 125]?.id, "test-fill")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

    internal func testLayerPositionWithSlots() {
        let expectation = self.expectation(description: "Wait for mapStyle to load")
        expectation.expectedFulfillmentCount = 1

        let layer = FillLayer(id: "test-line", source: "test-source")
            .slot(.bottom)
            .position(LayerPosition.at(0))

        mapView.mapboxMap.mapStyle = .standard
        mapView.mapboxMap.setMapStyleContent {
            layer
        }

        didFinishLoadingStyle = { mapView in
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers.count, 1)
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers.first?.id, "test-line")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

    internal func testLayerPositionsForAllLayerTypes() {
        let expectation = self.expectation(description: "Wait for mapStyle to load")
        expectation.expectedFulfillmentCount = 1

        mapView.mapboxMap.styleURI = .streets
        mapView.mapboxMap.setMapStyleContent {
            FillLayer(id: "fill", source: "test-source")
                .position(.at(1))
            LineLayer(id: "line", source: "test-source")
                .position(.at(2))
            SymbolLayer(id: "symbol", source: "test-source")
                .position(.at(3))
            CircleLayer(id: "circle", source: "test-source")
                .position(.at(4))
            HeatmapLayer(id: "heatmap", source: "test-source")
                .position(.at(5))
            FillExtrusionLayer(id: "fillextrusion", source: "test-source")
                .position(.at(6))
            RasterLayer(id: "raster", source: "test-source")
                .position(.at(7))
            HillshadeLayer(id: "hillshadeLayer", source: "test-source")
                .position(.at(8))
            ModelLayer(id: "model", source: "test-source")
                .position(.at(9))
            BackgroundLayer(id: "background")
                .position(.at(10))
            SkyLayer(id: "sky")
                .position(.at(11))
            LocationIndicatorLayer(id: "location")
                .position(.at(12))
        }

        didFinishLoadingStyle = { mapView in
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: 1]?.id, "fill")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: 2]?.id, "line")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: 3]?.id, "symbol")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: 4]?.id, "circle")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: 5]?.id, "heatmap")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: 6]?.id, "fillextrusion")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: 7]?.id, "raster")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: 8]?.id, "hillshadeLayer")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: 9]?.id, "model")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: 10]?.id, "background")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: 11]?.id, "sky")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: 12]?.id, "location")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

    internal func testAddAndRemoveModel() {
        let expectation = self.expectation(description: "Wait for mapStyle to load")
        expectation.expectedFulfillmentCount = 1

        let model = Model(id: "test-id", uri: .init(string: "test-URL"))

        mapView.mapboxMap.mapStyle = .standard
        mapView.mapboxMap.setMapStyleContent {
            model
        }

        didFinishLoadingStyle = { mapView in
            XCTAssertTrue(mapView.mapboxMap.hasStyleModel(modelId: "test-id"))

            // Remove model
            mapView.mapboxMap.setMapStyleContent {}
            XCTAssertFalse(mapView.mapboxMap.hasStyleModel(modelId: "test-id"))
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

    internal func testStyleTransitionOptions() {
        let expectation = self.expectation(description: "Wait for mapStyle to load")
        expectation.expectedFulfillmentCount = 2

        let transitionOptions = TransitionOptions(duration: 1, delay: 1, enablePlacementTransitions: true)
        let transitionOptions2 = TransitionOptions(duration: 4, delay: 4, enablePlacementTransitions: false)

        mapView.mapboxMap.mapStyle = .streets
        mapView.mapboxMap.setMapStyleContent {
            transitionOptions
        }

        didFinishLoadingStyle = { mapView in
            XCTAssertEqual(mapView.mapboxMap.styleTransition.delay, transitionOptions.delay)

            // Change transition options
            mapView.mapboxMap.setMapStyleContent {
                transitionOptions2
            }
            expectation.fulfill()
        }

        didBecomeIdle = { mapView in
            XCTAssertEqual(mapView.mapboxMap.styleTransition.delay, 4.0)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

    internal func testRemoveStyleTransitionOptions() {
        let expectation = self.expectation(description: "Wait for mapStyle to load")
        expectation.expectedFulfillmentCount = 2

        let transitionOptions = TransitionOptions(duration: 1, delay: 1, enablePlacementTransitions: true)

        mapView.mapboxMap.mapStyle = .streets
        mapView.mapboxMap.setMapStyleContent {
            transitionOptions
        }

        didFinishLoadingStyle = { mapView in
            XCTAssertEqual(mapView.mapboxMap.styleTransition.delay, transitionOptions.delay)

            // Remove transition options
            mapView.mapboxMap.setMapStyleContent {}
            expectation.fulfill()
        }

        didBecomeIdle = { mapView in
            XCTAssertNil(mapView.mapboxMap.styleTransition.delay)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

    internal func testDirectionalAmbientLights() {
        let expectation = self.expectation(description: "Wait for mapStyle to load")
        expectation.expectedFulfillmentCount = 2

        let directionalLights = DirectionalLight(id: "Directional")
        let ambientLights = AmbientLight(id: "Ambient")

        mapView.mapboxMap.mapStyle = .standard
        mapView.mapboxMap.setMapStyleContent {
            directionalLights
            ambientLights
        }

        didFinishLoadingStyle = { mapView in
            let lights = mapView.mapboxMap.allLightIdentifiers

            XCTAssertEqual(lights.contains(where: { lightInfo in
                lightInfo.id == "Directional"
            }), true)
            XCTAssertEqual(lights.contains(where: { lightInfo in
                lightInfo.id == "Ambient"
            }), true)

            // Remove just ambient lights
            mapView.mapboxMap.setMapStyleContent {
                directionalLights
            }
            expectation.fulfill()
        }

        didBecomeIdle = { mapView in
            // warning is logged, but lights are not removed 
            XCTAssertEqual(mapView.mapboxMap.allLightIdentifiers.count, 2)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

    internal func testFlatLights() {
        let expectation = self.expectation(description: "Wait for mapStyle to load")
        expectation.expectedFulfillmentCount = 1

        let flatLights = FlatLight(id: "flat")

        mapView.mapboxMap.mapStyle = .streets
        mapView.mapboxMap.setMapStyleContent {
            flatLights
        }

        didFinishLoadingStyle = { mapView in
            let lights = mapView.mapboxMap.allLightIdentifiers

            XCTAssertEqual(lights.contains(where: { lightInfo in
                lightInfo.id == "flat"
            }), true)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }
}
