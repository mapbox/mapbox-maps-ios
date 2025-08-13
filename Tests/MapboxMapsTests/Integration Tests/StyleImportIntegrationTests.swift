import XCTest
@_spi(Experimental) @testable import MapboxMaps

internal class StyleImportIntegrationTests: MapViewIntegrationTestCase {
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

    func testGetStyleImports() {
        let expectedStyleImports = [StyleObjectInfo(id: "standard", type: "import")]

        let styleJSON = ValueConverter.toJson(forValue: styleJSONObject)
        mapView.mapboxMap.styleJSON = styleJSON
        let getStyleImportsExpectation = XCTestExpectation(description: "Wait for imported style to load")

        mapView.mapboxMap.onMapLoaded.observe { [weak self] _ in
            let returnedStyleImports = self?.mapView.mapboxMap.styleImports
            XCTAssertEqual(expectedStyleImports.first?.id, returnedStyleImports?.first?.id)
            XCTAssertEqual(expectedStyleImports.first?.type, returnedStyleImports?.first?.type)
            getStyleImportsExpectation.fulfill()
        }.store(in: &cancelables)

        wait(for: [getStyleImportsExpectation], timeout: 5.0)
    }

    func testRemoveStyleImports() {
        let styleJSON = ValueConverter.toJson(forValue: styleJSONObject)
        mapView.mapboxMap.styleJSON = styleJSON
        let removeStyleImportsExpectation = XCTestExpectation(description: "Wait for imported style to load")

        mapView.mapboxMap.onMapLoaded.observe { [weak self] _ in
            do {
                try self?.mapView.mapboxMap.removeStyleImport(withId: "standard")
                let returnedStyleImports = self?.mapView.mapboxMap.styleImports
                XCTAssertEqual([], returnedStyleImports)
                removeStyleImportsExpectation.fulfill()
            } catch {
                XCTFail("Should remove style import")
            }
        }.store(in: &cancelables)

        wait(for: [removeStyleImportsExpectation], timeout: 5.0)
    }

    func testGetSchema() {
        let styleJSON = ValueConverter.toJson(forValue: styleJSONObject)
        mapView.mapboxMap.styleJSON = styleJSON
        let getSchemaExpectation = XCTestExpectation(description: "Wait for schema to be requested")

        mapView.mapboxMap.onMapLoaded.observe { [weak self] _ in
            do {
                let returnedSchema = try self?.mapView.mapboxMap.getStyleImportSchema(for: "standard")
                XCTAssertNotNil(returnedSchema)
                getSchemaExpectation.fulfill()
            } catch {
                XCTFail("Should get style import schema")
            }
        }.store(in: &cancelables)

        wait(for: [getSchemaExpectation], timeout: 5.0)
    }

    func testGetSchemaIncorrectId() {
        let styleJSON = ValueConverter.toJson(forValue: styleJSONObject)
        mapView.mapboxMap.styleJSON = styleJSON
        let getSchemaIncorrectIdExpectation = XCTestExpectation(description: "Wait for schema to be requested")

        mapView.mapboxMap.onMapLoaded.observe { [weak self] _ in
            do {
                _ = try self?.mapView.mapboxMap.getStyleImportSchema(for: "no_id")
            } catch {
                XCTAssertEqual(error.localizedDescription, "Import no_id does not exist")
                getSchemaIncorrectIdExpectation.fulfill()
            }
        }.store(in: &cancelables)

        wait(for: [getSchemaIncorrectIdExpectation], timeout: 5.0)
    }

    func testSetAndGetConfigProperty() {
        let expectedProperty: [String: Any] = ["showTransitLabels": false]

        let styleJSON = ValueConverter.toJson(forValue: styleJSONObject)
        mapView.mapboxMap.styleJSON = styleJSON
        let getConfigPropertyExpectation = XCTestExpectation(description: "Wait for config to be requested")

        mapView.mapboxMap.onMapLoaded.observe { [weak self] _ in
            do {
                try self?.mapView.mapboxMap.setStyleImportConfigProperty(for: "standard", config: "showTransitLabels", value: false)
                let returnedProperty = try self?.mapView.mapboxMap.getStyleImportConfigProperty(for: "standard", config: "showTransitLabels")
                XCTAssertEqual(expectedProperty["showTransitLabels"] as? Bool, returnedProperty?.value as? Bool)
                getConfigPropertyExpectation.fulfill()
            } catch {
                XCTFail("Should set style import config property")
            }
        }.store(in: &cancelables)

        wait(for: [getConfigPropertyExpectation], timeout: 5.0)
    }

