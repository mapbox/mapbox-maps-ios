// swiftlint:disable all
// This file is generated
import XCTest
import Turf
@testable import MapboxMaps

class PointAnnotationIntegrationTests: MapViewIntegrationTestCase {

    var manager: PointAnnotationManager?

    internal func testWaitForIdle() throws {
        let style = try XCTUnwrap(self.style)

        let successfullyLoadedStyleExpectation = XCTestExpectation(description: "Successfully loaded style to Map")
        successfullyLoadedStyleExpectation.expectedFulfillmentCount = 1
        style.uri = .streets

        didFinishLoadingStyle = { [weak self] _ in

            guard let self = self, 
                  let style = try? XCTUnwrap(self.style),
                  let mapView = try? XCTUnwrap(self.mapView) else { return }

            let manager = mapView.annotations.makePointAnnotationManager()
            XCTAssertTrue(style.layerExists(withId: manager.layerId))
            XCTAssertTrue(style.sourceExists(withId: manager.sourceId))

            var annotation = PointAnnotation(point: .init(.init(latitude: 0, longitude: 0)))
            
            annotation.iconAnchor =  IconAnchor.testConstantValue()
            annotation.iconImage =  String.testConstantValue()
            annotation.iconOffset =  [Double].testConstantValue()
            annotation.iconRotate =  Double.testConstantValue()
            annotation.iconSize =  Double.testConstantValue()
            annotation.symbolSortKey =  Double.testConstantValue()
            annotation.textAnchor =  TextAnchor.testConstantValue()
            annotation.textField =  String.testConstantValue()
            annotation.textJustify =  TextJustify.testConstantValue()
            annotation.textLetterSpacing =  Double.testConstantValue()
            annotation.textMaxWidth =  Double.testConstantValue()
            annotation.textOffset =  [Double].testConstantValue()
            annotation.textRadialOffset =  Double.testConstantValue()
            annotation.textRotate =  Double.testConstantValue()
            annotation.textSize =  Double.testConstantValue()
            annotation.textTransform =  TextTransform.testConstantValue()
            annotation.iconColor =  ColorRepresentable.testConstantValue()
            annotation.iconHaloBlur =  Double.testConstantValue()
            annotation.iconHaloColor =  ColorRepresentable.testConstantValue()
            annotation.iconHaloWidth =  Double.testConstantValue()
            annotation.iconOpacity =  Double.testConstantValue()
            annotation.textColor =  ColorRepresentable.testConstantValue()
            annotation.textHaloBlur =  Double.testConstantValue()
            annotation.textHaloColor =  ColorRepresentable.testConstantValue()
            annotation.textHaloWidth =  Double.testConstantValue()
            annotation.textOpacity =  Double.testConstantValue()

            self.verifyFeatureContainsProperties(annotation: annotation)
            manager.annotations = [annotation]
            self.manager = manager
            successfullyLoadedStyleExpectation.fulfill()
        }

        wait(for: [successfullyLoadedStyleExpectation], timeout: 5.0)
    }

