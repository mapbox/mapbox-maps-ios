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
}
