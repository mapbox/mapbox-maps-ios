import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class CustomSourcesIntegrationTests: MapViewIntegrationTestCase {

    func testCustomRasterSourceAdditionAndRemoval() {
        let successfullyAddedSourceExpectation = XCTestExpectation(description: "Successfully added CustomRasterSource to Map")
        successfullyAddedSourceExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedSourceExpectation = XCTestExpectation(description: "Successfully retrieved CustomRasterSource from Map")
        successfullyRetrievedSourceExpectation.expectedFulfillmentCount = 1

        mapView.mapboxMap.styleURI = .standard

        didFinishLoadingStyle = { mapView in
            let source = CustomRasterSource(id: "test-source", options: CustomRasterSourceOptions(fetchTileFunction: { _ in }, cancelTileFunction: { _ in }))

            // Add source
            do {
                try mapView.mapboxMap.addSource(source)
                successfullyAddedSourceExpectation.fulfill()
            } catch {
                XCTFail("Failed to add CustomRasterSource because of error: \(error)")
            }

            // Retrieve the source
            do {
                _ = try mapView.mapboxMap.source(withId: "test-source", type: CustomRasterSource.self)
                successfullyRetrievedSourceExpectation.fulfill()
            } catch {
                XCTFail("Failed to retrieve CustomRasterSource because of error: \(error)")
            }
        }
        wait(for: [successfullyAddedSourceExpectation, successfullyRetrievedSourceExpectation], timeout: 5.0)
    }

    func testCustomGeometrySourceAdditionAndRemoval() {
        let successfullyAddedSourceExpectation = XCTestExpectation(description: "Successfully added CustomGeometrySource to Map")
        successfullyAddedSourceExpectation.expectedFulfillmentCount = 1

        let successfullyRetrievedSourceExpectation = XCTestExpectation(description: "Successfully retrieved CustomGeometrySource from Map")
        successfullyRetrievedSourceExpectation.expectedFulfillmentCount = 1

        mapView.mapboxMap.styleURI = .standard

        didFinishLoadingStyle = { mapView in
            let source = CustomGeometrySource(id: "test-source", options: CustomGeometrySourceOptions(fetchTileFunction: { _ in }, cancelTileFunction: { _ in }, tileOptions: TileOptions()))

            // Add source
            do {
                try mapView.mapboxMap.addSource(source)
                successfullyAddedSourceExpectation.fulfill()
            } catch {
                XCTFail("Failed to add CustomGeometrySource because of error: \(error)")
            }

            // Retrieve the source
            do {
                _ = try mapView.mapboxMap.source(withId: "test-source", type: CustomGeometrySource.self)
                successfullyRetrievedSourceExpectation.fulfill()
            } catch {
                XCTFail("Failed to retrieve CustomGeometrySource because of error: \(error)")
            }
        }
        wait(for: [successfullyAddedSourceExpectation, successfullyRetrievedSourceExpectation], timeout: 5.0)
    }
}