    func testSetAndGetConfigProperties() {
        let expectedProperties: [String: Any] = ["font": "test", "lightPreset": "dusk", "showTransitLabels": false]

        let styleJSON = ValueConverter.toJson(forValue: styleJSONObject)
        mapView.mapboxMap.styleJSON = styleJSON
        let getConfigPropertiesExpectation = XCTestExpectation(description: "Wait for configs to be requested")

        mapView.mapboxMap.onMapLoaded.observe { [weak self] _ in
            do {
                try self?.mapView.mapboxMap.setStyleImportConfigProperties(for: "standard", configs: expectedProperties)
                let returnedProperties = try self?.mapView.mapboxMap.getStyleImportConfigProperties(for: "standard")
                XCTAssertEqual(expectedProperties["font"] as? String, returnedProperties?["font"]?.value as? String)
                XCTAssertEqual(expectedProperties["lightPreset"] as? String, returnedProperties?["lightPreset"]?.value as? String)
                XCTAssertEqual(expectedProperties["showTransitLabels"] as? Bool, returnedProperties?["showTransitLabels"]?.value as? Bool)
                getConfigPropertiesExpectation.fulfill()
            } catch {
                XCTFail("Should set style import config properties")
            }
        }.store(in: &cancelables)

        wait(for: [getConfigPropertiesExpectation], timeout: 5.0)
    }

