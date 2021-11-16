import XCTest
@testable import MapboxMaps
@_implementationOnly import MapboxCoreMaps_Private

final class ViewAnnotationTests: XCTestCase {

    var container: SubviewInteractionOnlyView!
    var mockMapboxMap: MockMapboxMap!
    var manager: ViewAnnotationManager!

    override func setUp() {
        super.setUp()
        container = SubviewInteractionOnlyView()
        mockMapboxMap = MockMapboxMap()
        manager = ViewAnnotationManager(containerView: container, mapboxMap: mockMapboxMap)
    }

    override func tearDown() {
        container = nil
        mockMapboxMap = nil
        manager = nil
        super.tearDown()
    }

    func testAddAnnotationView() {
        let testView = UIView()
        let geometry = Geometry.point(Point(CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)))
        let annotationView = try? manager.addAnnotationView(withContent: testView, options: ViewAnnotationOptions(geometry: geometry))
        XCTAssertEqual(mockMapboxMap.addViewAnnotationStub.invocations.count, 1)
        XCTAssertEqual(annotationView?.superview, container)
        XCTAssertEqual(annotationView?.subviews.first, testView)
        XCTAssertEqual(container.subviews.count, 1)
    }

    func testAddAnnotationViewMissingGeometry() {
        XCTAssertThrowsError(try manager.addAnnotationView(withContent: UIView(), options: ViewAnnotationOptions()))
        XCTAssertEqual(mockMapboxMap.addViewAnnotationStub.invocations.count, 0)
        XCTAssertEqual(container.subviews.count, 0)
    }

    func testRemove() {
        let annotationView = addTestAnnotationView()
        XCTAssertEqual(mockMapboxMap.removeViewAnnotationStub.invocations.count, 0)
        XCTAssertEqual(container.subviews.count, 1)
        XCTAssertNoThrow(try manager.remove(annotationView))
        XCTAssertEqual(mockMapboxMap.removeViewAnnotationStub.invocations.count, 1)
        XCTAssertEqual(container.subviews.count, 0)

        // Trying to remove the same view the second time should throw
        XCTAssertThrowsError(try manager.remove(annotationView))
    }

    func testUpdate() {
        let annotationView = addTestAnnotationView()
        XCTAssertEqual(mockMapboxMap.updateViewAnnotationStub.invocations.count, 0)
        let options = ViewAnnotationOptions(width: 10.0, allowOverlap: false, anchor: .bottomRight)
        XCTAssertNoThrow(try manager.update(annotationView, options: options))
        XCTAssertEqual(mockMapboxMap.updateViewAnnotationStub.invocations.count, 1)
        XCTAssertEqual(mockMapboxMap.updateViewAnnotationStub.invocations.first?.parameters.options, options)

        // Trying to update the view after removal should throw
        XCTAssertNoThrow(try manager.remove(annotationView))
        XCTAssertThrowsError(try manager.update(annotationView, options: options))
    }

    func testViewAnnotationByFeatureId() {
        let testFeatureIdOne = "testFeatureIdOne"
        let annotationView = addTestAnnotationView(featureId: testFeatureIdOne)
        XCTAssertEqual(annotationView, manager.viewAnnotation(byFeatureId: testFeatureIdOne))
        XCTAssertNil(manager.viewAnnotation(byFeatureId: "testFeatureIdTwo"))
        XCTAssertNil(manager.viewAnnotation(byFeatureId: ""))
    }

    func testOptionsByFeatureId() {
        let testFeatureIdOne = "testFeatureIdOne"
        let geometry = Geometry.point(Point(CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)))
        let expectedOptions = ViewAnnotationOptions(geometry: geometry, associatedFeatureId: testFeatureIdOne)
        let annotationView = addTestAnnotationView(featureId: testFeatureIdOne)
        XCTAssertEqual(expectedOptions, manager.options(byFeatureId: testFeatureIdOne))
        XCTAssertNoThrow(try manager.remove(annotationView))
        XCTAssertNil(manager.options(byFeatureId: testFeatureIdOne))
    }

    func testOptionsByAnnotationView() {
        let testFeatureIdOne = "testFeatureIdOne"
        let geometry = Geometry.point(Point(CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)))
        let expectedOptions = ViewAnnotationOptions(geometry: geometry, associatedFeatureId: testFeatureIdOne)
        let annotationView = addTestAnnotationView(featureId: testFeatureIdOne)
        XCTAssertEqual(expectedOptions, manager.options(byAnnotationView: annotationView))
        XCTAssertNoThrow(try manager.remove(annotationView))
        XCTAssertNil(manager.options(byAnnotationView: annotationView))
    }

    func testValidateAnnotation() {
        let annotationView = addTestAnnotationView()

        // First check: annotation is valid, leave it in place
        manager.validateAnnotation(byAnnotationId: annotationView.id)
        XCTAssertEqual(mockMapboxMap.removeViewAnnotationStub.invocations.count, 0)

        // Second check: annotation is manually removed from superview, remove is called
        annotationView.removeFromSuperview()
        manager.validateAnnotation(byAnnotationId: annotationView.id)
        XCTAssertEqual(mockMapboxMap.removeViewAnnotationStub.invocations.count, 1)
    }

    func testAnnotationViewVisibilityUpdate() {
        let annotationView = addTestAnnotationView()

        let stub = mockMapboxMap.updateViewAnnotationStub
        XCTAssertEqual(stub.invocations.count, 0)
        annotationView.isHidden = true
        XCTAssertEqual(stub.invocations.count, 1)
        XCTAssertFalse(stub.invocations.last!.parameters.options.visible!)
        annotationView.isHidden = false
        XCTAssertEqual(stub.invocations.count, 2)
        XCTAssertTrue(stub.invocations.last!.parameters.options.visible!)
    }

    // MARK: Test placeAnnotations

    func testPlacementMissingAnnotation() {
        manager.onViewAnnotationPositionsUpdate(forPositions: [ViewAnnotationPositionDescriptor(
            __identifier: "arbitraryId",
            width: UInt32(0),
            height: UInt32(0),
            leftTopCoordinate: ScreenCoordinate(x: 0.0, y: 0.0)
        )])
    }

    func testPlacementPosition() {
        let annotationView = addTestAnnotationView()
        XCTAssertEqual(container.subviews.count, 1)
        XCTAssertEqual(annotationView.frame, CGRect.zero)

        manager.onViewAnnotationPositionsUpdate(forPositions: [ViewAnnotationPositionDescriptor(
            __identifier: annotationView.id,
            width: UInt32(100),
            height: UInt32(50),
            leftTopCoordinate: ScreenCoordinate(x: 150.0, y: 200.0)
        )])

        XCTAssertEqual(annotationView.frame, CGRect(x: 150.0, y: 200.0, width: 100.0, height: 50.0))
    }

    func testPlacementHideMissingAnnotations() {
        let annotationViewA = addTestAnnotationView()
        let annotationViewB = addTestAnnotationView()
        let annotationViewC = addTestAnnotationView()

        XCTAssertFalse(annotationViewA.isHidden)
        XCTAssertFalse(annotationViewB.isHidden)
        XCTAssertFalse(annotationViewC.isHidden)

        manager.onViewAnnotationPositionsUpdate(forPositions: [ViewAnnotationPositionDescriptor(
            __identifier: annotationViewA.id,
            width: UInt32(100),
            height: UInt32(50),
            leftTopCoordinate: ScreenCoordinate(x: 150.0, y: 200.0)
        )])

        XCTAssertFalse(annotationViewA.isHidden)
        XCTAssertTrue(annotationViewB.isHidden)
        XCTAssertTrue(annotationViewC.isHidden)
    }

    // MARK: - Helper functions

    func addTestAnnotationView(featureId: String? = nil) -> AnnotationView {
        let geometry = Geometry.point(Point(CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)))
        let options = ViewAnnotationOptions(geometry: geometry, associatedFeatureId: featureId)
        let annotationView = try! manager.addAnnotationView(withContent: UIView(), options: options)
        mockMapboxMap.optionsForViewAnnotationWithIdStub.defaultReturnValue = options
        return annotationView
    }

}
