import XCTest
@testable import MapboxMaps

final class ViewAnnotationManagerTests: XCTestCase {

    var container: UIView!
    var mapboxMap: MockMapboxMap!
    var manager: ViewAnnotationManager!

    override func setUp() {
        super.setUp()
        container = UIView()
        mapboxMap = MockMapboxMap()
        manager = ViewAnnotationManager(containerView: container, mapboxMap: mapboxMap)
    }

    override func tearDown() {
        container = nil
        mapboxMap = nil
        manager = nil
        super.tearDown()
    }

    func testAddView() {
        let testView = UIView()
        let geometry = Geometry.point(Point(CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)))
        let options = ViewAnnotationOptions(geometry: geometry, width: 0.0, height: 0.0)
        try? manager.add(testView, options: options)
        XCTAssertEqual(mapboxMap.addViewAnnotationStub.invocations.count, 1)
        XCTAssertEqual(mapboxMap.addViewAnnotationStub.invocations.last?.parameters, .init(id: "0", options: options))
        XCTAssertEqual(testView.superview, container)
        XCTAssertEqual(container.subviews.count, 1)

        // Should fail if the view is already added
        XCTAssertThrowsError(try manager.add(testView, options: ViewAnnotationOptions(geometry: geometry)))

        // Adding views should increment keys
        XCTAssertEqual(mapboxMap.addViewAnnotationStub.invocations.last?.parameters.id, "0")
        try? manager.add(UIView(), options: ViewAnnotationOptions(geometry: geometry))
        XCTAssertEqual(mapboxMap.addViewAnnotationStub.invocations.last?.parameters.id, "1")
    }

    func testAddViewReadSize() {
        let testView = UIView()
        let geometry = Geometry.point(Point(CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)))
        let expectedSize = CGSize(width: 32.0, height: 64.0)
        testView.bounds.size = expectedSize
        try? manager.add(testView, options: ViewAnnotationOptions(geometry: geometry))

        XCTAssertEqual(mapboxMap.addViewAnnotationStub.invocations.first?.parameters.options, ViewAnnotationOptions(geometry: geometry, width: expectedSize.width, height: expectedSize.height))
    }

    func testAddViewMissingGeometry() {
        XCTAssertThrowsError(try manager.add(UIView(), options: ViewAnnotationOptions()))
        XCTAssertEqual(mapboxMap.addViewAnnotationStub.invocations.count, 0)
        XCTAssertEqual(container.subviews.count, 0)
    }

    func testRemove() {
        // Removing a view which wasn't added should not call internal remove method
        let view = UIView()
        manager.remove(view)
        XCTAssertEqual(mapboxMap.removeViewAnnotationStub.invocations.count, 0)

        let annotationView = addTestAnnotationView()
        let expectedId = mapboxMap.addViewAnnotationStub.invocations.last!.parameters.id
        XCTAssertEqual(container.subviews.count, 1)
        manager.remove(annotationView)
        XCTAssertEqual(mapboxMap.removeViewAnnotationStub.invocations.count, 1)
        XCTAssertEqual(mapboxMap.removeViewAnnotationStub.invocations.first?.parameters, expectedId)
        XCTAssertEqual(container.subviews.count, 0)
    }

    func testAssociatedFeatureIdIsAlreadyInUse() {
        let testView = UIView()
        let geometry = Geometry.point(Point(CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)))
        let optionWithFeatureId = ViewAnnotationOptions(geometry: geometry, associatedFeatureId: "testId")

        XCTAssertNoThrow(try manager.add(testView, options: optionWithFeatureId))

        // Should prevent adding a view with a feature id which is already in use
        XCTAssertThrowsError(try manager.add(UIView(), options: optionWithFeatureId))

        let otherView = UIView()
        XCTAssertNoThrow(try manager.add(otherView, options: ViewAnnotationOptions(geometry: geometry)))
        // Should prevent updating a view with a feature id which is already in use
        XCTAssertThrowsError(try manager.update(otherView, options: optionWithFeatureId))

        // Removing the view should allow the usage of the feature ID again
        manager.remove(testView)
        XCTAssertThrowsError(try manager.add(UIView(), options: optionWithFeatureId))
    }

    func testAssociatedFeatureIdUpdateDissociate() {
        let testIdA = "testIdA"
        let testView = UIView()
        let geometry = Geometry.point(Point(CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)))
        let optionsA = ViewAnnotationOptions(geometry: geometry, width: 0.0, height: 0.0, associatedFeatureId: testIdA)
        try? manager.add(testView, options: optionsA)
        mapboxMap.optionsForViewAnnotationWithIdStub.defaultReturnValue = optionsA

        XCTAssertEqual(testView, manager.view(forFeatureId: testIdA))
        XCTAssertEqual(optionsA, manager.options(forFeatureId: testIdA))

        let testIdB = "testIdB"
        let optionsB = ViewAnnotationOptions(associatedFeatureId: testIdB)
        try? manager.update(testView, options: optionsB)
        mapboxMap.optionsForViewAnnotationWithIdStub.defaultReturnValue = optionsB
        XCTAssertNil(manager.view(forFeatureId: testIdA))
        XCTAssertNil(manager.options(forFeatureId: testIdA))

        XCTAssertEqual(testView, manager.view(forFeatureId: testIdB))
        XCTAssertEqual(optionsB, manager.options(forFeatureId: testIdB))
    }

    func testUpdate() {
        let annotationView = addTestAnnotationView()
        XCTAssertEqual(mapboxMap.updateViewAnnotationStub.invocations.count, 0)
        let options = ViewAnnotationOptions(width: 10.0, allowOverlap: false, anchor: .bottomRight)
        XCTAssertNoThrow(try manager.update(annotationView, options: options))
        XCTAssertEqual(mapboxMap.updateViewAnnotationStub.invocations.count, 1)
        XCTAssertEqual(mapboxMap.updateViewAnnotationStub.invocations.first?.parameters.options, options)

        // Trying to update the view after removal should throw
        manager.remove(annotationView)
        XCTAssertThrowsError(try manager.update(annotationView, options: options))
    }

    func testViewForFeatureId() {
        let testFeatureIdOne = "testFeatureIdOne"
        let annotationView = addTestAnnotationView(featureId: testFeatureIdOne)
        XCTAssertEqual(annotationView, manager.view(forFeatureId: testFeatureIdOne))
        XCTAssertNil(manager.view(forFeatureId: "testFeatureIdTwo"))
        XCTAssertNil(manager.view(forFeatureId: ""))

        manager.remove(annotationView)
        XCTAssertNil(manager.view(forFeatureId: testFeatureIdOne))
    }

    func testOptionsforFeatureId() {
        let testFeatureIdOne = "testFeatureIdOne"
        let geometry = Geometry.point(Point(CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)))
        let expectedOptions = ViewAnnotationOptions(geometry: geometry, associatedFeatureId: testFeatureIdOne)
        let annotationView = addTestAnnotationView(featureId: testFeatureIdOne)
        XCTAssertEqual(expectedOptions, manager.options(forFeatureId: testFeatureIdOne))
        manager.remove(annotationView)
        XCTAssertNil(manager.options(forFeatureId: testFeatureIdOne))
    }

    func testOptionsForView() {
        let testFeatureIdOne = "testFeatureIdOne"
        let geometry = Geometry.point(Point(CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)))
        let expectedOptions = ViewAnnotationOptions(geometry: geometry, associatedFeatureId: testFeatureIdOne)
        let annotationView = addTestAnnotationView(featureId: testFeatureIdOne)
        XCTAssertEqual(expectedOptions, manager.options(for: annotationView))
        manager.remove(annotationView)
        XCTAssertNil(manager.options(for: annotationView))
    }

    func testValidateAnnotation() {
        let annotationView = addTestAnnotationView()
        let id = mapboxMap.addViewAnnotationStub.invocations.last!.parameters.id

        // Position update should also call validation
        triggerPositionUpdate(forId: id)
        XCTAssertEqual(mapboxMap.removeViewAnnotationStub.invocations.count, 0)

        annotationView.removeFromSuperview()
        XCTAssertEqual(container.subviews.count, 0)
        triggerPositionUpdate(forId: id)
        XCTAssertEqual(container.subviews.count, 1)

        let view = UIView()
        annotationView.removeFromSuperview()
        view.addSubview(annotationView)
        XCTAssertEqual(container.subviews.count, 0)
        triggerPositionUpdate(forId: id)
        XCTAssertEqual(container.subviews.count, 1)

        annotationView.isHidden = true
        triggerPositionUpdate(forId: id)
        XCTAssertFalse(annotationView.isHidden)
    }

    func testDisableValidateAnnotation() {
        let annotationView = addTestAnnotationView()
        let id = mapboxMap.addViewAnnotationStub.invocations.last!.parameters.id

        manager.validatesViews = false

        annotationView.removeFromSuperview()
        XCTAssertEqual(container.subviews.count, 0)
        triggerPositionUpdate(forId: id)
        XCTAssertEqual(container.subviews.count, 0)

        let view = UIView()
        annotationView.removeFromSuperview()
        view.addSubview(annotationView)
        XCTAssertEqual(container.subviews.count, 0)
        triggerPositionUpdate(forId: id)
        XCTAssertEqual(container.subviews.count, 0)
    }

    // MARK: Test placeAnnotations

    func testPlacementMissingAnnotation() {
        manager.onViewAnnotationPositionsUpdate(forPositions: [ViewAnnotationPositionDescriptor(
            identifier: "arbitraryId",
            width: 0,
            height: 0,
            leftTopCoordinate: CGPoint(x: 0.0, y: 0.0)
        )])
    }

    func testPlacementPosition() {
        let annotationView = addTestAnnotationView()
        XCTAssertEqual(container.subviews.count, 1)
        XCTAssertEqual(annotationView.frame, CGRect.zero)

        manager.onViewAnnotationPositionsUpdate(forPositions: [ViewAnnotationPositionDescriptor(
            identifier: "0",
            width: 100,
            height: 50,
            leftTopCoordinate: CGPoint(x: 150.0, y: 200.0)
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
            identifier: "0",
            width: 100,
            height: 50,
            leftTopCoordinate: CGPoint(x: 150.0, y: 200.0)
        )])

        XCTAssertFalse(annotationViewA.isHidden)
        XCTAssertTrue(annotationViewB.isHidden)
        XCTAssertTrue(annotationViewC.isHidden)
    }

    // MARK: - Helper functions

    private func addTestAnnotationView(featureId: String? = nil) -> UIView {
        let geometry = Geometry.point(Point(CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)))
        let options = ViewAnnotationOptions(geometry: geometry, associatedFeatureId: featureId)
        let view = UIView()
        try! manager.add(view, options: options)
        mapboxMap.optionsForViewAnnotationWithIdStub.defaultReturnValue = options
        return view
    }

    private func triggerPositionUpdate(forId id: String) {
        manager.onViewAnnotationPositionsUpdate(forPositions: [ViewAnnotationPositionDescriptor(
            identifier: id,
            width: 100,
            height: 50,
            leftTopCoordinate: CGPoint(x: 150.0, y: 200.0)
        )])
    }

}
