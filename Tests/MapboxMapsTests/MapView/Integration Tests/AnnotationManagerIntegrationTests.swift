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

        didFinishLoadingStyle = { [weak self] mapView in

            styleLoadedExpectation.fulfill()

            guard let self = self,
                  let style = self.style else {
                XCTFail("nil test or style")
                return
            }

            // Given
            let annotation = PointAnnotation(coordinate: mapView.cameraState.center)
            let annotationManager = AnnotationManager(for: mapView,
                                                      mapEventsObservable: mapView.mapboxMap,
                                                      with: self)
            annotationManager.addAnnotation(annotation)

            _ = try! style.sourceProperties(for: annotationManager.defaultSourceId)
            sourceAddedExpectation.fulfill()

            _ = try! style.layerProperties(for: annotationManager.defaultSymbolLayerId)
            styleLayerAddedExpectation.fulfill()
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
                                                      mapEventsObservable: mapView.mapboxMap,
                                                      with: self)
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

        didFinishLoadingStyle = { [weak self] mapView in

            styleLoadedExpectation.fulfill()

            guard let self = self,
                  let style = self.style else {
                XCTFail("nil test or style")
                return
            }

            // Given
            var annotation = PointAnnotation(coordinate: mapView.cameraState.center)
            let annotationManager = AnnotationManager(for: mapView,
                                                      mapEventsObservable: mapView.mapboxMap,
                                                      with: self)
            annotation.userInfo = ["TestKey": true]
            annotationManager.addAnnotation(annotation)

            // When
            _ = try! style.source(withId: annotationManager.defaultSourceId) as GeoJSONSource
            sourceAddedExpectation.fulfill()

            _ = try! style.layerProperties(for: annotationManager.defaultSymbolLayerId)
            styleLayerAddedExpectation.fulfill()
        }

        let expectations = [
            styleLoadedExpectation,
            sourceAddedExpectation,
            styleLayerAddedExpectation
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

    func image(withId id: String) -> UIImage? {
        guard let style = style else {
            return nil
        }
        return style.image(withId: id)
    }

    func addImage(_ image: UIImage, id: String, sdf: Bool, stretchX: [ImageStretches], stretchY: [ImageStretches], content: ImageContent?) throws {
        let style = try XCTUnwrap(self.style)
        try style.addImage(image, id: id)
    }

    func addSource(_ source: Source, id: String) throws {
        let style = try XCTUnwrap(self.style)
        try style.addSource(source, id: id)
    }

    func setSourceProperty(for sourceId: String, property: String, value: Any) throws {
        let style = try XCTUnwrap(self.style)
        try style.setSourceProperty(for: sourceId, property: property, value: value)
    }

    func addLayer(_ layer: Layer, layerPosition: LayerPosition?) throws {
        let style = try XCTUnwrap(self.style)
        try style.addLayer(layer, layerPosition: layerPosition)
    }
}
