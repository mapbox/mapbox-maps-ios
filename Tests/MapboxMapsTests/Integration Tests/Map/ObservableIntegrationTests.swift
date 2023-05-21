import XCTest
@testable import MapboxMaps

class ObservableIntegrationTests: MapViewIntegrationTestCase {

    func testResourceRequestEvent() throws {
        guard
            let mapView = mapView,
            let style = style else {
            XCTFail("There should be valid MapView and Style objects created by setUp.")
            return
        }

        let eventExpectation = XCTestExpectation(description: "Event should have been received")
        eventExpectation.assertForOverFulfill = false

        mapView.mapboxMap.onResourceRequest.observe { req in
            let validDataSources = [RequestDataSourceType.resourceLoader, .network, .database, .asset, .fileSystem]
            XCTAssert(validDataSources.contains(req.source))
            eventExpectation.fulfill()
        }.store(in: &cancelables)

        style.uri = .streets

        let styleLoadExpectation = XCTestExpectation(description: "Style should have been loaded")

        didFinishLoadingStyle = { _ in
            styleLoadExpectation.fulfill()
        }

        wait(for: [styleLoadExpectation, eventExpectation], timeout: 5.0)
    }
}
