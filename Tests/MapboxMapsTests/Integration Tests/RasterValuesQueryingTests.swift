@_spi(Experimental) @testable import MapboxMaps
import XCTest

final class RasterValuesQueryingTests: MapViewIntegrationTestCase {

    func testQueryRenderedRasterValues() {
        // The purpose of this test is to ensure raster values are correctly queried from
        // raster-array sources. It uses a fixed camera position (36°N, 136°E, zoom 4),
        // a specific raster-array-band value, and expects hardcoded precipitation
        // values to ensure consistent and reproducible test results.

        let queryExpectation1 = XCTestExpectation(description: "Query with specific layer filter")
        let queryExpectation2 = XCTestExpectation(description: "Query with empty layer filter")

        mapView.mapboxMap.setCamera(
            to: CameraOptions(center: CLLocationCoordinate2D(latitude: 36, longitude: 136), zoom: 4))
        mapView.mapboxMap.load(mapStyle: MapStyle(json: """
        {
            "version": 8,
            "sources": {
                "precipitations": {
                    "type": "raster-array",
                    "url": "mapbox://mapboxsatellite.msm-precip-demo",
                    "tilesize": 512
                }
            },
            "layers": [
                {
                    "id": "precipitations",
                    "source": "precipitations",
                    "source-layer": "Total Precip",
                    "type": "raster",
                    "paint": {
                        "raster-color": [
                            "interpolate",
                            ["linear"],
                            ["raster-value"],
                            -5, "rgba(94, 79, 162, 0.8)",
                            0, "rgba(75, 160, 177, 0.8)",
                            5, "rgba(160, 217, 163, 0.8)",
                            10, "rgba(235, 247, 166, 0.8)",
                            15, "rgba(254, 232, 154, 0.8)",
                            20, "rgba(251, 163, 94, 0.8)",
                            25, "rgba(225, 82, 74, 0.8)",
                            30, "rgba(158, 1, 66, 0.8)"
                        ],
                        "raster-color-range": [-5, 30],
                        "raster-array-band": "1708308000",
                        "raster-opacity": 0.75
                    }
                }
            ]
        }
        """))

        didLoadMap = { mapView in

            XCTAssertTrue(mapView.mapboxMap.layerExists(withId: "precipitations"))
            XCTAssertTrue(mapView.mapboxMap.sourceExists(withId: "precipitations"))

            // Test 1: Filter for specific layer "precipitations"
            let options1 = RenderedRasterQueryOptions(layers: ["precipitations"])
            mapView.mapboxMap.queryRenderedRasterValues(
                for: mapView.center,
                options: options1
            ) { result in
                switch result {
                case .success(let queried):
                    XCTAssertNoThrow {
                        let values = try XCTUnwrap(queried.layers["precipitations"])
                        XCTAssertEqual(values.count, 1)
                        XCTAssertEqual(values[0].doubleValue, 1.401490136981, accuracy: 0.001)
                    }
                    queryExpectation1.fulfill()
                case .failure(let error):
                    XCTFail("Precipitation raster query should succeed: \(error)")
                }
            }

            // Test 2: Empty filter array (treat as no filter)
            let options2 = RenderedRasterQueryOptions(layers: [])
            mapView.mapboxMap.queryRenderedRasterValues(
                for: mapView.center,
                options: options2
            ) { result in
                switch result {
                case .success(let queried):
                    XCTAssertNoThrow {
                        let values = try XCTUnwrap(queried.layers["precipitations"])
                        XCTAssertEqual(values.count, 1)
                        XCTAssertEqual(values[0].doubleValue, 1.401490136981, accuracy: 0.001)
                    }
                    queryExpectation2.fulfill()
                case .failure(let error):
                    XCTFail("Precipitation raster query should succeed: \(error)")
                }
            }
        }

        wait(for: [queryExpectation1, queryExpectation2], timeout: 10.0)
    }
}
