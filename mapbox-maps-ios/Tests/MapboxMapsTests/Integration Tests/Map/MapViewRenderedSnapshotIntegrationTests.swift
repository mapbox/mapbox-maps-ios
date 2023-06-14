import Foundation
import XCTest
@_spi(Experimental) import MapboxMaps

final class MapViewRenderedSnapshotIntegrationTests: MapViewIntegrationTestCase {

    func testLoadStyleAndTakeSnapshotSucceeds() throws {
        guard !UIApplication.shared.windows.isEmpty else {
            throw XCTSkip("Requires a host application")
        }

        mapView.mapboxMap.styleURI = .dark

        let snapshotExpectation = expectation(description: "Take snapshot")

        didBecomeIdle = { mapView in
            defer { snapshotExpectation.fulfill() }
            do {
                _ = try mapView.snapshot()
            } catch {
                XCTFail("Snapshot failed with error: \(error)")
            }
        }

        wait(for: [snapshotExpectation], timeout: 10)
    }
}
