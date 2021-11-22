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

    func testAddView() {
        let testView = UIView()
        let geometry = Geometry.point(Point(CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)))
        try? manager.add(testView, options: ViewAnnotationOptions(geometry: geometry))
        XCTAssertEqual(mockMapboxMap.addViewAnnotationStub.invocations.count, 1)
        XCTAssertEqual(testView.superview, container)
        XCTAssertEqual(container.subviews.count, 1)
    }

    func testAddViewMissingGeometry() {
        XCTAssertThrowsError(try manager.add(UIView(), options: ViewAnnotationOptions()))
        XCTAssertEqual(mockMapboxMap.addViewAnnotationStub.invocations.count, 0)
        XCTAssertEqual(container.subviews.count, 0)
    }

    func testRemove() {
        let annotationView = addTestAnnotationView()
        XCTAssertEqual(mockMapboxMap.removeViewAnnotationStub.invocations.count, 0)
        XCTAssertEqual(container.subviews.count, 1)
        manager.remove(annotationView)
        XCTAssertEqual(mockMapboxMap.removeViewAnnotationStub.invocations.count, 1)
        XCTAssertEqual(container.subviews.count, 0)
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

    func testViewForFeatureId() {
        let testFeatureIdOne = "testFeatureIdOne"
        let annotationView = addTestAnnotationView(featureId: testFeatureIdOne)
        XCTAssertEqual(manager.viewsByFeatureIds[testFeatureIdOne], annotationView)
        XCTAssertEqual(annotationView, manager.view(forFeatureId: testFeatureIdOne))
        XCTAssertNil(manager.view(forFeatureId: "testFeatureIdTwo"))
        XCTAssertNil(manager.view(forFeatureId: ""))
        
        manager.remove(annotationView)
        XCTAssertEqual(manager.viewsByFeatureIds.keys.count, 0)
    }

    func testOptionsforFeatureId() {
        let testFeatureIdOne = "testFeatureIdOne"
        let geometry = Geometry.point(Point(CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)))
        let expectedOptions = ViewAnnotationOptions(geometry: geometry, associatedFeatureId: testFeatureIdOne)
        let annotationView = addTestAnnotationView(featureId: testFeatureIdOne)
        XCTAssertEqual(expectedOptions, manager.options(forFeatureId: testFeatureIdOne))
        XCTAssertNoThrow(try manager.remove(annotationView))
        XCTAssertNil(manager.options(forFeatureId: testFeatureIdOne))
    }

    func testOptionsForView() {
        let testFeatureIdOne = "testFeatureIdOne"
        let geometry = Geometry.point(Point(CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)))
        let expectedOptions = ViewAnnotationOptions(geometry: geometry, associatedFeatureId: testFeatureIdOne)
        let annotationView = addTestAnnotationView(featureId: testFeatureIdOne)
        XCTAssertEqual(expectedOptions, manager.options(for: annotationView))
        XCTAssertNoThrow(try manager.remove(annotationView))
        XCTAssertNil(manager.options(for: annotationView))
    }

    func testValidateAnnotation() {
        let annotationView = addTestAnnotationView()

        manager.validate(annotationView)
        XCTAssertEqual(mockMapboxMap.removeViewAnnotationStub.invocations.count, 0)

        annotationView.removeFromSuperview()
        XCTAssertEqual(container.subviews.count, 0)
        manager.validate(annotationView)
        XCTAssertEqual(container.subviews.count, 1)

        let view = UIView()
        annotationView.removeFromSuperview()
        view.addSubview(annotationView)
        XCTAssertEqual(container.subviews.count, 0)
        manager.validate(annotationView)
        XCTAssertEqual(container.subviews.count, 1)

        annotationView.isHidden = true
        manager.validate(annotationView)
        XCTAssertFalse(annotationView.isHidden)
    }

    func testExpectedHiddenState() {
        let annotationView = addTestAnnotationView()
        let id = manager.idsByView[annotationView]!

        XCTAssertFalse(manager.expectedHiddenByView[annotationView]!)
        // Not including ID in position update signals that view is out of bounds
        manager.onViewAnnotationPositionsUpdate(forPositions: [])
        XCTAssertTrue(manager.expectedHiddenByView[annotationView]!)
        manager.onViewAnnotationPositionsUpdate(forPositions: [ViewAnnotationPositionDescriptor(
            __identifier: id,
            width: UInt32(100),
            height: UInt32(50),
            leftTopCoordinate: ScreenCoordinate(x: 100.0, y: 100.0)
        )])
        XCTAssertFalse(manager.expectedHiddenByView[annotationView]!)
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
            __identifier: manager.idsByView[annotationView]!,
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
            __identifier: manager.idsByView[annotationViewA]!,
            width: UInt32(100),
            height: UInt32(50),
            leftTopCoordinate: ScreenCoordinate(x: 150.0, y: 200.0)
        )])

        XCTAssertFalse(annotationViewA.isHidden)
        XCTAssertTrue(annotationViewB.isHidden)
        XCTAssertTrue(annotationViewC.isHidden)
    }

    // MARK: - Helper functions

    func addTestAnnotationView(featureId: String? = nil) -> UIView {
        let geometry = Geometry.point(Point(CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)))
        let options = ViewAnnotationOptions(geometry: geometry, associatedFeatureId: featureId)
        let view = UIView()
        try! manager.add(view, options: options)
        mockMapboxMap.optionsForViewAnnotationWithIdStub.defaultReturnValue = options
        return view
    }

}
