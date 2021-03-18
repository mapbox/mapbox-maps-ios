import XCTest
import CoreLocation
import Turf

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsAnnotations
@testable import MapboxMapsFoundation
#endif

//swiftlint:disable explicit_acl explicit_top_level_acl
class AnnotationManagerTests: XCTestCase {

    var annotationSupportableMapMock: AnnotationSupportableMapMock!
    var annotationSupportableStyleMock: AnnotationStyleDelegateMock!
    var annotationManager: AnnotationManager!

    var defaultCoordinate: CLLocationCoordinate2D!

    override func setUp() {
        // Given
        annotationSupportableMapMock = AnnotationSupportableMapMock()
        annotationSupportableStyleMock = AnnotationStyleDelegateMock()
        annotationManager = AnnotationManager(for: annotationSupportableMapMock,
                                              with: annotationSupportableStyleMock,
                                              options: AnnotationOptions())

        defaultCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }

    override func tearDown() {
        annotationSupportableMapMock = nil
        annotationSupportableStyleMock = nil
        annotationManager = nil
        defaultCoordinate = nil
    }

    // MARK: - Test adding point annotation
    func testAnnotationOptions() {
        let a = AnnotationOptions()
        let b = AnnotationOptions()
        XCTAssertEqual(a, b)

        // Test ergonomics
        _ = AnnotationOptions(layerPosition: LayerPosition())
        _ = AnnotationOptions(sourceId: "test")
        _ = AnnotationOptions(sourceOptions: AnnotationSourceOptions())
    }

    func testAnnotationManagerDefaultInitialization() {
        // Given / When
        let expectedInitialAnnotationsCount = 0

        // Then
        XCTAssertEqual(annotationManager.annotations.count, expectedInitialAnnotationsCount)
        XCTAssertTrue(annotationManager.annotationFeatures.features.isEmpty)
        XCTAssertNotNil(annotationManager.tapGesture)
        XCTAssertNil(annotationManager.annotationSource)
        XCTAssertNil(annotationManager.symbolLayer)
        XCTAssertNil(annotationManager.lineLayer)
        XCTAssertNil(annotationManager.fillLayer)
    }

    func testLayerIdentifiers() {
        let symbolLayerId = annotationManager.layerId(for: PointAnnotation.self)
        XCTAssertNil(symbolLayerId)

        let lineLayerId = annotationManager.layerId(for: LineAnnotation.self)
        XCTAssertNil(lineLayerId)

        let fillLayerId = annotationManager.layerId(for: PolygonAnnotation.self)
        XCTAssertNil(fillLayerId)
    }

    func testAnnotationFeatureCollectionIsValid() {
        // Given / When
        guard let geoJSONDictionary = try? GeoJSONManager.dictionaryFrom(annotationManager.annotationFeatures) else {
            return XCTFail("Failed to parse data from annotation FeatureCollection")
        }

        // Then
        XCTAssertTrue(JSONSerialization.isValidJSONObject(geoJSONDictionary))
    }

    func testAnnotationFeatureConversion() {
        // Given
        let coordinate = CLLocationCoordinate2D(latitude: 25, longitude: 25)
        let annotation = PointAnnotation(coordinate: coordinate)

        // When
        let feature = try? annotationManager.makeFeature(for: annotation)

        // Then
        XCTAssertNoThrow(feature)

        guard let featureIdentifier = feature?.identifier?.value as? String else {
            XCTFail("FeatureIdentifier should be a String")
            return
        }

        guard let featureGeometry = feature?.geometry.value as? Point else {
            XCTFail("Feature should be a point")
            return
        }

        XCTAssertEqual(annotation.identifier, featureIdentifier)
        XCTAssertEqual(annotation.coordinate, featureGeometry.coordinates)
    }

    func testUpdateFeatureCollection() {
        // Given / When
        let coordinate = CLLocationCoordinate2D(latitude: -45, longitude: 50)
        let annotation = PointAnnotation(coordinate: coordinate)

        // Then
        XCTAssertTrue(annotationManager.annotationFeatures.features.isEmpty)
        XCTAssertNoThrow(try? annotationManager.updateFeatureCollection(for: annotation))
        XCTAssertTrue(annotationManager.annotationFeatures.features.count == 1)
    }

    func testAddingSingleAnnotation() {
        // Given
        let annotation = PointAnnotation(coordinate: defaultCoordinate)
        let expectedAnnotationsCount = 1

        // When
        let addResult = annotationManager.addAnnotation(annotation)

        // Then
        XCTAssertNoThrow(try? addResult.get())
        XCTAssertEqual(annotationManager.annotations.count, expectedAnnotationsCount)
        XCTAssertTrue(annotationManager.annotations.keys.contains(annotation.identifier))
    }