    func testStandardStyleConfigurationIntegration() {
        let expectation = self.expectation(description: "Standard style configuration integration test")

        // Set Standard style with comprehensive configuration
        let standardStyle = MapStyle.standard(
            theme: .faded,
            lightPreset: .night,
            font: .barlow,
            showPointOfInterestLabels: true,
            showTransitLabels: false,
            showPlaceLabels: true,
            showRoadLabels: true,
            showPedestrianRoads: false,
            show3dObjects: true,
            backgroundPointOfInterestLabels: .circle,
            colorAdminBoundaries: StyleColor(.red),
            colorBuildingHighlight: StyleColor(.blue),
            colorBuildingSelect: StyleColor(.green),
            colorGreenspace: StyleColor(.cyan),
            colorModePointOfInterestLabels: .single,
            colorMotorways: StyleColor(.yellow),
            colorPlaceLabelHighlight: StyleColor(.magenta),
            colorPlaceLabels: StyleColor(.orange),
            colorPlaceLabelSelect: StyleColor(.purple),
            colorPointOfInterestLabels: StyleColor(.brown),
            colorRoadLabels: StyleColor(.gray),
            colorRoads: StyleColor(.lightGray),
            colorTrunks: StyleColor(.darkGray),
            colorWater: StyleColor(.blue),
            densityPointOfInterestLabels: 2.5,
            roadsBrightness: 0.6,
            showAdminBoundaries: false,
            showLandmarkIconLabels: true,
            showLandmarkIcons: false,
            themeData: "test-theme-data"
        )

        mapView.mapboxMap.mapStyle = standardStyle

        mapView.mapboxMap.onMapLoaded.observe { [weak self] _ in
            do {
                // Get all Standard style configurations at once
                let configs = try self?.mapView.mapboxMap.getStyleImportConfigProperties(for: "basemap")
                let configDict = try XCTUnwrap(configs)

                // Test basic configuration properties
                XCTAssertEqual(configDict["theme"]?.value as? String, "faded")
                XCTAssertEqual(configDict["lightPreset"]?.value as? String, "night")
                XCTAssertEqual(configDict["font"]?.value as? String, "Barlow")

                // Test boolean configurations
                XCTAssertEqual(configDict["showPointOfInterestLabels"]?.value as? Bool, true)
                XCTAssertEqual(configDict["showTransitLabels"]?.value as? Bool, false)
                XCTAssertEqual(configDict["showPlaceLabels"]?.value as? Bool, true)
                XCTAssertEqual(configDict["showRoadLabels"]?.value as? Bool, true)
                XCTAssertEqual(configDict["showPedestrianRoads"]?.value as? Bool, false)
                XCTAssertEqual(configDict["show3dObjects"]?.value as? Bool, true)
                XCTAssertEqual(configDict["showAdminBoundaries"]?.value as? Bool, false)

                // Test landmark icons configurations
                XCTAssertEqual(configDict["showLandmarkIconLabels"]?.value as? Bool, true)
                XCTAssertEqual(configDict["showLandmarkIcons"]?.value as? Bool, false)

                // Test enum configurations
                XCTAssertEqual(configDict["backgroundPointOfInterestLabels"]?.value as? String, "circle")
                XCTAssertEqual(configDict["colorModePointOfInterestLabels"]?.value as? String, "single")

                // Test numeric configurations
                XCTAssertEqual(configDict["densityPointOfInterestLabels"]?.value as? Double, 2.5)
                XCTAssertEqual(configDict["roadsBrightness"]?.value as? Double, 0.6)

                // Test color configurations (verify they are strings with RGBA format)
                XCTAssertEqual(configDict["colorAdminBoundaries"]?.value as? String, "rgba(255.00, 0.00, 0.00, 1.00)")
                XCTAssertEqual(configDict["colorBuildingHighlight"]?.value as? String, "rgba(0.00, 0.00, 255.00, 1.00)")
                XCTAssertEqual(configDict["colorBuildingSelect"]?.value as? String, "rgba(0.00, 255.00, 0.00, 1.00)")
                XCTAssertEqual(configDict["colorGreenspace"]?.value as? String, "rgba(0.00, 255.00, 255.00, 1.00)")
                XCTAssertEqual(configDict["colorMotorways"]?.value as? String, "rgba(255.00, 255.00, 0.00, 1.00)")
                XCTAssertEqual(configDict["colorPlaceLabelHighlight"]?.value as? String, "rgba(255.00, 0.00, 255.00, 1.00)")
                XCTAssertEqual(configDict["colorPlaceLabels"]?.value as? String, "rgba(255.00, 127.50, 0.00, 1.00)")
                XCTAssertEqual(configDict["colorPlaceLabelSelect"]?.value as? String, "rgba(127.50, 0.00, 127.50, 1.00)")
                XCTAssertEqual(configDict["colorPointOfInterestLabels"]?.value as? String, "rgba(153.00, 102.00, 51.00, 1.00)")
                XCTAssertEqual(configDict["colorRoadLabels"]?.value as? String, "rgba(127.50, 127.50, 127.50, 1.00)")
                XCTAssertEqual(configDict["colorRoads"]?.value as? String, "rgba(170.00, 170.00, 170.00, 1.00)")
                XCTAssertEqual(configDict["colorTrunks"]?.value as? String, "rgba(85.00, 85.00, 85.00, 1.00)")
                XCTAssertEqual(configDict["colorWater"]?.value as? String, "rgba(0.00, 0.00, 255.00, 1.00)")

                // Test theme data
                XCTAssertEqual(configDict["theme-data"]?.value as? String, "test-theme-data")

                expectation.fulfill()
            } catch {
                XCTFail("Failed to verify Standard style configuration: \(error)")
            }
        }.store(in: &cancelables)

        wait(for: [expectation], timeout: 10)
    }

