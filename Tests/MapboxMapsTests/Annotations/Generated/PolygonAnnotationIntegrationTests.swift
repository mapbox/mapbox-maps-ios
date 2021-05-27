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

            self.verifyFeatureContainsProperties(annotation: annotation)
            manager.syncAnnotations([annotation])
            self.manager = manager
            successfullyLoadedStyleExpectation.fulfill()
        }

        wait(for: [successfullyLoadedStyleExpectation], timeout: 5.0)
    }

    func verifyFeatureContainsProperties(annotation: PolygonAnnotation)  {

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else { return }
        
        XCTAssertEqual(featureProperties["fill-sort-key"] as? Double, annotation.fillSortKey)
        XCTAssertEqual(featureProperties["fill-color"] as? String, annotation.fillColor?.rgbaDescription)
        XCTAssertEqual(featureProperties["fill-opacity"] as? Double, annotation.fillOpacity)
        XCTAssertEqual(featureProperties["fill-outline-color"] as? String, annotation.fillOutlineColor?.rgbaDescription)
        XCTAssertEqual(featureProperties["fill-pattern"] as? String, annotation.fillPattern)
    }

    func verifySourceContainsProperties(sourceId: String, annotation: PolygonAnnotation) {
        guard let style = try? XCTUnwrap(self.style) else { return }

        var source: GeoJSONSource?
        do { 
            source = try style.source(withId: sourceId) as GeoJSONSource
        } catch {
            XCTFail("Could not retrieve source due to error: \(error)")
            return
        }
        guard case let .featureCollection(featureCollection) = source!.data,
              let feature = featureCollection.features.first,
              let featureProperties = feature.properties else {
            XCTFail("Could not find feature collection in source data")
            return
        }

        XCTAssertEqual(featureProperties["fill-sort-key"] as? Double, annotation.fillSortKey)
        XCTAssertEqual(featureProperties["fill-color"] as? String, annotation.fillColor?.rgbaDescription)
        XCTAssertEqual(featureProperties["fill-opacity"] as? Double, annotation.fillOpacity)
        XCTAssertEqual(featureProperties["fill-outline-color"] as? String, annotation.fillOutlineColor?.rgbaDescription)
        XCTAssertEqual(featureProperties["fill-pattern"] as? String, annotation.fillPattern)
    }
}

// End of generated file
// swiftlint:enable all