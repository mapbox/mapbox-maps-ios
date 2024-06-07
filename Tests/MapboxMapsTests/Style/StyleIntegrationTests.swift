import XCTest
@_spi(Experimental) @testable import MapboxMaps

internal class StyleIntegrationTests: MapViewIntegrationTestCase {

    internal func testUpdateStyleLayer() throws {
        let expectation = XCTestExpectation(description: "Manipulating style succeeded")
        expectation.expectedFulfillmentCount = 3

        mapView.mapboxMap.styleURI = .streets

        didFinishLoadingStyle = { mapView in

            var newBackgroundLayer = BackgroundLayer(id: "test-id")
            newBackgroundLayer.backgroundColor = .constant(StyleColor(.white))
            newBackgroundLayer.backgroundColorTransition = .init(duration: 2, delay: 1)

            do {
                try mapView.mapboxMap.addLayer(newBackgroundLayer)
                expectation.fulfill()
            } catch {
                XCTFail("Could not add background layer due to error: \(error)")
            }

            do {
                try mapView.mapboxMap.updateLayer(withId: newBackgroundLayer.id, type: BackgroundLayer.self) { layer in
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
                let retrievedLayer = try mapView.mapboxMap.layer(withId: newBackgroundLayer.id, type: BackgroundLayer.self)
                XCTAssert(retrievedLayer.backgroundColor == .constant(StyleColor(.blue)))
                XCTAssertEqual(retrievedLayer.minZoom, 10)

                let defaultBackgroundColorTransition = try XCTUnwrap(StyleManager.layerPropertyDefaultValue(for: newBackgroundLayer.type, property: "background-color-transition").value as? [String: TimeInterval])
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

        let expectation = XCTestExpectation(description: "Move style layer succeeded")
        expectation.expectedFulfillmentCount = 2

        mapView.mapboxMap.styleURI = .streets

        didFinishLoadingStyle = { mapView in

            let layers = mapView.mapboxMap.allLayerIdentifiers
            let newBackgroundLayer = BackgroundLayer(id: "test-id")

            do {
                try mapView.mapboxMap.addLayer(newBackgroundLayer)
                expectation.fulfill()
            } catch {
                XCTFail("Could not add background layer due to error: \(error)")
            }

            // Move layer, repeatedly
            do {
                for step in stride(from: 0, to: layers.count, by: 3) {

                    try mapView.mapboxMap.moveLayer(withId: "test-id", to: .at(step))

                    // Get layer position
                    let layers = mapView.mapboxMap.allLayerIdentifiers

                    let position = layers.firstIndex(where: { $0.id == "test-id" })
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

        let addLayerExpectation = XCTestExpectation(description: "Adding a persistent style layer succeeded.")
        let persistenceExpectation = XCTestExpectation(description: "The layer should still be persistent after repeatedly moving.")

        let layerId = "test-id"
        mapView.mapboxMap.styleURI = .streets

        didFinishLoadingStyle = { mapView in

            let layers = mapView.mapboxMap.allLayerIdentifiers
            let newBackgroundLayer = BackgroundLayer(id: layerId)

            do {
                try mapView.mapboxMap.addPersistentLayer(newBackgroundLayer)
                addLayerExpectation.fulfill()
            } catch {
                XCTFail("Could not add background layer due to error: \(error)")
            }

            // Move layer, repeatedly
            do {
                for step in stride(from: 0, to: layers.count, by: 3) {

                    try mapView.mapboxMap.moveLayer(withId: layerId, to: .at(step))

                    // Get layer position
                    let layers = mapView.mapboxMap.allLayerIdentifiers
                    let layerIds = layers.map { $0.id }

                    let position = layerIds.firstIndex(of: layerId)
                    XCTAssertEqual(position, step)

                    let isPersistent = try mapView.mapboxMap.isPersistentLayer(id: layerId)
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
        let expectedLayerCount = 134 // The current number of layers

        let expectation = XCTestExpectation(description: "Getting style layers succeeded")
        expectation.expectedFulfillmentCount = expectedLayerCount

        didFinishLoadingStyle = { mapView in
            let layerIds = mapView.mapboxMap.allLayerIdentifiers
            XCTAssertEqual(layerIds.count, expectedLayerCount)

            for layerId in layerIds {
                do {
                    _ = try mapView.mapboxMap.layer(withId: layerId.id)
                    expectation.fulfill()
                } catch {
                    XCTFail("Failed to get line layer with id \(layerId.id), error \(error)")
                }
            }
        }

        mapView.mapboxMap.styleURI = .streets

        wait(for: [expectation], timeout: 5.0)
    }

    func testGetLocaleValueBaseCase() {
        let locale = Locale(identifier: "es")
        let localeValue = mapView.mapboxMap.getLocaleValue(locale: locale)

        XCTAssertEqual(localeValue, "es")
    }

    func testGetLocaleValueForUnsupportedScriptAndRegionCode() {
        let locale = Locale(identifier: "en-US")
        let localeValue = mapView.mapboxMap.getLocaleValue(locale: locale)

        XCTAssertEqual(localeValue, "en")
    }

    func testGetLocaleValueForUnsupportedLanguage() {
        let locale = Locale(identifier: "hi")
        let localeValue = mapView.mapboxMap.getLocaleValue(locale: locale)

        XCTAssertNil(localeValue)
    }

    func testGetLocaleValueForCustomV8Style() {
        var source = VectorSource(id: "v8-source")
        source.url = "https://mapbox.mapbox-streets-v8"
        try! mapView.mapboxMap.addSource(source)

        let locale = Locale(identifier: "zh-Hant-TW")
        let localeValue = mapView.mapboxMap.getLocaleValue(locale: locale)

        XCTAssertEqual(localeValue, "zh-Hant")
    }

    func testGetLocaleValueForCustomV7Style() {
        var source = VectorSource(id: "v7-source")
        source.url = "https://mapbox.mapbox-streets-v7"
        try! mapView.mapboxMap.addSource(source)

        let locale = Locale(identifier: "zh-Hant")
        let localeValue = mapView.mapboxMap.getLocaleValue(locale: locale)

        XCTAssertEqual(localeValue, "zh")
    }

    func testConvertExpression() {
        var symbolLayer = SymbolLayer(id: "testLayer", source: "source")
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

        XCTAssertNoThrow {
            let convertedExpression = try self.mapView.mapboxMap.convertExpressionForLocalization(symbolLayer: symbolLayer, localeValue: "zh")
            let data = try JSONSerialization.data(withJSONObject: XCTUnwrap(convertedExpression), options: [.prettyPrinted])
            let convertedString = String(decoding: data, as: UTF8.self).replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "\n", with: "")

            let result = "[\"format\",[\"coalesce\",[\"get\",\"name_zh\"],[\"get\",\"name\"]]]"
            XCTAssertEqual(result, convertedString)
        }
    }

    func testLocalizeLabelsv7() throws {
        let mapView = MapView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))

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
                        "text-field": ["coalesce", ["get", "name_en"], ["get", "name"]] as [Any],
                    ],
                ] as [String: Any],
            ],
        ]

        let styleJSON: String =  String(decoding: try! JSONSerialization.data(withJSONObject: styleJSONObject, options: [.prettyPrinted]), as: UTF8.self)
        XCTAssertFalse(styleJSON.isEmpty, "ValueConverter should create valid JSON string.")

        let styleJSONFinishedLoading = expectation(description: "Style JSON has finished loading")
        mapView.mapboxMap.loadStyle(styleJSON) { _ in
            styleJSONFinishedLoading.fulfill()
        }

        wait(for: [styleJSONFinishedLoading], timeout: 10.0)

        XCTAssertEqual(mapView.mapboxMap.allSourceIdentifiers.count, 1)
        XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers.count, 1)

        func textFieldExpression(layerIdentifier: String) -> Exp? {
            let expressionArray = mapView.mapboxMap.layerProperty(for: layerIdentifier, property: "text-field").value

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
        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "ar"))
        assert(placeLabelProperty: "name_ar")

        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "en"))
        assert(placeLabelProperty: "name_en")

        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "es"))
        assert(placeLabelProperty: "name_es")

        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "fr"))
        assert(placeLabelProperty: "name_fr")

        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "de"))
        assert(placeLabelProperty: "name_de")

        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "pt"))
        assert(placeLabelProperty: "name_pt")

        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "ru"))
        assert(placeLabelProperty: "name_ru")

        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "ja"))
        assert(placeLabelProperty: "name_ja")

        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "ko"))
        assert(placeLabelProperty: "name_ko")

        XCTAssertThrowsError(try mapView.mapboxMap.localizeLabels(into: Locale(identifier: "vi")), "Vietnamese not availabe in Streets v7")

        XCTAssertThrowsError(try mapView.mapboxMap.localizeLabels(into: Locale(identifier: "it")), "Italian not availabe in Streets v7")

        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "zh-Hant-TW"))
        assert(placeLabelProperty: "name_zh")

        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "zh-Hant-HK"))
        assert(placeLabelProperty: "name_zh")

        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "zh-Hans-CN"))
        assert(placeLabelProperty: "name_zh-Hans")

        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "zh_Hant-TW"))
        assert(placeLabelProperty: "name_zh")

        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "zh_Hant-HK"))
        assert(placeLabelProperty: "name_zh")

        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "zh_Hans-CN"))
        assert(placeLabelProperty: "name_zh-Hans")

        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "zh_Hant_TW"))
        assert(placeLabelProperty: "name_zh")

        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "zh_Hant_HK"))
        assert(placeLabelProperty: "name_zh")

        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "zh_Hans_CN"))
        assert(placeLabelProperty: "name_zh-Hans")

        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "zh-Hant-TW"))
        assert(placeLabelProperty: "name_zh")

        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "zh-Hant-HK"))
        assert(placeLabelProperty: "name_zh")

        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "zh-Hans-CN"))
        assert(placeLabelProperty: "name_zh-Hans")
    }

    func testLocalizeLabelsv8() throws {
        let mapView = MapView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))

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
                        "text-field": ["coalesce", ["get", "name_en"], ["get", "name"]] as [Any],
                    ],
                ] as [String: Any],
            ],
        ]

        let styleJSON: String = ValueConverter.toJson(forValue: styleJSONObject)
        XCTAssertFalse(styleJSON.isEmpty, "ValueConverter should create valid JSON string.")

        let styleJSONFinishedLoading = expectation(description: "Style JSON has finished loading")
        mapView.mapboxMap.loadStyle(styleJSON) { _ in
            styleJSONFinishedLoading.fulfill()
        }

        wait(for: [styleJSONFinishedLoading], timeout: 10.0)

        XCTAssertEqual(mapView.mapboxMap.allSourceIdentifiers.count, 1)
        XCTAssertEqual(mapView.mapboxMap.allLayerIdentifiers.count, 1)

        func textFieldExpression(layerIdentifier: String) -> Exp? {
            let expressionArray = mapView.mapboxMap.layerProperty(for: layerIdentifier, property: "text-field").value

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
        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "ar"))
        assert(placeLabelProperty: "name_ar")

        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "en"))
        assert(placeLabelProperty: "name_en")

        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "es"))
        assert(placeLabelProperty: "name_es")

        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "fr"))
        assert(placeLabelProperty: "name_fr")

        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "de"))
        assert(placeLabelProperty: "name_de")

        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "pt"))
        assert(placeLabelProperty: "name_pt")

        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "ru"))
        assert(placeLabelProperty: "name_ru")

        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "ja"))
        assert(placeLabelProperty: "name_ja")

        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "ko"))
        assert(placeLabelProperty: "name_ko")

        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "vi"))
        assert(placeLabelProperty: "name_vi")

        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "it"))
        assert(placeLabelProperty: "name_it")

        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "zh-Hant-TW"))
        assert(placeLabelProperty: "name_zh-Hant")

        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "zh-Hant-HK"))
        assert(placeLabelProperty: "name_zh-Hant")

        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "zh-Hans-CN"))
        assert(placeLabelProperty: "name_zh-Hans")

        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "zh_Hant_TW"))
        assert(placeLabelProperty: "name_zh-Hant")

        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "zh_Hant_HK"))
        assert(placeLabelProperty: "name_zh-Hant")

        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "zh_Hans_CN"))
        assert(placeLabelProperty: "name_zh-Hans")

        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "zh_Hant-TW"))
        assert(placeLabelProperty: "name_zh-Hant")

        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "zh_Hant-HK"))
        assert(placeLabelProperty: "name_zh-Hant")

        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "zh_Hans-CN"))
        assert(placeLabelProperty: "name_zh-Hans")

        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "zh-Hant_TW"))
        assert(placeLabelProperty: "name_zh-Hant")

        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "zh-Hant_HK"))
        assert(placeLabelProperty: "name_zh-Hant")

        try! mapView.mapboxMap.localizeLabels(into: Locale(identifier: "zh-Hans_CN"))
        assert(placeLabelProperty: "name_zh-Hans")

        XCTAssertThrowsError(try mapView.mapboxMap.localizeLabels(into: Locale(identifier: "jkls")), "Locale string needs to match exactly")
    }

    func testTerrain() throws {
        let sourceId = String.testConstantValue()
        let exaggeration = Double.testConstantValue()

        let sourcePropertyName = "source"
        let exaggerationPropertyName = "exaggeration"
        let exaggerationTransitionPropertyName = "exaggeration-transition"

        mapView.mapboxMap.mapStyle = .standard

        var sourceTerrainProperty: Any = mapView.mapboxMap.terrainProperty(sourcePropertyName)
        var exaggerationTerrainProperty: Any = mapView.mapboxMap.terrainProperty(exaggerationPropertyName)
        var exaggerationTransitionProperty: Any = mapView.mapboxMap.terrainProperty(exaggerationTransitionPropertyName)

        XCTAssertTrue(sourceTerrainProperty is NSNull)
        XCTAssertTrue(exaggerationTerrainProperty is NSNull)
        XCTAssertTrue(exaggerationTransitionProperty is NSNull)

        var terrain = Terrain(sourceId: sourceId)
        terrain.exaggeration = .constant(exaggeration)
        terrain.exaggerationTransition = StyleTransition(duration: 1, delay: 1)

        try mapView.mapboxMap.setTerrain(terrain)

        sourceTerrainProperty = mapView.mapboxMap.terrainProperty(sourcePropertyName)
        exaggerationTerrainProperty = mapView.mapboxMap.terrainProperty(exaggerationPropertyName)
        guard let exaggerationTransitionPropertyStyleTransition = try? JSONDecoder().decode(StyleTransition.self, from: JSONSerialization.data(withJSONObject: mapView.mapboxMap.terrainProperty(exaggerationTransitionPropertyName).value, options: [])) else {
            XCTFail("Failed to read Terrain exaggeration transition")
            return
        }

        XCTAssertEqual(sourceTerrainProperty as? String, sourceId)
        let exaggerationTerrainPropertyDouble = try XCTUnwrap(exaggerationTerrainProperty as? Double)
        // convert to float and back to double to work around precision mismatch
        XCTAssertEqual(exaggerationTerrainPropertyDouble, Double(Float(exaggeration)))
        XCTAssertEqual(exaggerationTransitionPropertyStyleTransition, StyleTransition(duration: 1, delay: 1))

        mapView.mapboxMap.removeTerrain()

        sourceTerrainProperty = mapView.mapboxMap.terrainProperty(sourcePropertyName)
        exaggerationTerrainProperty = mapView.mapboxMap.terrainProperty(exaggerationPropertyName)
        exaggerationTransitionProperty = mapView.mapboxMap.terrainProperty(exaggerationTransitionPropertyName)

        XCTAssertEqual(sourceTerrainProperty as? String, "")
        XCTAssertTrue(exaggerationTerrainProperty is NSNull)
        XCTAssertTrue(exaggerationTransitionProperty is NSNull)
    }

    func testOnlyAddedDataIdReturned() {
        let source = GeoJSONSource(id: "Source")
        let source2 = GeoJSONSource(id: "Source2")
        let geometry = Geometry.point(Point.init(LocationCoordinate2D(latitude: 0, longitude: 0)))
        let dataId = "TestdataId"
        let expectation = XCTestExpectation(description: "dataId returned when source updated")
        expectation.expectedFulfillmentCount = 1
        expectation.assertForOverFulfill = true

        var returnedSourceDataId: String?

        try! mapView.mapboxMap.addSource(source)
        try! mapView.mapboxMap.addSource(source2)

        mapView.mapboxMap.onSourceDataLoaded.observe { event in
            returnedSourceDataId = event.dataId
            XCTAssertEqual(returnedSourceDataId, dataId)

            expectation.fulfill()
        }.store(in: &cancelables)

        mapView.mapboxMap.updateGeoJSONSource(withId: source.id, geoJSON: .geometry(geometry), dataId: dataId)

        wait(for: [expectation], timeout: 3.0)
    }

    func testCustomLayerAdd() throws {
        let customLayer = CustomLayer(id: "test-layer", renderer: MockCustomRenderer(), slot: "test-slot")

        try mapView.mapboxMap.addLayer(customLayer)
        let decodedLayer = try mapView.mapboxMap.layer(withId: customLayer.id, type: type(of: customLayer))

        XCTAssertEqual(decodedLayer.id, customLayer.id)
        XCTAssertEqual(decodedLayer.slot, customLayer.slot)
        XCTAssertFalse(try mapView.mapboxMap.isPersistentLayer(id: customLayer.id))
    }

    func testCustomLayerAddPersistent() throws {
        let customLayer = CustomLayer(id: "test-layer", renderer: MockCustomRenderer(), slot: "test-slot")

        try mapView.mapboxMap.addPersistentLayer(customLayer)
        let decodedLayer = try mapView.mapboxMap.layer(withId: customLayer.id, type: type(of: customLayer))

        XCTAssertEqual(decodedLayer.id, customLayer.id)
        XCTAssertEqual(decodedLayer.slot, customLayer.slot)
        XCTAssertTrue(try mapView.mapboxMap.isPersistentLayer(id: customLayer.id))
    }

    func testCustomLayerThrowsOnEmptyCustomRenderer() throws {
        let customLayer = CustomLayer(id: "test-layer", renderer: EmptyCustomRenderer())

        // Do not throw when we are adding `EmptyCustomRenderer` explicitly
        XCTAssertThrowsError(try mapView.mapboxMap.addLayer(customLayer)) { error in
            XCTAssert(error is StyleError)
            XCTAssert(error.localizedDescription.contains("CustomLayer"))
        }
    }

    func testCustomLayerThrowsOnReadd() throws {
        let customLayer = CustomLayer(id: "test-layer", renderer: EmptyCustomRenderer(shouldWarnBeforeUsage: false))

        // Do not throw when we are adding `EmptyCustomRenderer` explicitly
        XCTAssertNoThrow(try mapView.mapboxMap.addLayer(customLayer))

        let decodedLayer = try mapView.mapboxMap.layer(withId: customLayer.id, type: type(of: customLayer))

        XCTAssertNotIdentical(decodedLayer.renderer, customLayer.renderer)

        try mapView.mapboxMap.removeLayer(withId: decodedLayer.id)

        XCTAssertThrowsError(try mapView.mapboxMap.addLayer(decodedLayer)) { error in
            XCTAssert(error is StyleError)
            XCTAssert(error.localizedDescription.contains("CustomLayer"))
        }
    }

    func testEmptyCustomRenderer() throws {
        let customLayer = CustomLayer(id: "test-layer", renderer: EmptyCustomRenderer(shouldWarnBeforeUsage: false))

        try mapView.mapboxMap.addLayer(customLayer)

        let renderExpectation = expectation(description: "Wait for render call")
        DispatchQueue.main.async {
            renderExpectation.fulfill()
        }

        wait(for: [renderExpectation], timeout: 1)
    }

    func testUpdateProjection() throws {
        mapView.mapboxMap.styleURI = .satelliteStreets

        let projection = StyleProjection(name: .globe)

        try mapView.mapboxMap.setProjection(projection)

        XCTAssertEqual(projection, mapView.mapboxMap.projection)
    }
}