    func testStandardSatelliteStyleConfigurationIntegration() {
        let expectation = self.expectation(description: "Standard Satellite style configuration integration test")

        // Set Standard Satellite style with comprehensive configuration
        let standardSatelliteStyle = MapStyle.standardSatellite(
            lightPreset: .dawn,
            font: .lato,
            showPointOfInterestLabels: false,
            showTransitLabels: true,
            showPlaceLabels: false,
            showRoadLabels: true,
            showRoadsAndTransit: true,
            showPedestrianRoads: true,
            backgroundPointOfInterestLabels: .noBackground,
            colorAdminBoundaries: StyleColor(.red),
            colorModePointOfInterestLabels: .default,
            colorMotorways: StyleColor(.yellow),
            colorPlaceLabelHighlight: StyleColor(.magenta),
            colorPlaceLabels: StyleColor(.orange),
            colorPlaceLabelSelect: StyleColor(.purple),
            colorPointOfInterestLabels: StyleColor(.brown),
            colorRoadLabels: StyleColor(.gray),
            colorRoads: StyleColor(.lightGray),
            colorTrunks: StyleColor(.darkGray),
            densityPointOfInterestLabels: 1.8,
            roadsBrightness: 0.7,
            showAdminBoundaries: true
        )

        mapView.mapboxMap.mapStyle = standardSatelliteStyle

        mapView.mapboxMap.onMapLoaded.observe { [weak self] _ in
            do {
                // Get all Standard Satellite style configurations at once
                let configs = try self?.mapView.mapboxMap.getStyleImportConfigProperties(for: "basemap")
                let configDict = try XCTUnwrap(configs)

                // Test basic configuration properties
                XCTAssertEqual(configDict["lightPreset"]?.value as? String, "dawn")
                XCTAssertEqual(configDict["font"]?.value as? String, "Lato")

                // Test boolean configurations
                XCTAssertEqual(configDict["showPointOfInterestLabels"]?.value as? Bool, false)
                XCTAssertEqual(configDict["showTransitLabels"]?.value as? Bool, true)
                XCTAssertEqual(configDict["showPlaceLabels"]?.value as? Bool, false)
                XCTAssertEqual(configDict["showRoadLabels"]?.value as? Bool, true)
                XCTAssertEqual(configDict["showRoadsAndTransit"]?.value as? Bool, true)
                XCTAssertEqual(configDict["showPedestrianRoads"]?.value as? Bool, true)
                XCTAssertEqual(configDict["showAdminBoundaries"]?.value as? Bool, true)

                // Test enum configurations
                XCTAssertEqual(configDict["backgroundPointOfInterestLabels"]?.value as? String, "none")
                XCTAssertEqual(configDict["colorModePointOfInterestLabels"]?.value as? String, "default")

                // Test numeric configurations
                XCTAssertEqual(configDict["densityPointOfInterestLabels"]?.value as? Double, 1.8)
                XCTAssertEqual(configDict["roadsBrightness"]?.value as? Double, 0.7)

                // Test color configurations (verify they are strings with RGBA format)
                XCTAssertEqual(configDict["colorAdminBoundaries"]?.value as? String, "rgba(255.00, 0.00, 0.00, 1.00)")
                XCTAssertEqual(configDict["colorMotorways"]?.value as? String, "rgba(255.00, 255.00, 0.00, 1.00)")
                XCTAssertEqual(configDict["colorPlaceLabelHighlight"]?.value as? String, "rgba(255.00, 0.00, 255.00, 1.00)")
                XCTAssertEqual(configDict["colorPlaceLabels"]?.value as? String, "rgba(255.00, 127.50, 0.00, 1.00)")
                XCTAssertEqual(configDict["colorPlaceLabelSelect"]?.value as? String, "rgba(127.50, 0.00, 127.50, 1.00)")
                XCTAssertEqual(configDict["colorPointOfInterestLabels"]?.value as? String, "rgba(153.00, 102.00, 51.00, 1.00)")
                XCTAssertEqual(configDict["colorRoadLabels"]?.value as? String, "rgba(127.50, 127.50, 127.50, 1.00)")
                XCTAssertEqual(configDict["colorRoads"]?.value as? String, "rgba(170.00, 170.00, 170.00, 1.00)")
                XCTAssertEqual(configDict["colorTrunks"]?.value as? String, "rgba(85.00, 85.00, 85.00, 1.00)")

                expectation.fulfill()
            } catch {
                XCTFail("Failed to verify Standard Satellite style configuration: \(error)")
            }
        }.store(in: &cancelables)

        wait(for: [expectation], timeout: 10)
    }
}
