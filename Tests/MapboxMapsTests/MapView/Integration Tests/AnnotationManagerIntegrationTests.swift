import XCTest
@testable import MapboxMaps

internal class AnnotationManagerIntegrationTestCase: MapViewIntegrationTestCase {

    // MARK: - Integration tests

    /**
     The purpose of this test is to ensure that the appropriate source and style
     layers exist on the style object after an annotation has been added.
     It does this by adding an annotation, and then querying the map object
     to ensure the correct layers exist.
     */
    internal func testAddAnnotation() {
        style?.uri = .streets

        let styleLoadedExpectation = XCTestExpectation(description: "Wait for map to load style")
        let sourceAddedExpectation = XCTestExpectation(description: "Annotation source layer added")
        let styleLayerAddedExpectation = XCTestExpectation(description: "Annotation style layer added")

        didFinishLoadingStyle = { mapView in

            // Given
            let annotation = PointAnnotation(coordinate: mapView.cameraState.center)
            let annotationManager = AnnotationManager(for: mapView,
                                                      with: self,
                                                      options: AnnotationOptions())
            annotationManager.addAnnotation(annotation)

            // When
            let sourceResult = self.style?.getSource(identifier: annotationManager.defaultSourceId, type: GeoJSONSource.self)
            let styleLayer = self.mapView?.mapboxMap.__map.getStyleLayerProperties(forLayerId: annotationManager.defaultSymbolLayerId)
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

    internal func testAddAnnotationAtSpecificLayerPosition() {
        style?.uri = .streets

        let styleLoadedExpectation = XCTestExpectation(description: "Wait for map to load style")

        didFinishLoadingStyle = { mapView in

            // Given
            let annotation = PointAnnotation(coordinate: mapView.cameraState.center)
            let requiredIndex = 3
            let position = LayerPosition(above: nil, below: nil, at: requiredIndex)
            let annotationManager = AnnotationManager(for: mapView,
                                                      with: self,
                                                      options: AnnotationOptions(layerPosition: position))
            annotationManager.addAnnotation(annotation)

            guard let layerId = annotationManager.layerId(for: PointAnnotation.self) else {
                XCTFail("Layer should exist")
                return
            }

            // Get layer position
            let layers = mapView.style.styleManager.getStyleLayers()
            let layerIds = layers.map { $0.id }
            let layerIndex = layerIds.firstIndex(of: layerId)
            XCTAssertNotNil(layerIndex)
            XCTAssertEqual(layerIndex, requiredIndex)

            styleLoadedExpectation.fulfill()
        }

        wait(for: [styleLoadedExpectation], timeout: 5.0)
    }

    /**
     The purpose of this test is to ensure that adding userInfo to the annotation
     will still render that annotation without fail, while also being able to retrieve that
     that information at another instance.
     */
    internal func testAddUserInfoToAnnotation() {
        style?.uri = .streets

        let styleLoadedExpectation = XCTestExpectation(description: "Wait for map to load style")
        let sourceAddedExpectation = XCTestExpectation(description: "Annotation source layer added")
        let styleLayerAddedExpectation = XCTestExpectation(description: "Annotation style layer added")
        let retrieveUserInfoExpectation = XCTestExpectation(description: "Get the userInfo value that was set for the annotation")

        didFinishLoadingStyle = { mapView in

            // Given
            var annotation = PointAnnotation(coordinate: mapView.cameraState.center)
            let annotationManager = AnnotationManager(for: mapView,
                                                      with: self,
                                                      options: AnnotationOptions())
            annotation.userInfo = ["TestKey": true]
            annotationManager.addAnnotation(annotation)

            // When
            let sourceResult = self.style?.getSource(identifier: annotationManager.defaultSourceId, type: GeoJSONSource.self)
            let styleLayer = self.mapView?.mapboxMap.__map.getStyleLayerProperties(forLayerId: annotationManager.defaultSymbolLayerId)
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
    func setStyleImage(image: UIImage, with identifier: String, sdf: Bool, stretchX: [ImageStretches], stretchY: [ImageStretches], imageContent: ImageContent?) -> Result<Bool, ImageError> {
        guard let style = style else {
            XCTFail("No style available")
            return .failure(.addStyleImageFailed(nil))
        }

        return style.setStyleImage(image: image, with: identifier)
    }

    func getStyleImage(with identifier: String) -> Image? {
        guard let style = style else {
            XCTFail("No style available")
            return nil
        }

        return style.getStyleImage(with: identifier)
    }

    func addSource(source: Source, identifier: String) -> Result<Bool, SourceError> {
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

    func addLayer(_ layer: Layer, layerPosition: LayerPosition?) throws {
        let style = try XCTUnwrap(self.style)
        try style.addLayer(layer, layerPosition: layerPosition)
    }
}
