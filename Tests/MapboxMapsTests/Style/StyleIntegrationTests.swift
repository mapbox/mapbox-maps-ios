import XCTest
@testable import MapboxMaps

internal class StyleIntegrationTests: MapViewIntegrationTestCase {

    internal func testUpdateStyleLayer() throws {
        guard
            let style = style else {
            XCTFail("There should be valid MapView and Style objects created by setUp.")
            return
        }

        let expectation = XCTestExpectation(description: "Manipulating style succeeded")
        expectation.expectedFulfillmentCount = 3

        style.uri = .streets

        didFinishLoadingStyle = { _ in

            var newBackgroundLayer = BackgroundLayer(id: "test-id")
            newBackgroundLayer.backgroundColor = .constant(StyleColor(.white))
            newBackgroundLayer.backgroundColorTransition = .init(duration: 2, delay: 1)

            do {
                try style.addLayer(newBackgroundLayer)
                expectation.fulfill()
            } catch {
                XCTFail("Could not add background layer due to error: \(error)")
            }

            do {
                try style.updateLayer(withId: newBackgroundLayer.id, type: BackgroundLayer.self) { layer in
                    // Update property
                    layer.backgroundColor = .constant(StyleColor(.blue))
                    // Reset property
                    layer.backgroundColorTransition = nil
                    // New property
                    layer.minZoom = 10
                }
                expectation.fulfill()
            } catch {
                XCTFail("Could not update background layer due to error: \(error)")
            }

            do {
                let retrievedLayer = try style.layer(withId: newBackgroundLayer.id, type: BackgroundLayer.self)
                XCTAssert(retrievedLayer.backgroundColor == .constant(StyleColor(.blue)))
                XCTAssertEqual(retrievedLayer.minZoom, 10)

                let defaultBackgroundColorTransition = try XCTUnwrap(Style.layerPropertyDefaultValue(for: newBackgroundLayer.type, property: "background-color-transition").value as? [String: TimeInterval])
                XCTAssertEqual(retrievedLayer.backgroundColorTransition!.duration * 1000.0, defaultBackgroundColorTransition["duration"])
                XCTAssertEqual(retrievedLayer.backgroundColorTransition!.delay * 1000.0, defaultBackgroundColorTransition["delay"])

                expectation.fulfill()
            } catch {
                XCTFail("Could not retrieve background layer due to error: \(error)")
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }

    internal func testMoveStyleLayer() throws {
        guard
            let style = style else {
            XCTFail("There should be valid MapView and Style objects created by setUp.")
            return
        }

        let expectation = XCTestExpectation(description: "Move style layer succeeded")
        expectation.expectedFulfillmentCount = 2

        style.uri = .streets

        didFinishLoadingStyle = { _ in

            let layers = style.styleManager.getStyleLayers()
            let newBackgroundLayer = BackgroundLayer(id: "test-id")

            do {
                try style.addLayer(newBackgroundLayer)
                expectation.fulfill()
            } catch {
                XCTFail("Could not add background layer due to error: \(error)")
            }

            // Move layer, repeatedly
            do {
                for step in stride(from: 0, to: layers.count, by: 3) {

                    try style.moveLayer(withId: "test-id", to: .at(step))

                    // Get layer position
                    let layers = style.styleManager.getStyleLayers()
                    let layerIds = layers.map { $0.id }

                    let position = layerIds.firstIndex(of: "test-id")
                    XCTAssertEqual(position, step)
                }

                expectation.fulfill()
            } catch {
                XCTFail("_moveLayer failed with \(error)")
            }
        }

        wait(for: [expectation], timeout: 5.0)
    }

    func testMovePersistentLayer() {
        guard
            let style = style else {
            XCTFail("There should be valid MapView and Style objects created by setUp.")
            return
        }

        let addLayerExpectation = XCTestExpectation(description: "Adding a persistent style layer succeeded.")
        let persistenceExpectation = XCTestExpectation(description: "The layer should still be persistent after repeatedly moving.")

        let layerId = "test-id"
        style.uri = .streets

        didFinishLoadingStyle = { _ in

            let layers = style.allLayerIdentifiers
            let newBackgroundLayer = BackgroundLayer(id: layerId)

            do {
                try style.addPersistentLayer(newBackgroundLayer)
                addLayerExpectation.fulfill()
            } catch {
                XCTFail("Could not add background layer due to error: \(error)")
            }

            // Move layer, repeatedly
            do {
                for step in stride(from: 0, to: layers.count, by: 3) {

                    try style.moveLayer(withId: layerId, to: .at(step))

                    // Get layer position
                    let layers = style.styleManager.getStyleLayers()
                    let layerIds = layers.map { $0.id }

                    let position = layerIds.firstIndex(of: layerId)
                    XCTAssertEqual(position, step)

                    let isPersistent = try style.isPersistentLayer(id: layerId)
                    XCTAssertTrue(isPersistent)
                }

                persistenceExpectation.fulfill()
            } catch {
                XCTFail("_moveLayer failed with \(error)")
            }
        }

        wait(for: [addLayerExpectation, persistenceExpectation], timeout: 5.0)
    }

    func testDecodingOfAllLayersInStreetsv11() {
        guard let style = style else {
            XCTFail("There should be valid MapView and Style objects created by setUp.")
            return
        }
        let expectedLayerCount = 111 // The current number of layers

        let expectation = XCTestExpectation(description: "Getting style layers succeeded")
        expectation.expectedFulfillmentCount = expectedLayerCount

        didFinishLoadingStyle = { _ in
            let layerIds = style.allLayerIdentifiers
            XCTAssertEqual(layerIds.count, expectedLayerCount)

            for layerId in layerIds {
                do {
                    _ = try style.layer(withId: layerId.id)
                    expectation.fulfill()
                } catch {
                    XCTFail("Failed to get line layer with id \(layerId.id), error \(error)")
                }
            }
        }

        style.uri = .streets

        wait(for: [expectation], timeout: 5.0)
    }

    func testGetLocaleValueBaseCase() {
        let locale = Locale(identifier: "es")
        let localeValue = style!.getLocaleValue(locale: locale)

        XCTAssertEqual(localeValue, "es")
    }

    func testGetLocaleValueForUnsupportedScriptAndRegionCode() {
        let locale = Locale(identifier: "en-US")
        let localeValue = style!.getLocaleValue(locale: locale)

        XCTAssertEqual(localeValue, "en")
    }

    func testGetLocaleValueForUnsupportedLanguage() {
        let locale = Locale(identifier: "hi")
        let localeValue = style!.getLocaleValue(locale: locale)

        XCTAssertNil(localeValue)
    }

    func testGetLocaleValueForCustomV8Style() {
        var source = VectorSource()
        source.url = "https://mapbox.mapbox-streets-v8"
        try! style!.addSource(source, id: "v8-source")

        let locale = Locale(identifier: "zh-Hant-TW")
        let localeValue = style!.getLocaleValue(locale: locale)

        XCTAssertEqual(localeValue, "zh-Hant")
    }

    func testGetLocaleValueForCustomV7Style() {
        var source = VectorSource()
        source.url = "https://mapbox.mapbox-streets-v7"
        try! style!.addSource(source, id: "v7-source")

        let locale = Locale(identifier: "zh-Hant")
        let localeValue = style!.getLocaleValue(locale: locale)

        XCTAssertEqual(localeValue, "zh")
    }

    func testConvertExpression() {
        var symbolLayer = SymbolLayer(id: "testLayer")
        let originalExpression = Exp(.format) {
            Exp(.coalesce) {
                Exp(.get) {
                    "name_en"
                }
                Exp(.get) {
                    "name"
                }
            }
        }
        symbolLayer.textField = .expression(originalExpression)

        let convertedExpression = try! style!.convertExpressionForLocalization(symbolLayer: symbolLayer, localeValue: "zh")

        let data = try! JSONSerialization.data(withJSONObject: convertedExpression!, options: [.prettyPrinted])
        let convertedString = String(data: data, encoding: .utf8)!.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "")

        let result = "[\"format\",[\"coalesce\",[\"get\",\"name_zh\"],[\"get\",\"name\"]]]"
        XCTAssertEqual(result, convertedString)
    }

    func testLocalizeLabelsv7() {
        let resourceOptions = ResourceOptions(accessToken: "")
        let mapInitOptions = MapInitOptions(resourceOptions: resourceOptions)
        let mapView = MapView(frame: UIScreen.main.bounds, mapInitOptions: mapInitOptions)

        let styleJSONObject: [String: Any] = [
            "version": 7,
            "center": [
                -122.385563, 37.763330
            ],
            "zoom": 15,
            "sources": [
                "composite": [
                    "url": "mapbox://mapbox.mapbox-streets-v7,mapbox.mapbox-terrain-v2",
                    "type": "vector",
                ]
            ],
            "layers": [
                [
                    "id": "place-labels",
                    "type": "symbol",
                    "source": "composite",
                    "source-layer": "place",
                    "layout": [
                        "text-field": ["coalesce", ["get", "name_en"], ["get", "name"]],
                    ],
                ],
            ],
        ]

        let styleJSON: String = ValueConverter.toJson(forValue: styleJSONObject)
        XCTAssertFalse(styleJSON.isEmpty, "ValueConverter should create valid JSON string.")

        let mapLoadingErrorExpectation = expectation(description: "Map loading error expectation")
        mapLoadingErrorExpectation.assertForOverFulfill = false

        mapView.mapboxMap.onNext(event: .mapLoadingError, handler: { _ in
            mapLoadingErrorExpectation.fulfill()
        })

        mapView.mapboxMap.loadStyleJSON(styleJSON)

        wait(for: [mapLoadingErrorExpectation], timeout: 10.0)

        let style = mapView.mapboxMap.style
        XCTAssertEqual(style.allSourceIdentifiers.count, 1)
        XCTAssertEqual(style.allLayerIdentifiers.count, 1)

        func textFieldExpression(layerIdentifier: String) -> Exp? {
            let expressionArray = style.layerProperty(for: layerIdentifier, property: "text-field").value

            var expressionData: Data?
            XCTAssertNoThrow(expressionData = try JSONSerialization.data(withJSONObject: expressionArray, options: []))
            guard expressionData != nil else { return nil }

            var expression: Exp?
            XCTAssertNoThrow(expression = try JSONDecoder().decode(Exp.self, from: expressionData!))
            return expression
        }

        XCTAssertEqual(textFieldExpression(layerIdentifier: "place-labels"),
                       Exp(.format) {
                        Exp(.coalesce) { Exp(.get) { "name_en" }; Exp(.get) { "name" } }
                        FormatOptions()
                       },
                       "Place labels should be in English by default.")

        func assert(placeLabelProperty: String) {
            XCTAssertEqual(textFieldExpression(layerIdentifier: "place-labels"),
                           Exp(.format) {
                            Exp(.coalesce) { Exp(.get) { placeLabelProperty }; Exp(.get) { "name" } }
                            FormatOptions()
                           },
                           "Place labels should be localized after localization.")
        }
        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "ar"))
        assert(placeLabelProperty: "name_ar")

        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "en"))
        assert(placeLabelProperty: "name_en")

        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "es"))
        assert(placeLabelProperty: "name_es")

        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "fr"))
        assert(placeLabelProperty: "name_fr")

        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "de"))
        assert(placeLabelProperty: "name_de")

        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "pt"))
        assert(placeLabelProperty: "name_pt")

        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "ru"))
        assert(placeLabelProperty: "name_ru")

        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "ja"))
        assert(placeLabelProperty: "name_ja")

        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "ko"))
        assert(placeLabelProperty: "name_ko")

        XCTAssertThrowsError(try mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "vi")), "Vietnamese not availabe in Streets v7")

        XCTAssertThrowsError(try mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "it")), "Italian not availabe in Streets v7")

        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "zh-Hant-TW"))
        assert(placeLabelProperty: "name_zh")

        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "zh-Hant-HK"))
        assert(placeLabelProperty: "name_zh")

        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "zh-Hans-CN"))
        assert(placeLabelProperty: "name_zh-Hans")

        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "zh_Hant-TW"))
        assert(placeLabelProperty: "name_zh")

        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "zh_Hant-HK"))
        assert(placeLabelProperty: "name_zh")

        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "zh_Hans-CN"))
        assert(placeLabelProperty: "name_zh-Hans")

        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "zh_Hant_TW"))
        assert(placeLabelProperty: "name_zh")

        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "zh_Hant_HK"))
        assert(placeLabelProperty: "name_zh")

        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "zh_Hans_CN"))
        assert(placeLabelProperty: "name_zh-Hans")

        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "zh-Hant-TW"))
        assert(placeLabelProperty: "name_zh")

        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "zh-Hant-HK"))
        assert(placeLabelProperty: "name_zh")

        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "zh-Hans-CN"))
        assert(placeLabelProperty: "name_zh-Hans")
    }

    func testLocalizeLabelsv8() {
        let resourceOptions = ResourceOptions(accessToken: "")
        let mapInitOptions = MapInitOptions(resourceOptions: resourceOptions)
        let mapView = MapView(frame: UIScreen.main.bounds, mapInitOptions: mapInitOptions)

        let styleJSONObject: [String: Any] = [
            "version": 8,
            "center": [
                -122.385563, 37.763330
            ],
            "zoom": 15,
            "sources": [
                "composite": [
                    "url": "mapbox://mapbox.mapbox-streets-v8,mapbox.mapbox-terrain-v2",
                    "type": "vector",
                ]
            ],
            "layers": [
                [
                    "id": "place-labels",
                    "type": "symbol",
                    "source": "composite",
                    "source-layer": "place",
                    "layout": [
                        "text-field": ["coalesce", ["get", "name_en"], ["get", "name"]],
                    ],
                ],
            ],
        ]

        let styleJSON: String = ValueConverter.toJson(forValue: styleJSONObject)
        XCTAssertFalse(styleJSON.isEmpty, "ValueConverter should create valid JSON string.")

        let mapLoadingErrorExpectation = expectation(description: "Map loading error expectation")
        mapLoadingErrorExpectation.assertForOverFulfill = false

        mapView.mapboxMap.onNext(event: .mapLoadingError, handler: { _ in
            mapLoadingErrorExpectation.fulfill()
        })

        mapView.mapboxMap.loadStyleJSON(styleJSON)

        wait(for: [mapLoadingErrorExpectation], timeout: 10.0)

        let style = mapView.mapboxMap.style
        XCTAssertEqual(style.allSourceIdentifiers.count, 1)
        XCTAssertEqual(style.allLayerIdentifiers.count, 1)

        func textFieldExpression(layerIdentifier: String) -> Exp? {
            let expressionArray = style.layerProperty(for: layerIdentifier, property: "text-field").value

            var expressionData: Data?
            XCTAssertNoThrow(expressionData = try JSONSerialization.data(withJSONObject: expressionArray, options: []))
            guard expressionData != nil else { return nil }

            var expression: Exp?
            XCTAssertNoThrow(expression = try JSONDecoder().decode(Exp.self, from: expressionData!))
            return expression
        }

        XCTAssertEqual(textFieldExpression(layerIdentifier: "place-labels"),
                       Exp(.format) {
                        Exp(.coalesce) { Exp(.get) { "name_en" }; Exp(.get) { "name" } }
                        FormatOptions()
                       },
                       "Place labels should be in English by default.")

        func assert(placeLabelProperty: String) {
            XCTAssertEqual(textFieldExpression(layerIdentifier: "place-labels"),
                           Exp(.format) {
                            Exp(.coalesce) { Exp(.get) { placeLabelProperty }; Exp(.get) { "name" } }
                            FormatOptions()
                           },
                           "Place labels should be localized after localization.")
        }
        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "ar"))
        assert(placeLabelProperty: "name_ar")

        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "en"))
        assert(placeLabelProperty: "name_en")

        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "es"))
        assert(placeLabelProperty: "name_es")

        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "fr"))
        assert(placeLabelProperty: "name_fr")

        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "de"))
        assert(placeLabelProperty: "name_de")

        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "pt"))
        assert(placeLabelProperty: "name_pt")

        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "ru"))
        assert(placeLabelProperty: "name_ru")

        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "ja"))
        assert(placeLabelProperty: "name_ja")

        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "ko"))
        assert(placeLabelProperty: "name_ko")

        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "vi"))
        assert(placeLabelProperty: "name_vi")

        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "it"))
        assert(placeLabelProperty: "name_it")

        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "zh-Hant-TW"))
        assert(placeLabelProperty: "name_zh-Hant")

        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "zh-Hant-HK"))
        assert(placeLabelProperty: "name_zh-Hant")

        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "zh-Hans-CN"))
        assert(placeLabelProperty: "name_zh-Hans")

        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "zh_Hant_TW"))
        assert(placeLabelProperty: "name_zh-Hant")

        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "zh_Hant_HK"))
        assert(placeLabelProperty: "name_zh-Hant")

        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "zh_Hans_CN"))
        assert(placeLabelProperty: "name_zh-Hans")

        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "zh_Hant-TW"))
        assert(placeLabelProperty: "name_zh-Hant")

        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "zh_Hant-HK"))
        assert(placeLabelProperty: "name_zh-Hant")

        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "zh_Hans-CN"))
        assert(placeLabelProperty: "name_zh-Hans")

        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "zh-Hant_TW"))
        assert(placeLabelProperty: "name_zh-Hant")

        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "zh-Hant_HK"))
        assert(placeLabelProperty: "name_zh-Hant")

        try! mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "zh-Hans_CN"))
        assert(placeLabelProperty: "name_zh-Hans")

        XCTAssertThrowsError(try mapView.mapboxMap.style.localizeLabels(into: Locale(identifier: "jkls")), "Locale string needs to match exactly")
    }

    func testTerrain() throws {
        let sourceId = String.randomASCII(withLength: .random(in: 1...20))
        let exaggeration = Double.random(in: 0...1000)

        let sourcePropertyName = "source"
        let exaggerationPropertyName = "exaggeration"

        var sourceTerrainProperty: Any = style.terrainProperty(sourcePropertyName)
        var exaggerationTerrainProperty: Any = style.terrainProperty(exaggerationPropertyName)

        XCTAssertTrue(sourceTerrainProperty is NSNull)
        XCTAssertTrue(exaggerationTerrainProperty is NSNull)

        var terrain = Terrain(sourceId: sourceId)
        terrain.exaggeration = .constant(exaggeration)

        try style.setTerrain(terrain)

        sourceTerrainProperty = style.terrainProperty(sourcePropertyName)
        exaggerationTerrainProperty = style.terrainProperty(exaggerationPropertyName)

        XCTAssertEqual(sourceTerrainProperty as? String, sourceId)
        let exaggerationTerrainPropertyDouble = try XCTUnwrap(exaggerationTerrainProperty as? Double)
        // convert to float and back to double to work around precision mismatch
        XCTAssertEqual(exaggerationTerrainPropertyDouble, Double(Float(exaggeration)))

        style.removeTerrain()

        sourceTerrainProperty = style.terrainProperty(sourcePropertyName)
        exaggerationTerrainProperty = style.terrainProperty(exaggerationPropertyName)

        XCTAssertTrue(sourceTerrainProperty is NSNull)
        XCTAssertTrue(exaggerationTerrainProperty is NSNull)
    }

    func testAllSourceIdentifiersOmitsIdentifiersForCustomVectorSources() {
        // add GeoJSON source to map style
        let sourceId = "source"
        var source = GeoJSONSource()
        source.data = .empty
        try! self.style.addSource(source, id: sourceId)

        // style sources’ identifiers count increases to 1, excluding custom vector sources
        XCTAssertEqual(self.style.allSourceIdentifiers.map(\.id), [sourceId])

        // add custom source to map style
        let customSourceId = "custom-vector-source"
        let customSourceOptions = CustomGeometrySourceOptions(fetchTileFunction: { tileId in
            do {
                try self.style.setCustomGeometrySourceTileData(forSourceId: customSourceId, tileId: tileId, features: [])
            } catch {
                debugPrint(error)
            }
        }, cancelTileFunction: { _ in
            // do nothing
        }, tileOptions: TileOptions.init())
        try! self.style.addCustomGeometrySource(withId: customSourceId, options: customSourceOptions)

        // style sources’ identifiers count remains at 1, excluding custom vector sources
        XCTAssertEqual(self.style.allSourceIdentifiers.map(\.id), [sourceId])
    }

    func testOnlyAddeddataIdReturned() {
        let sourceID = "Source"
        let sourceID2 = "Source2"
        var source = GeoJSONSource()
        var source2 = GeoJSONSource()
        source.data = .empty
        source2.data = .empty
        let geometry = Geometry.point(Point.init(LocationCoordinate2D(latitude: 0, longitude: 0)))
        let dataId = "TestdataId"
        let expectation = XCTestExpectation(description: "dataId returned when source updated")
        expectation.expectedFulfillmentCount = 1
        expectation.assertForOverFulfill = true

        var returnedSourceDataId: String?

        try! self.style.addSource(source, id: sourceID)
        try! self.style.addSource(source2, id: sourceID2)

        mapView.mapboxMap.onEvery(event: .sourceDataLoaded) { event in
            returnedSourceDataId = event.payload.dataId
            XCTAssertEqual(returnedSourceDataId, dataId)

            expectation.fulfill()
        }

        try! mapView.mapboxMap.style.updateGeoJSONSource(withId: sourceID, geoJSON: .geometry(geometry), dataId: dataId)

        wait(for: [expectation], timeout: 3.0)
    }
}
