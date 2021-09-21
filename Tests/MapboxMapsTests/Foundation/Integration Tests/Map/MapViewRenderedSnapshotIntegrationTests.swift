import Foundation
import XCTest
@testable @_spi(Experimental) import MapboxMaps

final class MapViewRenderedSnapshotIntegrationTests: MapViewIntegrationTestCase {

    func testLoadStyleAndTakeSnapshotSucceeds() {

        guard let style = style else {
            XCTFail("Should have a valid Style object")
            return
        }

        let expectation1 = self.expectation(description: "Wait for style to load")
        expectation1.expectedFulfillmentCount = 1

        let expectation2 = self.expectation(description: "Wait for snapshot to be taken")
        expectation2.expectedFulfillmentCount = 1

        didFinishLoadingStyle = { _ in
            expectation1.fulfill()
        }

        didBecomeIdle = { [weak self] _ in
            guard let mapView = self?.mapView else {
                XCTFail("Mapview must exist.")
                return
            }

            do {
                let image = try mapView.snapshot().get()
                XCTAssertNotNil(image)
                expectation2.fulfill()
            } catch {
                XCTFail("Snapshot failed with error: \(error)")
            }
        }

        style.uri = .dark
        wait(for: [expectation1, expectation2], timeout: 10)
    }

    func testSnapshotFailsDueToNoMetalView() {

        guard let style = style else {
            XCTFail("Should have a valid Style object")
            return
        }

        let expectation1 = self.expectation(description: "Wait for style to load")
        expectation1.expectedFulfillmentCount = 1

        let expectation2 = self.expectation(description: "Wait for snapshot to fail")
        expectation2.expectedFulfillmentCount = 1

        didFinishLoadingStyle = { _ in
            expectation1.fulfill()
        }

        didBecomeIdle = { [weak self] _ in
            guard let mapView = self?.mapView else {
                XCTFail("Mapview must exist.")
                return
            }

            // Remove the metal view before attempting snapshot
            mapView.subviews.forEach {
                if $0 is MTKView {
                    $0.removeFromSuperview()
                }
            }

            do {
                _ = try mapView.snapshot().get()
            } catch {
                XCTAssertEqual(error as? MapView.RenderedSnapshotError,
                               MapView.RenderedSnapshotError.noMetalView)
                expectation2.fulfill()
            }
        }

        style.uri = .dark
        wait(for: [expectation1, expectation2], timeout: 10)
    }
}
