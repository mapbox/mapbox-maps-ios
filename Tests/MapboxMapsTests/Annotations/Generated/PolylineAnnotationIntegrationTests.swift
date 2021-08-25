// swiftlint:disable all
// This file is generated
import XCTest
import Turf
@testable import MapboxMaps

class PolylineAnnotationIntegrationTests: MapViewIntegrationTestCase {

    var manager: PolylineAnnotationManager?

    internal func testWaitForIdle() throws {
        let style = try XCTUnwrap(self.style)

        let successfullyLoadedStyleExpectation = XCTestExpectation(description: "Successfully loaded style to Map")
        successfullyLoadedStyleExpectation.expectedFulfillmentCount = 1
        style.uri = .streets

        didFinishLoadingStyle = { [weak self] _ in

            guard let self = self,
                  let style = try? XCTUnwrap(self.style),
                  let mapView = try? XCTUnwrap(self.mapView) else { return }

            let manager = mapView.annotations.makePolylineAnnotationManager()
            XCTAssertTrue(style.layerExists(withId: manager.layerId))
            XCTAssertTrue(style.sourceExists(withId: manager.sourceId))

            let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
            var annotation = PolylineAnnotation(lineString: .init(lineCoordinates))

            annotation.lineJoin =  LineJoin.testConstantValue()
            annotation.lineSortKey =  Double.testConstantValue()
            annotation.lineBlur =  Double.testConstantValue()
            annotation.lineColor =  ColorRepresentable.testConstantValue()
            annotation.lineGapWidth =  Double.testConstantValue()
            annotation.lineOffset =  Double.testConstantValue()
            annotation.lineOpacity =  Double.testConstantValue()
            annotation.linePattern =  String.testConstantValue()
            annotation.lineWidth =  Double.testConstantValue()

            manager.syncAnnotations([annotation])
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

            let manager = mapView.annotations.makePolylineAnnotationManager()
            XCTAssertTrue(style.layerExists(withId: manager.layerId))
            XCTAssertTrue(style.sourceExists(withId: manager.sourceId))

            let lineCoordinates = [ CLLocationCoordinate2DMake(0, 0), CLLocationCoordinate2DMake(10, 10) ]
            let annotation = PolylineAnnotation(lineString: .init(lineCoordinates))

            manager.syncAnnotations([annotation])
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
