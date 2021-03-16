import XCTest
@testable import MapboxMaps

internal class AnnotationManagerIntegrationTestCase: MapViewIntegrationTestCase {

    // MARK: - Test adding point annotation

    /**
     The purpose of this test is to ensure that the appropriate source and style
     layers exist on the style object after an annotation has been added.
     It does this by adding an annotation, and then querying the map object
     to ensure the correct layers exist.
     */
    internal func testAddAnnotation() {
        style?.styleURL = .streets

        let styleLoadedExpectation = XCTestExpectation(description: "Wait for map to load style")
        let sourceAddedExpectation = XCTestExpectation(description: "Annotation source layer added")
        let styleLayerAddedExpectation = XCTestExpectation(description: "Annotation style layer added")

        didFinishLoadingStyle = { mapView in

            // Given
            let annotation = PointAnnotation(coordinate: mapView.centerCoordinate)
            let annotationManager = AnnotationManager(for: mapView,
                                                      with: self,
                                                      options: AnnotationOptions())
            annotationManager.addAnnotation(annotation)

            // When
            let sourceResult = self.style?.getSource(identifier: annotationManager.defaultSourceId, type: GeoJSONSource.self)
            let styleLayer = try! self.mapView?.__map.getStyleLayerProperties(forLayerId: annotationManager.defaultSymbolLayerId)
            // ❓ Core SDK call to get style layer works, but not Style API line below
            // let styleLayer = self.style?.getLayer(with: annotationManager.defaultSymbolLayerId, type: SymbolLayer.self)

            // Then
            styleLoadedExpectation.fulfill()

            if case .success = sourceResult {
                sourceAddedExpectation.fulfill()
            }

            if styleLayer?.value != nil {
                styleLayerAddedExpectation.fulfill()
            }
        }

        let expectations = [
            styleLoadedExpectation,
            sourceAddedExpectation,
            styleLayerAddedExpectation
        ]

        wait(for: expectations, timeout: 5.0)
    }

    // MARK: - Test adding userInfo to annotation still renders annotation

    /**
     The purpose of this test is to ensure that adding userInfo to the annotation
     will still render that annotation without fail, while also being able to retrieve that
     that information at another instance.
     */
    internal func testAddUserInfoToAnnotation() {
        style?.styleURL = .streets

        let styleLoadedExpectation = XCTestExpectation(description: "Wait for map to load style")
        let sourceAddedExpectation = XCTestExpectation(description: "Annotation source layer added")
        let styleLayerAddedExpectation = XCTestExpectation(description: "Annotation style layer added")
        let retrieveUserInfoExpectation = XCTestExpectation(description: "Get the userInfo value that was set for the annotation")

        didFinishLoadingStyle = { mapView in

            // Given
            var annotation = PointAnnotation(coordinate: mapView.centerCoordinate)
            let annotationManager = AnnotationManager(for: mapView,
                                                      with: self,
                                                      options: AnnotationOptions())
            annotation.userInfo = ["TestKey": true]
            annotationManager.addAnnotation(annotation)

            // When
            let sourceResult = self.style?.getSource(identifier: annotationManager.defaultSourceId, type: GeoJSONSource.self)
            let styleLayer = try! self.mapView?.__map.getStyleLayerProperties(forLayerId: annotationManager.defaultSymbolLayerId)
            // ❓ Core SDK call to get style layer works, but not Style API line below
            // let styleLayer = self.style?.getLayer(with: annotationManager.defaultSymbolLayerId, type: SymbolLayer.self)

            // Then
            styleLoadedExpectation.fulfill()

            if let value = annotation.userInfo?["TestKey"] as? Bool,
               value == true {
                retrieveUserInfoExpectation.fulfill()
            }

            if case .success = sourceResult {
                sourceAddedExpectation.fulfill()
            }

            if styleLayer?.value != nil {
                styleLayerAddedExpectation.fulfill()
            }
        }

        let expectations = [
            styleLoadedExpectation,
            sourceAddedExpectation,
            styleLayerAddedExpectation,
            retrieveUserInfoExpectation
        ]

        wait(for: expectations, timeout: 5.0)
    }
}

// MARK: - Set up AnnotationManager

/**
 Implement AnnotationStyleDelegate methods, so we can work with just
 the AnnotationManager class without having to create an entire MapViewController.
 */

// swiftlint:disable function_parameter_count identifier_name
extension AnnotationManagerIntegrationTestCase: AnnotationStyleDelegate {
    func setStyleImage(image: UIImage, with identifier: String, sdf: Bool, stretchX: [ImageStretches], stretchY: [ImageStretches], scale: CGFloat, imageContent: ImageContent?) -> Result<Bool, ImageError> {
        guard let style = style else {
            XCTFail("No style available")
            return .failure(.addStyleImageFailed(nil))
        }

        return style.setStyleImage(image: image, with: identifier, scale: scale)
    }

    func getStyleImage(with identifier: String) -> Image? {
        guard let style = style else {
            XCTFail("No style available")
            return nil
        }

        return style.getStyleImage(with: identifier)
    }

    func addSource<T>(source: T, identifier: String) -> Result<Bool, SourceError> where T: Source {
        guard let style = style else {
            XCTFail("No style available")
            return .failure(.addSourceFailed(nil))
        }

        return style.addSource(source: source, identifier: identifier)
    }

    func updateSourceProperty(id: String, property: String, value: [String: Any]) -> Result<Bool, SourceError> {
        guard let style = style else {
            XCTFail("No style available")
            return .failure(.addSourceFailed(nil))
        }

        return style.updateSourceProperty(id: id, property: property, value: value)
    }

    func addLayer<T>(layer: T, layerPosition: LayerPosition?) -> Result<Bool, LayerError> where T: Layer {
        guard let style = style else {
            XCTFail("No style available")
            return .failure(.addStyleLayerFailed(nil))
        }

        return style.addLayer(layer: layer, layerPosition: layerPosition)
    }
}
