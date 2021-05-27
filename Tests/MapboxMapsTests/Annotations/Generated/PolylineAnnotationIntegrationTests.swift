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
            var annotation = PolylineAnnotation(line: .init(lineCoordinates))
            
            annotation.lineJoin =  LineJoin.testConstantValue()
            annotation.lineSortKey =  Double.testConstantValue()
            annotation.lineBlur =  Double.testConstantValue()
            annotation.lineColor =  ColorRepresentable.testConstantValue()
            annotation.lineGapWidth =  Double.testConstantValue()
            annotation.lineOffset =  Double.testConstantValue()
            annotation.lineOpacity =  Double.testConstantValue()
            annotation.linePattern =  String.testConstantValue()
            annotation.lineWidth =  Double.testConstantValue()

            self.verifyFeatureContainsProperties(annotation: annotation)
            manager.syncAnnotations([annotation])
            self.manager = manager
            successfullyLoadedStyleExpectation.fulfill()
        }

        wait(for: [successfullyLoadedStyleExpectation], timeout: 5.0)
    }

    func verifyFeatureContainsProperties(annotation: PolylineAnnotation)  {

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else { return }
        
        XCTAssertEqual(featureProperties["line-join"] as? String, annotation.lineJoin?.rawValue)
        XCTAssertEqual(featureProperties["line-sort-key"] as? Double, annotation.lineSortKey)
        XCTAssertEqual(featureProperties["line-blur"] as? Double, annotation.lineBlur)
        XCTAssertEqual(featureProperties["line-color"] as? String, annotation.lineColor?.rgbaDescription)
        XCTAssertEqual(featureProperties["line-gap-width"] as? Double, annotation.lineGapWidth)
        XCTAssertEqual(featureProperties["line-offset"] as? Double, annotation.lineOffset)
        XCTAssertEqual(featureProperties["line-opacity"] as? Double, annotation.lineOpacity)
        XCTAssertEqual(featureProperties["line-pattern"] as? String, annotation.linePattern)
        XCTAssertEqual(featureProperties["line-width"] as? Double, annotation.lineWidth)
    }

    func verifySourceContainsProperties(sourceId: String, annotation: PolylineAnnotation) {
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

        XCTAssertEqual(featureProperties["line-join"] as? String, annotation.lineJoin?.rawValue)
        XCTAssertEqual(featureProperties["line-sort-key"] as? Double, annotation.lineSortKey)
        XCTAssertEqual(featureProperties["line-blur"] as? Double, annotation.lineBlur)
        XCTAssertEqual(featureProperties["line-color"] as? String, annotation.lineColor?.rgbaDescription)
        XCTAssertEqual(featureProperties["line-gap-width"] as? Double, annotation.lineGapWidth)
        XCTAssertEqual(featureProperties["line-offset"] as? Double, annotation.lineOffset)
        XCTAssertEqual(featureProperties["line-opacity"] as? Double, annotation.lineOpacity)
        XCTAssertEqual(featureProperties["line-pattern"] as? String, annotation.linePattern)
        XCTAssertEqual(featureProperties["line-width"] as? Double, annotation.lineWidth)
    }
}

// End of generated file
// swiftlint:enable all