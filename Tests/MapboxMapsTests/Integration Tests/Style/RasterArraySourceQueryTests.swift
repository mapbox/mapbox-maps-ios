import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class RasterArraySourceQueryTests: MapViewIntegrationTestCase {

    func testAdditionAndRemovalOfSource() throws {
        let successfullyRetrievedSourceExpectation = XCTestExpectation(description: "Successfully retrieved RasterArraySource from Map")
        successfullyRetrievedSourceExpectation.expectedFulfillmentCount = 1

        mapView.mapboxMap.load(mapStyle: .init(json: """
        {
          "version": 8,
          "name": "Temperature",
          "sources": {
            "mapbox": {
                "type": "raster-array",
                "tiles": ["mapbox://tiles/example/{z}/{x}/{y}.mrt"],
                "scheme": "xyz",
                "minzoom": 1,
                "maxzoom": 4,
                "attribution": "mapbox",
                "volatile": true,
                "raster_layers": [
                    {
                        "fields": {
                            "bands": [
                                "1659898800", "1659902400", "1659906000", "1659909600", "1659913200", "1659916800"
                            ],
                            "buffer": 1,
                            "units": "degrees"
                        },
                        "id": "temperature",
                        "maxzoom": 3,
                        "minzoom": 0
                    },
                    {
                        "fields": {
                            "bands": [
                                "1659898800", "1659902400", "1659906000", "1659909600", "1659913200", "1659916800"
                            ],
                            "buffer": 1,
                            "units": "percent"
                        },
                        "id": "humidity",
                        "maxzoom": 3,
                        "minzoom": 0
                    }
                ]
            }
          },
          "layers": [
            {
            "id": "temperature",
            "type": "raster",
            "source": "mapbox",
            "source-layer": "temperature",
            "paint": {
                "raster-color": [
                  "interpolate",
                  [
                    "linear"
                  ],
                  [
                    "raster-value"
                  ],
                  -5,
                  "rgba(94, 79, 162, 0.8)",
                  0,
                  "rgba(75, 160, 177, 0.8)",
                  5,
                  "rgba(160, 217, 163, 0.8)",
                  10,
                  "rgba(235, 247, 166, 0.8)",
                  15,
                  "rgba(254, 232, 154, 0.8)",
                  20,
                  "rgba(251, 163, 94, 0.8)",
                  25,
                  "rgba(225, 82, 74, 0.8)",
                  30,
                  "rgba(158, 1, 66, 0.8)"
                ],
                "raster-color-range": [-5, 30]
            }
          }]
        }
"""))

        didFinishLoadingStyle = { mapView in
            // TODO: convert to use high-level API(RasterArraySource.rasterLayers) after GL Native bug is resolved
            // in v11.1.0-rc.1 - https://github.com/mapbox/mapbox-gl-native-internal/pull/5534
            // swiftlint:disable:next force_cast
            let value = mapView.mapboxMap.sourceProperty(for: "mapbox", property: "rasterLayers").value as! [String: [String]]
            let expectedValue = [
                "humidity": [1659898800, 1659902400, 1659906000, 1659909600, 1659913200, 1659916800],
                "temperature": [1659898800, 1659902400, 1659906000, 1659909600, 1659913200, 1659916800]
            ]
            XCTAssertEqual(value.mapValues { $0.map { Int($0) } }, expectedValue)
            successfullyRetrievedSourceExpectation.fulfill()
        }

        wait(for: [successfullyRetrievedSourceExpectation], timeout: 5.0)
    }
}
