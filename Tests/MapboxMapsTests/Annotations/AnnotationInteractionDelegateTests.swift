import XCTest
import CoreLocation

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsAnnotations
#endif

//swiftlint:disable explicit_acl explicit_top_level_acl
class AnnotationInteractionDelegateTests: XCTestCase {

    var annotationMapFeatureQueryableMock: MockMapFeatureQueryable!
    var annotationSupportableStyleMock: MockAnnotationStyleDelegate!
    var annotationMapEventsObservableMock: MockMapEventsObservable!
    var defaultCoordinate: CLLocationCoordinate2D!

    var selectionExpectation: XCTestExpectation?
    var selectionDelegateWasCalled: Bool = false
    var deselectionExpectation: XCTestExpectation?
    var deselectionDelegateWasCalled: Bool = false

    override func setUp() {
        annotationMapFeatureQueryableMock = MockMapFeatureQueryable()
        annotationMapEventsObservableMock = MockMapEventsObservable()
        annotationSupportableStyleMock = MockAnnotationStyleDelegate()
        selectionExpectation = expectation(description: "didSelectAnnotation was called")
        defaultCoordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }

    override func tearDown() {
        annotationMapFeatureQueryableMock = nil
        annotationSupportableStyleMock = nil
        annotationMapEventsObservableMock = nil
        selectionExpectation = nil
        deselectionExpectation = nil
        defaultCoordinate = nil
    }

    func testProgrammaticAnnotationSelection() {
        // Given
        let annotationManager = AnnotationManager(for: UIView(),
                                                  mapEventsObservable: annotationMapEventsObservableMock,
                                                  mapFeatureQueryable: annotationMapFeatureQueryableMock,
                                                  style: annotationSupportableStyleMock)
        annotationManager.interactionDelegate = self
        let annotation = PointAnnotation(coordinate: defaultCoordinate)
        _ = annotationManager.addAnnotation(annotation)
        XCTAssertEqual(annotationManager.selectedAnnotations.count, 0)

        // When
        annotationManager.selectAnnotation(annotation)

        // Then
        XCTAssertEqual(annotationManager.selectedAnnotations.count, 1)

        // When
        annotationManager.selectAnnotation(annotation)

        // Then
        XCTAssertEqual(annotationManager.selectedAnnotations.count, 0)

        waitForExpectations(timeout: 10)
        XCTAssertTrue(selectionDelegateWasCalled)
        XCTAssertTrue(deselectionDelegateWasCalled)
    }
}

extension AnnotationInteractionDelegateTests: AnnotationInteractionDelegate {
    func didSelectAnnotation(annotation: Annotation) {
        selectionDelegateWasCalled = true
        selectionExpectation?.fulfill()
    }

    func didDeselectAnnotation(annotation: Annotation) {
        deselectionDelegateWasCalled = true
        deselectionDelegateWasCalled = true
    }
}
