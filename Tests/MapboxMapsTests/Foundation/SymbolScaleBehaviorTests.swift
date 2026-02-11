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
            // Custom mappings with functions can't be easily compared for equality,
            // but we can verify it was set and is in System mode
            XCTAssertTrue(actual.isSystem)
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
            expectation.fulfill()
        }

        mapView.mapboxMap.styleJSON = .testStyleJSON()
        wait(for: [expectation], timeout: 5.0)
    }
}
