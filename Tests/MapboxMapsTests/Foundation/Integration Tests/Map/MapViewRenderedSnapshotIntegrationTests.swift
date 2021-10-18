import Foundation
import MetalKit
import XCTest
@testable @_spi(Experimental) import MapboxMaps

final class MapViewRenderedSnapshotIntegrationTests: MapViewIntegrationTestCase {

    func testLoadStyleAndTakeSnapshotSucceeds() {

        guard let style = style else {
            XCTFail("Should have a valid Style object")
            return
        }

        let waitForStyleExpectation = self.expectation(description: "Wait for style to load")
        let waitForSnapshotExpectation = self.expectation(description: "Wait for snapshot to be taken")

        didFinishLoadingStyle = { _ in
            waitForStyleExpectation.fulfill()
        }

        didBecomeIdle = { [weak self] _ in
            guard let mapView = self?.mapView else {
                XCTFail("Mapview must exist.")
                return
            }

            do {
                let image = try mapView.snapshot()
                XCTAssertNotNil(image)
                waitForSnapshotExpectation.fulfill()
            } catch {
                XCTFail("Snapshot failed with error: \(error)")
            }
        }

        style.uri = .dark
        wait(for: [waitForStyleExpectation, waitForSnapshotExpectation], timeout: 10)
    }

    func testSnapshotFailsDueToNoMetalView() {

        guard let style = style else {
            XCTFail("Should have a valid Style object")
            return
        }

        let waitForStyleExpectation = self.expectation(description: "Wait for style to load")
        let waitForSnapshotExpectation = self.expectation(description: "Wait for snapshot to be taken")

        didFinishLoadingStyle = { _ in
            waitForStyleExpectation.fulfill()
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
                _ = try mapView.snapshot()
            } catch {
                XCTAssertEqual(error as? MapView.SnapshotError,
                               MapView.SnapshotError.noMetalView)
                waitForSnapshotExpectation.fulfill()
            }
        }

        style.uri = .dark
        wait(for: [waitForStyleExpectation, waitForSnapshotExpectation], timeout: 10)
    }
}