    func testAddingMultipleAnnotations() {
        // Given
        let annotation1 = PointAnnotation(coordinate: defaultCoordinate)
        let annotation2 = PointAnnotation(coordinate: defaultCoordinate)
        let expectedAnnotationsCount = 2

        // When
        let result = annotationManager.addAnnotations([annotation1, annotation2])

        // Then
        XCTAssertNoThrow(try? result.get())
        XCTAssertEqual(annotationManager.annotations.count, expectedAnnotationsCount)
        XCTAssertTrue(annotationManager.annotations.keys.contains(annotation1.identifier))
        XCTAssertTrue(annotationManager.annotations.keys.contains(annotation2.identifier))
    }

    func testRemoveSingleAnnotation() {
        // Given
        let annotation = PointAnnotation(coordinate: defaultCoordinate)
        let expectedAnnotationCount = 0

        // When
        let addResult = annotationManager.addAnnotation(annotation)
        let removeResult = annotationManager.removeAnnotation(annotation)

        // Then
        XCTAssertNoThrow(try? addResult.get())
        XCTAssertNoThrow(try? removeResult.get())
        XCTAssertEqual(annotationManager.annotations.count, expectedAnnotationCount)
        XCTAssertFalse(annotationManager.annotations.keys.contains(annotation.identifier))
    }

    func testRemoveMultipleAnnotations() {
        // Given
        let annotation1 = PointAnnotation(coordinate: defaultCoordinate)
        let annotation2 = PointAnnotation(coordinate: defaultCoordinate)
        let annotation3 = PointAnnotation(coordinate: defaultCoordinate)
        let expectedAnnotationCount = 1

        // When
        let addResult = annotationManager.addAnnotations([annotation1, annotation2, annotation3])
        let removeResult = annotationManager.removeAnnotations([annotation1, annotation3])

        // Then
        XCTAssertNoThrow(try? addResult.get())
        XCTAssertNoThrow(try? removeResult.get())
        XCTAssertEqual(annotationManager.annotations.count, expectedAnnotationCount)
        XCTAssertTrue(annotationManager.annotations.keys.contains(annotation2.identifier))
    }

    func testUpdateAnnotation() {
        // Given
        var annotation = PointAnnotation(coordinate: defaultCoordinate)
        annotationManager.addAnnotation(annotation)

        // When
        annotation.coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)

        // Then
        XCTAssertNoThrow(try annotationManager.updateAnnotation(annotation))
        let pointAnnotation = annotationManager.annotations[annotation.identifier] as? PointAnnotation
        XCTAssertEqual(annotation.coordinate, pointAnnotation?.coordinate)
    }

    func testUserInteractionEnabled() {
        XCTAssertTrue(annotationManager.userInteractionEnabled)
        XCTAssertNotNil(annotationManager.tapGesture)

        annotationManager.userInteractionEnabled = false

        XCTAssertFalse(annotationManager.userInteractionEnabled)
        XCTAssertNil(annotationManager.tapGesture)

        annotationManager.userInteractionEnabled = true

        XCTAssertTrue(annotationManager.userInteractionEnabled)
        XCTAssertNotNil(annotationManager.tapGesture)
    }

    func testLayerIdentifiersAfterAddingAnnotation() {
        annotationManager.addAnnotation(PointAnnotation(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0)))
        let symbolLayerId = annotationManager.layerId(for: PointAnnotation.self)
        XCTAssertEqual(symbolLayerId, annotationManager.defaultSymbolLayerId)

        annotationManager.addAnnotation(LineAnnotation(coordinates: [
            CLLocationCoordinate2D(latitude: 0, longitude: 0),
            CLLocationCoordinate2D(latitude: 1, longitude: 1)
        ]))
        let lineLayerId = annotationManager.layerId(for: LineAnnotation.self)
        XCTAssertEqual(lineLayerId, annotationManager.defaultLineLayerId)

        annotationManager.addAnnotation(PolygonAnnotation(coordinates: [
            CLLocationCoordinate2D(latitude: 0, longitude: 0),
            CLLocationCoordinate2D(latitude: 0, longitude: 1),
            CLLocationCoordinate2D(latitude: 1, longitude: 1),
            CLLocationCoordinate2D(latitude: 1, longitude: 0)
        ]))
        let fillLayerId = annotationManager.layerId(for: PolygonAnnotation.self)
        XCTAssertEqual(fillLayerId, annotationManager.defaultPolygonLayerId)
    }
}
