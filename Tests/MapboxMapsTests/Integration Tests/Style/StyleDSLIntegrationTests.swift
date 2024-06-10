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
            CustomLayer(id: "tenth", renderer: EmptyCustomRenderer())
        }

        didFinishLoadingStyle = { mapView in
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers.count, 10)
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
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: 9]?.id, "tenth")
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
            CustomLayer(id: "tenth", renderer: EmptyCustomRenderer())
        }

        didFinishLoadingStyle = { mapView in
            let layerCount = mapView.mapboxMap.allLayerIdentifiers.count
            XCTAssertGreaterThan(layerCount, 9)
            // New layers should be added in order to the top of the layer stack
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: layerCount-10]?.id, "first")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: layerCount-9]?.id, "second")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: layerCount-8]?.id, "third")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: layerCount-7]?.id, "fourth")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: layerCount-6]?.id, "fifth")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: layerCount-5]?.id, "sixth")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: layerCount-4]?.id, "seventh")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: layerCount-3]?.id, "eighth")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: layerCount-2]?.id, "ninth")
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: layerCount-1]?.id, "tenth")
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

        var layer = SlotLayer(id: "test-slot")
            .position(LayerPosition.above("poi-label"))

        mapView.mapboxMap.mapStyle = .streets
        mapView.mapboxMap.setMapStyleContent {
            layer
        }

        didFinishLoadingStyle = { mapView in
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers.count, 135)
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: 126]?.id, "test-slot")
            expectation.fulfill()

            layer.position = .below("poi-label")

            mapView.mapboxMap.mapStyle = .streets
            mapView.mapboxMap.setMapStyleContent {
                layer
            }
        }

        didBecomeIdle = { mapView in
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers.count, 135)
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers[safe: 125]?.id, "test-slot")
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }

    internal func testLayerPositionWithSlots() {
        let expectation = self.expectation(description: "Wait for mapStyle to load")
        expectation.expectedFulfillmentCount = 1

        let layer = SlotLayer(id: "test-slot")
            .slot(.bottom)
            .position(LayerPosition.at(0))

        mapView.mapboxMap.mapStyle = .standard
        mapView.mapboxMap.setMapStyleContent {
            layer
        }

        didFinishLoadingStyle = { mapView in
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers.count, 1)
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers.first?.id, "test-slot")
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
            LineLayer(id: "line", source: "test-source")
            SymbolLayer(id: "symbol", source: "test-source")
            CircleLayer(id: "circle", source: "test-source")
            HeatmapLayer(id: "heatmap", source: "test-source")
            FillExtrusionLayer(id: "fillextrusion", source: "test-source")
            RasterLayer(id: "raster", source: "test-source")
            HillshadeLayer(id: "hillshadeLayer", source: "test-source")
            ModelLayer(id: "model", source: "test-source")
            BackgroundLayer(id: "background")
            SkyLayer(id: "sky")
            LocationIndicatorLayer(id: "location")
            CustomLayer(id: "custom", renderer: EmptyCustomRenderer())
            SlotLayer(id: "slot")
                .position(.below("fill"))
        }

        didFinishLoadingStyle = { mapView in
            let layerIds = mapView.mapboxMap.allLayerIdentifiers
            XCTAssertEqual(layerIds.count, 148)

            let testLayerIds = [
                "slot",
                "fill",
                "line",
                "symbol",
                "circle",
                "heatmap",
                "fillextrusion",
                "raster",
                "hillshadeLayer",
                "model",
                "background",
                "sky",
                "location",
                "custom"]

            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers.map(\.id).suffix(14), testLayerIds)

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
            XCTAssertEqual(mapView.mapboxMap.styleTransition, TransitionOptions(duration: 0.3, delay: 0.0, enablePlacementTransitions: true))
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

    internal func testRestoreDefaultTerrain() {
        let expectation = self.expectation(description: "Wait for style to load and then idle")
        expectation.expectedFulfillmentCount = 2

        var terrain = Terrain(sourceId: "mapbox-dem")
        terrain.exaggeration = .testConstantValue()
        terrain.exaggerationTransition = StyleTransition(duration: 1, delay: 1)

        /// Needs to be a style with default terrain
        let styleJSONObject: [String: Any] = [
            "version": 8,
            "center": [
                -87.6298,
                 41.8781
            ],
            "terrain": ["source": "initial-source",
                        "exaggeration": 4],
            "zoom": 12,
            "sources": [Any](),
            "layers": [Any]()
        ]
        let styleJSON = ValueConverter.toJson(forValue: styleJSONObject)
        mapView.mapboxMap.mapStyle = MapStyle(json: styleJSON)

        /// 1.) Test starting values
        let startingTerrainSource: Any = mapView.mapboxMap.terrainProperty("source")
        let startingTerrainExaggeration: Any = mapView.mapboxMap.terrainProperty("exaggeration")
        XCTAssertEqual(startingTerrainSource as? String, "initial-source")
        XCTAssertEqual(startingTerrainExaggeration as? Double, 4)

        mapView.mapboxMap.setMapStyleContent {
            terrain
        }

        /// 2.) Test set values
        didFinishLoadingStyle = { mapView in
            let loadedTerrainSource: Any = mapView.mapboxMap.terrainProperty("source")
            let terrainExaggeration: Any = mapView.mapboxMap.terrainProperty("exaggeration")
            guard let terrainExaggerationTransition = try? JSONDecoder().decode(StyleTransition.self, from: JSONSerialization.data(withJSONObject: mapView.mapboxMap.terrainProperty("exaggeration-transition").value, options: [])) else {
                XCTFail("Failed to read Terrain exaggeration transition")
                return
            }
            XCTAssertEqual(loadedTerrainSource as? String, "mapbox-dem")
            XCTAssertEqual(terrainExaggeration as? Double, .testConstantValue())
            XCTAssertEqual(terrainExaggerationTransition, StyleTransition(duration: 1, delay: 1))

            expectation.fulfill()

            mapView.mapboxMap.setMapStyleContent { }
        }

        /// 3.) Test  values reset to starting values
        didBecomeIdle = { mapView in
            let loadedTerrainSource: Any = mapView.mapboxMap.terrainProperty("source")
            let terrainExaggeration: Any = mapView.mapboxMap.terrainProperty("exaggeration")
            let exaggerationTransitionProperty: Any = mapView.mapboxMap.terrainProperty("exaggeration-transition")
            XCTAssertEqual(loadedTerrainSource as? String, "initial-source")
            XCTAssertEqual(terrainExaggeration as? Double, 4)
            XCTAssertTrue(exaggerationTransitionProperty is NSNull)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10)
    }

    internal func testRestoreProjection() {
        let expectation = self.expectation(description: "Wait for style to load and then idle")
        expectation.expectedFulfillmentCount = 2

        let projection = StyleProjection(name: .mercator)

        mapView.mapboxMap.mapStyle = .standard
        mapView.mapboxMap.setMapStyleContent {
            projection
        }

        /// 1.) Test set values
        didFinishLoadingStyle = { mapView in
            let returnedProjection = mapView.mapboxMap.projection
            XCTAssertEqual(returnedProjection?.name, StyleProjectionName.mercator)

            expectation.fulfill()

            mapView.mapboxMap.setMapStyleContent { }
        }

        /// 2.) Test  values reset to starting values
        didBecomeIdle = { mapView in
            let returnedProjection = mapView.mapboxMap.projection
            XCTAssertEqual(returnedProjection?.name, StyleProjectionName.globe)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10)
    }

    internal func testRestoreAtmosphereStandardImport() {
        let expectation = self.expectation(description: "Wait for style to load and then idle")
        expectation.expectedFulfillmentCount = 2

        var atmosphere = Atmosphere()
        atmosphere.color = .constant(.testConstantValue())
        atmosphere.colorTransition = .testConstantValue()
        atmosphere.highColor = .constant(.testConstantValue())
        atmosphere.highColorTransition = .testConstantValue()
        atmosphere.horizonBlend = .testConstantValue()
        atmosphere.horizonBlendTransition = .testConstantValue()
        atmosphere.range = .constant([1.0, 2.0])
        atmosphere.rangeTransition = .testConstantValue()
        atmosphere.spaceColor = .constant(.testConstantValue())
        atmosphere.spaceColorTransition = .testConstantValue()
        atmosphere.starIntensity = .testConstantValue()
        atmosphere.starIntensityTransition = .testConstantValue()
        atmosphere.verticalRange = .constant([1.0, 2.0])
        atmosphere.verticalRangeTransition = .testConstantValue()

        /// Style which imports Standard
        let styleJSONObject: [String: Any] = [
            "version": 8,
            "center": [
                -87.6298,
                 41.8781
            ],
            "zoom": 12,
            "sources": [Any](),
            "layers": [Any](),
            "imports": [[
                "id": "standard",
                "url": "mapbox://styles/mapbox/standard",
                "config": [
                    "font": "Montserrat",
                    "lightPreset": "day",
                    "showPointOfInterestLabels": true,
                    "showTransitLabels": true,
                    "showPlaceLabels": true,
                    "showRoadLabels": true
                ] as [String: Any]
            ] as [String: Any]]
        ]
        let styleJSON = ValueConverter.toJson(forValue: styleJSONObject)
        mapView.mapboxMap.mapStyle = MapStyle(json: styleJSON)
        mapView.mapboxMap.setMapStyleContent {
            atmosphere
        }

        /// 1.) Test set values
        didFinishLoadingStyle = { mapView in
            guard case let .expression(returnedColor) = Value<StyleColor>(stylePropertyValue: mapView.mapboxMap.atmosphereProperty("color")),
                  case let .expression(returnedHighColor) = Value<StyleColor>(stylePropertyValue: mapView.mapboxMap.atmosphereProperty("high-color")),
                  case let .expression(returnedSpaceColor) = Value<StyleColor>(stylePropertyValue: mapView.mapboxMap.atmosphereProperty("space-color")),
                  let colorTransition = try? JSONDecoder().decode(StyleTransition.self, from: JSONSerialization.data(withJSONObject: mapView.mapboxMap.atmosphereProperty("color-transition").value)),
                  let highColorTransition = try? JSONDecoder().decode(StyleTransition.self, from: JSONSerialization.data(withJSONObject: mapView.mapboxMap.atmosphereProperty("high-color-transition").value)),
                  let horizonBlendTransition = try? JSONDecoder().decode(StyleTransition.self, from: JSONSerialization.data(withJSONObject: mapView.mapboxMap.atmosphereProperty("horizon-blend-transition").value)),
                  let rangeTransition = try? JSONDecoder().decode(StyleTransition.self, from: JSONSerialization.data(withJSONObject: mapView.mapboxMap.atmosphereProperty("range-transition").value)),
                  let spaceColorTransition = try? JSONDecoder().decode(StyleTransition.self, from: JSONSerialization.data(withJSONObject: mapView.mapboxMap.atmosphereProperty("space-color-transition").value)),
                  let starIntensityTransition = try? JSONDecoder().decode(StyleTransition.self, from: JSONSerialization.data(withJSONObject: mapView.mapboxMap.atmosphereProperty("star-intensity-transition").value)),
                  let verticalRangeTransition = try? JSONDecoder().decode(StyleTransition.self, from: JSONSerialization.data(withJSONObject: mapView.mapboxMap.atmosphereProperty("vertical-range-transition").value)) else {
                XCTFail("Failed to read Atmosphere properties")
                return
            }
            let color = StyleColor(expression: returnedColor)
            let highColor = StyleColor(expression: returnedHighColor)
            let spaceColor = StyleColor(expression: returnedSpaceColor)
            let horizonBlend = mapView.mapboxMap.atmosphereProperty("horizon-blend").value as? Double
            let range = mapView.mapboxMap.atmosphereProperty("range").value as? [Double]
            let starIntensity = mapView.mapboxMap.atmosphereProperty("star-intensity").value as? Double
            let verticalRange = mapView.mapboxMap.atmosphereProperty("vertical-range").value as? [Double]

            XCTAssertEqual(color, .testConstantValue())
            XCTAssertEqual(colorTransition, .testConstantValue())
            XCTAssertEqual(highColor, .testConstantValue())
            XCTAssertEqual(highColorTransition, .testConstantValue())
            XCTAssertEqual(horizonBlend, .testConstantValue())
            XCTAssertEqual(horizonBlendTransition, .testConstantValue())
            XCTAssertEqual(range, [1.0, 2.0])
            XCTAssertEqual(rangeTransition, .testConstantValue())
            XCTAssertEqual(spaceColor, .testConstantValue())
            XCTAssertEqual(spaceColorTransition, .testConstantValue())
            XCTAssertEqual(starIntensity, .testConstantValue())
            XCTAssertEqual(starIntensityTransition, .testConstantValue())
            XCTAssertEqual(verticalRange, [1.0, 2.0])
            XCTAssertEqual(verticalRangeTransition, .testConstantValue())

            expectation.fulfill()

            mapView.mapboxMap.setMapStyleContent { }
        }

        /// 2.) Test  values reset to starting values
        didBecomeIdle = { mapView in
            let returnedAtmosphereColor = mapView.mapboxMap.atmosphereProperty("color")
            let returnedTransition = mapView.mapboxMap.atmosphereProperty("color-transition")
            let returnedHighColor = mapView.mapboxMap.atmosphereProperty("high-color")
            let returnedHighColorTransition = mapView.mapboxMap.atmosphereProperty("high-color-transition")
            let returnedHorizonBlend = mapView.mapboxMap.atmosphereProperty("horizon-blend")
            let returnedHorizonBlendTransition = mapView.mapboxMap.atmosphereProperty("horizon-blend-transition")
            let returnedRange = mapView.mapboxMap.atmosphereProperty("range")
            let returnedRangeTransition = mapView.mapboxMap.atmosphereProperty("range-transition")
            let returnedSpaceColor = mapView.mapboxMap.atmosphereProperty("space-color")
            let returnedSpaceColorTransition = mapView.mapboxMap.atmosphereProperty("space-color-transition")
            let returnedStarIntensity = mapView.mapboxMap.atmosphereProperty("star-intensity")
            let returnedStarIntensityTransition = mapView.mapboxMap.atmosphereProperty("star-intensity-transition")
            let returnedVerticalRange = mapView.mapboxMap.atmosphereProperty("vertical-range")
            let returnedVerticalRangeTransition = mapView.mapboxMap.atmosphereProperty("vertical-range-transition")

            XCTAssertTrue(returnedAtmosphereColor.value is NSNull)
            XCTAssertTrue(returnedTransition.value is NSNull)
            XCTAssertTrue(returnedHighColor.value is NSNull)
            XCTAssertTrue(returnedHighColorTransition.value is NSNull)
            XCTAssertTrue(returnedHorizonBlend.value is NSNull)
            XCTAssertTrue(returnedHorizonBlendTransition.value is NSNull)
            XCTAssertTrue(returnedRange.value is NSNull)
            XCTAssertTrue(returnedRangeTransition.value is NSNull)
            XCTAssertTrue(returnedSpaceColor.value is NSNull)
            XCTAssertTrue(returnedSpaceColorTransition.value is NSNull)
            XCTAssertTrue(returnedStarIntensity.value is NSNull)
            XCTAssertTrue(returnedStarIntensityTransition.value is NSNull)
            XCTAssertTrue(returnedVerticalRange.value is NSNull)
            XCTAssertTrue(returnedVerticalRangeTransition.value is NSNull)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10)
    }

    internal func testRestoreAtmosphereStreets() {
        let expectation = self.expectation(description: "Wait for style to load and then idle")
        expectation.expectedFulfillmentCount = 2

        var atmosphere = Atmosphere()
        atmosphere.color = .constant(.testConstantValue())
        atmosphere.colorTransition = .testConstantValue()
        atmosphere.highColor = .constant(.testConstantValue())
        atmosphere.highColorTransition = .testConstantValue()
        atmosphere.horizonBlend = .testConstantValue()
        atmosphere.horizonBlendTransition = .testConstantValue()
        atmosphere.range = .constant([1.0, 2.0])
        atmosphere.rangeTransition = .testConstantValue()
        atmosphere.spaceColor = .constant(.testConstantValue())
        atmosphere.spaceColorTransition = .testConstantValue()
        atmosphere.starIntensity = .testConstantValue()
        atmosphere.starIntensityTransition = .testConstantValue()
        atmosphere.verticalRange = .constant([1.0, 2.0])
        atmosphere.verticalRangeTransition = .testConstantValue()

        mapView.mapboxMap.mapStyle = .streets
        mapView.mapboxMap.setMapStyleContent {
            atmosphere
        }

        /// 1.) Test set new values
        didFinishLoadingStyle = { mapView in
            guard case let .expression(returnedColor) = Value<StyleColor>(stylePropertyValue: mapView.mapboxMap.atmosphereProperty("color")),
                  case let .expression(returnedHighColor) = Value<StyleColor>(stylePropertyValue: mapView.mapboxMap.atmosphereProperty("high-color")),
                  case let .expression(returnedSpaceColor) = Value<StyleColor>(stylePropertyValue: mapView.mapboxMap.atmosphereProperty("space-color")),
                  let colorTransition = try? JSONDecoder().decode(StyleTransition.self, from: JSONSerialization.data(withJSONObject: mapView.mapboxMap.atmosphereProperty("color-transition").value)),
                  let highColorTransition = try? JSONDecoder().decode(StyleTransition.self, from: JSONSerialization.data(withJSONObject: mapView.mapboxMap.atmosphereProperty("high-color-transition").value)),
                  let horizonBlendTransition = try? JSONDecoder().decode(StyleTransition.self, from: JSONSerialization.data(withJSONObject: mapView.mapboxMap.atmosphereProperty("horizon-blend-transition").value)),
                  let rangeTransition = try? JSONDecoder().decode(StyleTransition.self, from: JSONSerialization.data(withJSONObject: mapView.mapboxMap.atmosphereProperty("range-transition").value)),
                  let spaceColorTransition = try? JSONDecoder().decode(StyleTransition.self, from: JSONSerialization.data(withJSONObject: mapView.mapboxMap.atmosphereProperty("space-color-transition").value)),
                  let starIntensityTransition = try? JSONDecoder().decode(StyleTransition.self, from: JSONSerialization.data(withJSONObject: mapView.mapboxMap.atmosphereProperty("star-intensity-transition").value)),
                  let verticalRangeTransition = try? JSONDecoder().decode(StyleTransition.self, from: JSONSerialization.data(withJSONObject: mapView.mapboxMap.atmosphereProperty("vertical-range-transition").value)) else {
                XCTFail("Failed to read Atmosphere properties")
                return
            }
            let color = StyleColor(expression: returnedColor)
            let highColor = StyleColor(expression: returnedHighColor)
            let spaceColor = StyleColor(expression: returnedSpaceColor)
            let horizonBlend = mapView.mapboxMap.atmosphereProperty("horizon-blend").value as? Double
            let range = mapView.mapboxMap.atmosphereProperty("range").value as? [Double]
            let starIntensity = mapView.mapboxMap.atmosphereProperty("star-intensity").value as? Double
            let verticalRange = mapView.mapboxMap.atmosphereProperty("vertical-range").value as? [Double]

            XCTAssertEqual(color, .testConstantValue())
            XCTAssertEqual(colorTransition, .testConstantValue())
            XCTAssertEqual(highColor, .testConstantValue())
            XCTAssertEqual(highColorTransition, .testConstantValue())
            XCTAssertEqual(horizonBlend, .testConstantValue())
            XCTAssertEqual(horizonBlendTransition, .testConstantValue())
            XCTAssertEqual(range, [1.0, 2.0])
            XCTAssertEqual(rangeTransition, .testConstantValue())
            XCTAssertEqual(spaceColor, .testConstantValue())
            XCTAssertEqual(spaceColorTransition, .testConstantValue())
            XCTAssertEqual(starIntensity, .testConstantValue())
            XCTAssertEqual(starIntensityTransition, .testConstantValue())
            XCTAssertEqual(verticalRange, [1.0, 2.0])
            XCTAssertEqual(verticalRangeTransition, .testConstantValue())

            expectation.fulfill()

            mapView.mapboxMap.setMapStyleContent { }
        }

        /// 2.) Test  values reset to starting values
        didBecomeIdle = { mapView in
            guard case let .expression(returnedColor) = Value<StyleColor>(stylePropertyValue: mapView.mapboxMap.atmosphereProperty("color")),
                  case let .expression(returnedHighColor) = Value<StyleColor>(stylePropertyValue: mapView.mapboxMap.atmosphereProperty("high-color")),
                  case let .expression(horizonBlend) = Value<Double>(stylePropertyValue: mapView.mapboxMap.atmosphereProperty("horizon-blend")),
                  case let .expression(returnedSpaceColor) = Value<StyleColor>(stylePropertyValue: mapView.mapboxMap.atmosphereProperty("space-color")),
                  case let .expression(starIntensity) = Value<Double>(stylePropertyValue: mapView.mapboxMap.atmosphereProperty("star-intensity")) else {
                XCTFail("Failed to read Atmosphere properties")
                return
            }
            let color = StyleColor(expression: returnedColor)
            let highColor = StyleColor(expression: returnedHighColor)
            let range = mapView.mapboxMap.atmosphereProperty("range").value as? [Double]

            let expectedSpaceColorExpression = Exp(.interpolate) {
                Exp(.exponential) {
                    1.2
                }
                Exp(.zoom)
                5
                Exp(.rgba) {
                    46.0
                    77.0
                    107.00000762939453
                    1.0
                }
                7
                Exp(.rgba) {
                    153.0
                    204.00001525878906
                    255.0
                    1.0
                }
            }

            let expectedHorizonBlendExpression = Exp(.interpolate) {
                Exp(.exponential) {
                    1.2
                }
                Exp(.zoom)
                5
                0.02
                7
                0.08
            }

            let expectedStarIntensityExpression = Exp(.interpolate) {
                Exp(.exponential) {
                    1.2
                }
                Exp(.zoom)
                5
                0.1
                7
                0
            }

            XCTAssertEqual(color, StyleColor(red: 255.00, green: 255.00, blue: 255.00, alpha: 1.00))
            XCTAssertEqual(highColor, StyleColor(red: 153.00, green: 204.00, blue: 255.00, alpha: 1.00))
            XCTAssertEqual(horizonBlend, expectedHorizonBlendExpression)
            XCTAssertEqual(range, [2.0, 20.0])
            XCTAssertEqual(returnedSpaceColor, expectedSpaceColorExpression)
            XCTAssertEqual(starIntensity, expectedStarIntensityExpression)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10)
    }

    internal func testRestoreTransitionStandard() {
        let expectation = self.expectation(description: "Wait for style to load and then idle")
        expectation.expectedFulfillmentCount = 2

        let transition = TransitionOptions.testConstantValue()

        mapView.mapboxMap.mapStyle = .standard
        mapView.mapboxMap.setMapStyleContent {
           transition
        }

        /// 1.) Test set values
        didFinishLoadingStyle = { mapView in
            let setTransition = mapView.mapboxMap.styleTransition
            XCTAssertEqual(setTransition, .testConstantValue())

            expectation.fulfill()

            mapView.mapboxMap.setMapStyleContent { }
        }

        /// 2.) Test  values reset to starting values
        didBecomeIdle = { mapView in
            let setTransition = mapView.mapboxMap.styleTransition
            XCTAssertEqual(setTransition, TransitionOptions(duration: Optional(0.3), delay: Optional(0.0), enablePlacementTransitions: Optional(true)))
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10)
    }

    internal func testRestoreTransitionStreets() {
        let expectation = self.expectation(description: "Wait for style to load and then idle")
        expectation.expectedFulfillmentCount = 2

        let transition = TransitionOptions.testConstantValue()

        mapView.mapboxMap.mapStyle = .streets
        mapView.mapboxMap.setMapStyleContent {
            transition
        }

        /// 1.) Test set values
        didFinishLoadingStyle = { mapView in
            let setTransition = mapView.mapboxMap.styleTransition
            XCTAssertEqual(setTransition, .testConstantValue())

            expectation.fulfill()

            mapView.mapboxMap.setMapStyleContent { }
        }

        /// 2.) Test  values reset to starting values
        didBecomeIdle = { mapView in
            let setTransition = mapView.mapboxMap.styleTransition
            XCTAssertEqual(setTransition, TransitionOptions(duration: Optional(0.3), delay: Optional(0.0), enablePlacementTransitions: Optional(true)))

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10)
    }

    internal func testRestoreLightsAmbientDirectional() throws {
        let expectation = self.expectation(description: "Wait for style to load and then idle")
        expectation.expectedFulfillmentCount = 2

        var ambientLight = AmbientLight(id: "ambient-light")
        ambientLight.color = .constant(.testConstantValue())
        ambientLight.colorTransition = .testConstantValue()
        ambientLight.intensity = .testConstantValue()
        ambientLight.intensityTransition = .testConstantValue()

        let directionalLight = DirectionalLight(id: "directional-light")
            .castShadows(Bool.testConstantValue())
            .color(StyleColor.testConstantValue())
            .colorTransition(.testConstantValue())
            .direction(azimuthal: 210, polar: 30)
            .directionTransition(.testConstantValue())
            .intensity(Double.testConstantValue())
            .intensityTransition(.testConstantValue())
            .shadowIntensity(Double.testConstantValue())
            .shadowIntensityTransition(.testConstantValue())

        /// Needs to be a style with default lights
        let styleJSONObject: [String: Any] = [
            "version": 8,
            "center": [
                -87.6298,
                 41.8781
            ],
            "lights": [
                [
                    "id": "directional",
                    "type": "directional",
                    "properties": [
                        "direction": [209, 29],
                        "color": "rgb(11, 123, 229)",
                        "intensity": 0.65,
                        "cast-shadows": true,
                        "shadow-intensity": 0.44
                    ]
                ],
                [
                    "id": "ambient",
                    "type": "ambient",
                    "properties": [
                        "color": "rgb(245, 20, 20)",
                        "intensity": 0.71
                    ]
                ]
            ],
            "zoom": 12,
            "sources": [Any](),
            "layers": [Any]()
        ]
        let styleJSON = ValueConverter.toJson(forValue: styleJSONObject)
        mapView.mapboxMap.mapStyle = MapStyle(json: styleJSON)
        mapView.mapboxMap.setMapStyleContent {
            directionalLight
            ambientLight
        }

        /// 1.) Test set values
        didFinishLoadingStyle = { mapView in
            let ambientColor = try? JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: mapView.mapboxMap.lightPropertyValue(for: "ambient-light", property: "color").value))
            let ambientColorTransition = try? JSONDecoder().decode(StyleTransition.self, from: JSONSerialization.data(withJSONObject: mapView.mapboxMap.lightPropertyValue(for: "ambient-light", property: "color-transition").value))
            let ambientIntensity = mapView.mapboxMap.lightPropertyValue(for: "ambient-light", property: "intensity").value as? Double
            let ambientIntensityTransition = try? JSONDecoder().decode(StyleTransition.self, from: JSONSerialization.data(withJSONObject: mapView.mapboxMap.lightPropertyValue(for: "ambient-light", property: "intensity-transition").value))

            let directionalCastShadows = mapView.mapboxMap.lightProperty(for: "directional-light", property: "cast-shadows") as? Bool
            let directionalColor = try? JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: mapView.mapboxMap.lightPropertyValue(for: "directional-light", property: "color").value))
            let directionalColorTransition = try? JSONDecoder().decode(StyleTransition.self, from: JSONSerialization.data(withJSONObject: mapView.mapboxMap.lightPropertyValue(for: "directional-light", property: "color-transition").value))
            let directionalIntensity = mapView.mapboxMap.lightPropertyValue(for: "directional-light", property: "intensity").value as? Double
            let directionalIntensityTransition = try? JSONDecoder().decode(StyleTransition.self, from: JSONSerialization.data(withJSONObject: mapView.mapboxMap.lightPropertyValue(for: "directional-light", property: "intensity-transition").value))
            let directionalDirection = mapView.mapboxMap.lightProperty(for: "directional-light", property: "direction") as? [Double]
            let directionalDirectionTransition = try? JSONDecoder().decode(StyleTransition.self, from: JSONSerialization.data(withJSONObject: mapView.mapboxMap.lightPropertyValue(for: "directional-light", property: "direction-transition").value))
            let directionalShadowIntensity = mapView.mapboxMap.lightProperty(for: "directional-light", property: "shadow-intensity") as? Double
            let directionalShadowIntensityTransition = try? JSONDecoder().decode(StyleTransition.self, from: JSONSerialization.data(withJSONObject: mapView.mapboxMap.lightPropertyValue(for: "directional-light", property: "shadow-intensity-transition").value))

            XCTAssertEqual(ambientColor, .testConstantValue())
            XCTAssertEqual(ambientColorTransition, .testConstantValue())
            XCTAssertEqual(ambientIntensity, .testConstantValue())
            XCTAssertEqual(ambientIntensityTransition, .testConstantValue())

            XCTAssertEqual(directionalCastShadows, .testConstantValue())
            XCTAssertEqual(directionalColor, .testConstantValue())
            XCTAssertEqual(directionalColorTransition, .testConstantValue())
            XCTAssertEqual(directionalIntensity, .testConstantValue())
            XCTAssertEqual(directionalIntensityTransition, .testConstantValue())
            XCTAssertEqual(directionalDirection, [210, 30])
            XCTAssertEqual(directionalDirectionTransition, .testConstantValue())
            XCTAssertEqual(directionalShadowIntensity, .testConstantValue())
            XCTAssertEqual(directionalShadowIntensityTransition, .testConstantValue())

            expectation.fulfill()

            mapView.mapboxMap.setMapStyleContent { }
        }

        /// 2.) Test  values reset to starting values
        didBecomeIdle = { mapView in
            let ambientColor = try? JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: mapView.mapboxMap.lightPropertyValue(for: "ambient", property: "color").value))
            let ambientColorTransition = mapView.mapboxMap.lightPropertyValue(for: "ambient", property: "color-transition").value
            let ambientIntensityTransition = mapView.mapboxMap.lightPropertyValue(for: "ambient", property: "intensity-transition").value

            let directionalColor = try? JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: mapView.mapboxMap.lightPropertyValue(for: "directional", property: "color").value))
            let directionalColorTransition = mapView.mapboxMap.lightPropertyValue(for: "directional", property: "color-transition").value
            let directionalIntensityTransition = mapView.mapboxMap.lightPropertyValue(for: "directional", property: "intensity-transition").value
            let directionalDirection = mapView.mapboxMap.lightProperty(for: "directional", property: "direction") as? [Double]

            guard let ambientIntensity = mapView.mapboxMap.lightPropertyValue(for: "ambient", property: "intensity").value as? Double,
            let directionalIntensity = mapView.mapboxMap.lightPropertyValue(for: "directional", property: "intensity").value as? Double,
            let directionalCastShadows = mapView.mapboxMap.lightProperty(for: "directional", property: "cast-shadows") as? Bool else {
                XCTFail("Failed casting from Any")
                return
            }

            XCTAssertEqual(ambientColor, StyleColor(red: 245, green: 20, blue: 20, alpha: 1))
            XCTAssertTrue(ambientColorTransition is NSNull)
            XCTAssertEqual(ambientIntensity, 0.71, accuracy: 0.1)
            XCTAssertTrue(ambientIntensityTransition is NSNull)

            XCTAssertEqual(directionalColor, StyleColor(red: 11, green: 123, blue: 229, alpha: 1))
            XCTAssertTrue(directionalColorTransition is NSNull)
            XCTAssertEqual(directionalIntensity, 0.71, accuracy: 0.1)
            XCTAssertTrue(directionalIntensityTransition is NSNull)
            XCTAssertTrue(directionalCastShadows)
            XCTAssertEqual(directionalDirection, [209, 29])

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10)
    }

    internal func testRestoreLightsFlat() throws {
        let expectation = self.expectation(description: "Wait for style to load and then idle")
        expectation.expectedFulfillmentCount = 2

        let flatLight = FlatLight(id: "flat-light")
            .anchor(Anchor.testConstantValue())
            .color(StyleColor.testConstantValue())
            .colorTransition(.testConstantValue())
            .intensity(Double.testConstantValue())
            .intensityTransition(.testConstantValue())
            .position(radial: 10, azimuthal: 20, polar: 30)
            .positionTransition(.testConstantValue())

        /// Needs to be a style with default lights
        let styleJSONObject: [String: Any] = [
            "version": 8,
            "center": [
                -87.6298,
                 41.8781
            ],
            "lights": [
                [
                    "id": "flat",
                    "type": "flat",
                    "properties": [
                        "color": "rgb(11, 123, 229)",
                        "intensity": 0.65
                    ]
                ]
            ],
            "zoom": 12,
            "sources": [Any](),
            "layers": [Any]()
        ]
        let styleJSON = ValueConverter.toJson(forValue: styleJSONObject)
        mapView.mapboxMap.mapStyle = MapStyle(json: styleJSON)
        mapView.mapboxMap.setMapStyleContent {
            flatLight
        }

        /// 1.) Test set values
        didFinishLoadingStyle = { mapView in
            let flatColor = try? JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: mapView.mapboxMap.lightPropertyValue(for: "flat-light", property: "color").value))
            let flatColorTransition = try? JSONDecoder().decode(StyleTransition.self, from: JSONSerialization.data(withJSONObject: mapView.mapboxMap.lightPropertyValue(for: "flat-light", property: "color-transition").value))
            let flatIntensity = mapView.mapboxMap.lightPropertyValue(for: "flat-light", property: "intensity").value as? Double
            let flatIntensityTransition = try? JSONDecoder().decode(StyleTransition.self, from: JSONSerialization.data(withJSONObject: mapView.mapboxMap.lightPropertyValue(for: "flat-light", property: "intensity-transition").value))

            XCTAssertEqual(flatColor, .testConstantValue())
            XCTAssertEqual(flatColorTransition, .testConstantValue())
            XCTAssertEqual(flatIntensity, .testConstantValue())
            XCTAssertEqual(flatIntensityTransition, .testConstantValue())

            expectation.fulfill()

            mapView.mapboxMap.setMapStyleContent { }
        }

        /// 2.) Test  values reset to starting values
        didBecomeIdle = { mapView in
            let flatColor = try? JSONDecoder().decode(StyleColor.self, from: JSONSerialization.data(withJSONObject: mapView.mapboxMap.lightPropertyValue(for: "flat", property: "color").value))
            let flatColorTransition = mapView.mapboxMap.lightPropertyValue(for: "flat", property: "color-transition").value
            let flatIntensityTransition = mapView.mapboxMap.lightPropertyValue(for: "flat", property: "intensity-transition").value
            guard let flatIntensity = mapView.mapboxMap.lightPropertyValue(for: "flat", property: "intensity").value as? Double else {
                XCTFail("Failed casting from Any")
                return
            }

            XCTAssertEqual(flatColor, StyleColor(red: 11, green: 123, blue: 229, alpha: 1))
            XCTAssertTrue(flatColorTransition is NSNull)
            XCTAssertEqual(flatIntensity, 0.71, accuracy: 0.1)
            XCTAssertTrue(flatIntensityTransition is NSNull)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10)
    }

    func testStyleImports() {
        let expectation = self.expectation(description: "Wait for mapStyle to load")
        expectation.expectedFulfillmentCount = 1
        var showFirst = false

        mapView.mapboxMap.mapStyle = .standard
        mapView.mapboxMap.setMapStyleContent {
            FillLayer(id: "first", source: "test-source")
            if showFirst {
                StyleImport(id: "import1", json: .emptyStyle)
            } else {
                StyleImport(id: "import2", json: .emptyStyle)
            }
            LineLayer(id: "second", source: "test-source")
            StyleImport(id: "import3", json: .emptyStyle)
        }

        didFinishLoadingStyle = { mapView in
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers.map(\.id), ["first", "second"])
            XCTAssertEqual(mapView.mapboxMap.allImportIdentifiers, ["basemap", "import2", "import3"])
            expectation.fulfill()
        }

        showFirst = true

        mapView.mapboxMap.setMapStyleContent {
            FillLayer(id: "first", source: "test-source")
            StyleImport(id: "import3", json: .emptyStyle)
            if showFirst {
                StyleImport(id: "import1", json: .emptyStyle)
            } else {
                StyleImport(id: "import2", json: .emptyStyle)
            }
            LineLayer(id: "second", source: "test-source")
        }

        didFinishLoadingStyle = { mapView in
            XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers.map(\.id), ["first", "second"])
            XCTAssertEqual(mapView.mapboxMap.allImportIdentifiers, ["basemap", "import3", "import1"])
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)
    }
}

private extension String {
    static let emptyStyle = "{ \"layers\": [], \"sources\": {} }"
}