    func verifyFeatureContainsProperties(annotation: PointAnnotation)  {

        guard let featureProperties = try? XCTUnwrap(annotation.feature.properties) else { return }
        
        XCTAssertEqual(featureProperties["icon-anchor"] as? String, annotation.iconAnchor?.rawValue)
        XCTAssertEqual(featureProperties["icon-image"] as? String, annotation.iconImage)
        XCTAssertEqual(featureProperties["icon-offset"] as? [Double], annotation.iconOffset)
        XCTAssertEqual(featureProperties["icon-rotate"] as? Double, annotation.iconRotate)
        XCTAssertEqual(featureProperties["icon-size"] as? Double, annotation.iconSize)
        XCTAssertEqual(featureProperties["symbol-sort-key"] as? Double, annotation.symbolSortKey)
        XCTAssertEqual(featureProperties["text-anchor"] as? String, annotation.textAnchor?.rawValue)
        XCTAssertEqual(featureProperties["text-field"] as? String, annotation.textField)
        XCTAssertEqual(featureProperties["text-justify"] as? String, annotation.textJustify?.rawValue)
        XCTAssertEqual(featureProperties["text-letter-spacing"] as? Double, annotation.textLetterSpacing)
        XCTAssertEqual(featureProperties["text-max-width"] as? Double, annotation.textMaxWidth)
        XCTAssertEqual(featureProperties["text-offset"] as? [Double], annotation.textOffset)
        XCTAssertEqual(featureProperties["text-radial-offset"] as? Double, annotation.textRadialOffset)
        XCTAssertEqual(featureProperties["text-rotate"] as? Double, annotation.textRotate)
        XCTAssertEqual(featureProperties["text-size"] as? Double, annotation.textSize)
        XCTAssertEqual(featureProperties["text-transform"] as? String, annotation.textTransform?.rawValue)
        XCTAssertEqual(featureProperties["icon-color"] as? String, annotation.iconColor?.rgbaDescription)
        XCTAssertEqual(featureProperties["icon-halo-blur"] as? Double, annotation.iconHaloBlur)
        XCTAssertEqual(featureProperties["icon-halo-color"] as? String, annotation.iconHaloColor?.rgbaDescription)
        XCTAssertEqual(featureProperties["icon-halo-width"] as? Double, annotation.iconHaloWidth)
        XCTAssertEqual(featureProperties["icon-opacity"] as? Double, annotation.iconOpacity)
        XCTAssertEqual(featureProperties["text-color"] as? String, annotation.textColor?.rgbaDescription)
        XCTAssertEqual(featureProperties["text-halo-blur"] as? Double, annotation.textHaloBlur)
        XCTAssertEqual(featureProperties["text-halo-color"] as? String, annotation.textHaloColor?.rgbaDescription)
        XCTAssertEqual(featureProperties["text-halo-width"] as? Double, annotation.textHaloWidth)
        XCTAssertEqual(featureProperties["text-opacity"] as? Double, annotation.textOpacity)
    }

    func verifySourceContainsProperties(sourceId: String, annotation: PointAnnotation) {
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

        XCTAssertEqual(featureProperties["icon-anchor"] as? String, annotation.iconAnchor?.rawValue)
        XCTAssertEqual(featureProperties["icon-image"] as? String, annotation.iconImage)
        XCTAssertEqual(featureProperties["icon-offset"] as? [Double], annotation.iconOffset)
        XCTAssertEqual(featureProperties["icon-rotate"] as? Double, annotation.iconRotate)
        XCTAssertEqual(featureProperties["icon-size"] as? Double, annotation.iconSize)
        XCTAssertEqual(featureProperties["symbol-sort-key"] as? Double, annotation.symbolSortKey)
        XCTAssertEqual(featureProperties["text-anchor"] as? String, annotation.textAnchor?.rawValue)
        XCTAssertEqual(featureProperties["text-field"] as? String, annotation.textField)
        XCTAssertEqual(featureProperties["text-justify"] as? String, annotation.textJustify?.rawValue)
        XCTAssertEqual(featureProperties["text-letter-spacing"] as? Double, annotation.textLetterSpacing)
        XCTAssertEqual(featureProperties["text-max-width"] as? Double, annotation.textMaxWidth)
        XCTAssertEqual(featureProperties["text-offset"] as? [Double], annotation.textOffset)
        XCTAssertEqual(featureProperties["text-radial-offset"] as? Double, annotation.textRadialOffset)
        XCTAssertEqual(featureProperties["text-rotate"] as? Double, annotation.textRotate)
        XCTAssertEqual(featureProperties["text-size"] as? Double, annotation.textSize)
        XCTAssertEqual(featureProperties["text-transform"] as? String, annotation.textTransform?.rawValue)
        XCTAssertEqual(featureProperties["icon-color"] as? String, annotation.iconColor?.rgbaDescription)
        XCTAssertEqual(featureProperties["icon-halo-blur"] as? Double, annotation.iconHaloBlur)
        XCTAssertEqual(featureProperties["icon-halo-color"] as? String, annotation.iconHaloColor?.rgbaDescription)
        XCTAssertEqual(featureProperties["icon-halo-width"] as? Double, annotation.iconHaloWidth)
        XCTAssertEqual(featureProperties["icon-opacity"] as? Double, annotation.iconOpacity)
        XCTAssertEqual(featureProperties["text-color"] as? String, annotation.textColor?.rgbaDescription)
        XCTAssertEqual(featureProperties["text-halo-blur"] as? Double, annotation.textHaloBlur)
        XCTAssertEqual(featureProperties["text-halo-color"] as? String, annotation.textHaloColor?.rgbaDescription)
        XCTAssertEqual(featureProperties["text-halo-width"] as? Double, annotation.textHaloWidth)
        XCTAssertEqual(featureProperties["text-opacity"] as? Double, annotation.textOpacity)
    }
}

// End of generated file
// swiftlint:enable all