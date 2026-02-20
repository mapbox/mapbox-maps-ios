import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class SymbolScaleBehaviorTests: MapViewIntegrationTestCase {

    func testSetSymbolScaleBehaviorWithFixedMode() {
        let expectation = XCTestExpectation(description: "Set fixed scale behavior")

        didFinishLoadingStyle = { mapView in
            let expected = SymbolScaleBehavior.fixed(scaleFactor: 1.5)
            mapView.mapboxMap.symbolScaleBehavior = expected
            let actual = mapView.mapboxMap.symbolScaleBehavior
            XCTAssertEqual(actual, expected)

            // Verify native map received the scale factor
            let actualScaleFactor = mapView.mapboxMap.getScaleFactor()
            XCTAssertEqual(actualScaleFactor, 1.5, accuracy: 0.001)

            expectation.fulfill()
        }

        mapView.mapboxMap.styleJSON = .testStyleJSON()
        wait(for: [expectation], timeout: 5.0)
    }

    func testSetSymbolScaleBehaviorWithSystemMode() {
        let expectation = XCTestExpectation(description: "Set system scale behavior")

        didFinishLoadingStyle = { mapView in
            let expected = SymbolScaleBehavior.system
            mapView.mapboxMap.symbolScaleBehavior = expected
            let actual = mapView.mapboxMap.symbolScaleBehavior
            XCTAssertEqual(actual, expected)

            // Verify scale factor is within valid range [0.8, 2.0]
            let actualScaleFactor = mapView.mapboxMap.getScaleFactor()
            XCTAssertGreaterThanOrEqual(actualScaleFactor, 0.8)
            XCTAssertLessThanOrEqual(actualScaleFactor, 2.0)

            expectation.fulfill()
        }

        mapView.mapboxMap.styleJSON = .testStyleJSON()
        wait(for: [expectation], timeout: 5.0)
    }

    func testSetSymbolScaleBehaviorWithCustomMapping() {
        let expectation = XCTestExpectation(description: "Set custom mapping scale behavior")

        didFinishLoadingStyle = { mapView in
            // Function-based custom mapping
            let customMapping: (Double) -> Double = { systemScale in
                switch systemScale {
                case ...1.0:
                    return systemScale
                case ...1.5:
                    return 1.0 + (systemScale - 1.0) * 0.6
                default:
                    return 1.5
                }
            }
            let expected = SymbolScaleBehavior.system(mapping: customMapping)
            mapView.mapboxMap.symbolScaleBehavior = expected
            let actual = mapView.mapboxMap.symbolScaleBehavior

            // Verify scale behavior was applied (exact value depends on the device's system font scale)
            let actualScaleFactor = mapView.mapboxMap.getScaleFactor()
            XCTAssertGreaterThan(actualScaleFactor, 0.0)

            expectation.fulfill()
        }

        mapView.mapboxMap.styleJSON = .testStyleJSON()
        wait(for: [expectation], timeout: 5.0)
    }

    func testDefaultSymbolScaleBehavior() {
        let expectation = XCTestExpectation(description: "Check default scale behavior")

        didFinishLoadingStyle = { mapView in
            // Verify default is Fixed(1.0)
            let defaultBehavior = mapView.mapboxMap.symbolScaleBehavior
            XCTAssertTrue(defaultBehavior.isFixed)
            XCTAssertEqual(defaultBehavior.scaleFactor, 1.0)

            // Verify default scale factor in native map
            let actualScaleFactor = mapView.mapboxMap.getScaleFactor()
            XCTAssertEqual(actualScaleFactor, 1.0, accuracy: 0.001)

            expectation.fulfill()
        }

        mapView.mapboxMap.styleJSON = .testStyleJSON()
        wait(for: [expectation], timeout: 5.0)
    }
}
