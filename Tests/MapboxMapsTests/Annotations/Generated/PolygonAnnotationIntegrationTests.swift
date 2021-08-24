// swiftlint:disable all
// This file is generated
import XCTest
import Turf
@testable import MapboxMaps

class PolygonAnnotationIntegrationTests: MapViewIntegrationTestCase {

    var manager: PolygonAnnotationManager?

    internal func testWaitForIdle() throws {
        let style = try XCTUnwrap(self.style)

        let successfullyLoadedStyleExpectation = XCTestExpectation(description: "Successfully loaded style to Map")
        successfullyLoadedStyleExpectation.expectedFulfillmentCount = 1
        style.uri = .streets

        didFinishLoadingStyle = { [weak self] _ in

            guard let self = self,
                  let style = try? XCTUnwrap(self.style),
                  let mapView = try? XCTUnwrap(self.mapView) else { return }

            let manager = mapView.annotations.makePolygonAnnotationManager()
            XCTAssertTrue(style.layerExists(withId: manager.layerId))
            XCTAssertTrue(style.sourceExists(withId: manager.sourceId))

            let polygonCoords = [
                CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
                CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
                CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
                CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
                CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
            ]
            var annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)))

            annotation.fillSortKey =  Double.testConstantValue()
            annotation.fillColor =  ColorRepresentable.testConstantValue()
            annotation.fillOpacity =  Double.testConstantValue()
            annotation.fillOutlineColor =  ColorRepresentable.testConstantValue()
            annotation.fillPattern =  String.testConstantValue()

            manager.annotations = [annotation]
            self.manager = manager
            successfullyLoadedStyleExpectation.fulfill()
        }

        wait(for: [successfullyLoadedStyleExpectation], timeout: 5.0)
    }

    func testAnnotationPersistence() throws {
        let style = try XCTUnwrap(self.style)
        style.uri = .streets

        mapView?.mapboxMap.onNext(.mapLoaded, handler: { [weak self] _ in
            guard let self = self,
                let style = try? XCTUnwrap(self.style),
                let mapView = try? XCTUnwrap(self.mapView) else { return }

            let manager = mapView.annotations.makePolygonAnnotationManager()
            XCTAssertTrue(style.layerExists(withId: manager.layerId))
            XCTAssertTrue(style.sourceExists(withId: manager.sourceId))

            let polygonCoords = [
                CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375),
                CLLocationCoordinate2DMake(24.51713945052515, -87.967529296875),
                CLLocationCoordinate2DMake(26.244156283890756, -87.967529296875),
                CLLocationCoordinate2DMake(26.244156283890756, -89.857177734375),
                CLLocationCoordinate2DMake(24.51713945052515, -89.857177734375)
            ]
            let annotation = PolygonAnnotation(polygon: .init(outerRing: .init(coordinates: polygonCoords)))

            manager.annotations = [annotation]
            self.manager = manager

            do {
             let isPersistent = try style._isPersistentLayer(id: manager.layerId)
             XCTAssertTrue(isPersistent, "The layer with id \(manager.layerId) should be persistent.")
            } catch {
             XCTFail("Unable to verify that the layer with id \(manager.layerId) is persistent.")
            }
        })
    }
}

// End of generated file
// swiftlint:enable all
