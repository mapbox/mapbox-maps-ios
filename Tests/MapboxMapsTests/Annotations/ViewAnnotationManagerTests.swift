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
        manager = ViewAnnotationManager(
            containerView: container,
            mapboxMap: mapboxMap)
    }

    override func tearDown() {
        container = nil
        mapboxMap = nil
        manager = nil
        super.tearDown()
    }

    func testAddView() {
        let testView = UIView()
        let geometry = Point(CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
        let options = ViewAnnotationOptions(geometry: geometry, width: 0.0, height: 0.0)

        XCTAssertNoThrow(try manager.add(testView, id: "test-id", options: options))
        XCTAssertEqual(mapboxMap.addViewAnnotationStub.invocations.count, 1)
        XCTAssertEqual(mapboxMap.addViewAnnotationStub.invocations.last?.parameters, .init(id: "test-id", options: options))
        XCTAssertEqual(testView.superview, container)
        XCTAssertEqual(container.subviews.count, 1)
        XCTAssertNotNil(manager.annotations[testView])

        XCTAssertNoThrow(try manager.add(UIView(), options: options))
        XCTAssertNotNil(UUID(uuidString: mapboxMap.addViewAnnotationStub.invocations.last!.parameters.id), "Generated annotation view ID must be a valid UUID")
    }

    func testAddExistingView() {
        let testView = UIView()
        let options = ViewAnnotationOptions(geometry: Point(.init(latitude: 0.0, longitude: 0.0)))

        XCTAssertNoThrow(try manager.add(testView, options: options))
        XCTAssertThrowsError(try manager.add(testView, options: options))
    }

    func testAddViewWithExistingID() {
        let options = ViewAnnotationOptions(geometry: Point(.init(latitude: 0.0, longitude: 0.0)))

        XCTAssertNoThrow(try manager.add(UIView(), id: "test-id", options: options))
        XCTAssertThrowsError(try manager.add(UIView(), id: "test-id", options: options))
    }

    func testAddViewReadSize() {
        let testView = UIView()
        let geometry = Point(CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
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
        let annotationView = addTestAnnotationView()
        let expectedId = mapboxMap.addViewAnnotationStub.invocations.last!.parameters.id
        XCTAssertEqual(container.subviews.count, 1)
        XCTAssertNotNil(manager.annotations[annotationView])

        manager.remove(annotationView)

        XCTAssertEqual(mapboxMap.removeViewAnnotationStub.invocations.count, 1)
        XCTAssertEqual(mapboxMap.removeViewAnnotationStub.invocations.first?.parameters, expectedId)
        XCTAssertEqual(container.subviews.count, 0)
        XCTAssertNil(manager.annotations[annotationView])
    }

    func testRemoveNoAnnotationViews() {
        // Removing a view which wasn't added should not call internal remove method
        let view = UIView()

        manager.remove(view)

        XCTAssertEqual(mapboxMap.removeViewAnnotationStub.invocations.count, 0)
    }

    func testRemoveAll() {
        _ = addTestAnnotationView()
        _ = addTestAnnotationView()
        _ = addTestAnnotationView()
        let viewIds = mapboxMap.addViewAnnotationStub.invocations.map(\.parameters.id)

        manager.removeAll()

        XCTAssertEqual(Set(mapboxMap.removeViewAnnotationStub.invocations.map(\.parameters)), Set(viewIds))
        XCTAssertTrue(container.subviews.isEmpty)
        XCTAssertTrue(manager.annotations.isEmpty)
    }

    func testRemoveAllNoAnnotationViews() {
        manager.removeAll()

        XCTAssertTrue(mapboxMap.removeViewAnnotationStub.invocations.isEmpty)
    }

    func testGetViewByID() {
        let testView = addTestAnnotationView(id: "test-id")

        XCTAssertEqual(manager.view(forId: "test-id"), testView)
        XCTAssertNotEqual(manager.view(forId: "other-id"), testView)
    }

    func testAssociatedFeatureIdIsAlreadyInUse() {
        let testView = UIView()
        let geometry = Point(CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
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
        let geometry = Point(CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
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

    func testAssociatedFeatureIdUpdateDoesNotDissociate() throws {
        let testIdA = "testIdA"
        let testView = UIView()
        let optionsA = ViewAnnotationOptions(geometry: Point(.random()),
                                             width: 0,
                                             height: 0,
                                             associatedFeatureId: testIdA)
        let updateOptions = ViewAnnotationOptions(geometry: optionsA.geometry,
                                                  width: 100,
                                                  height: 100,
                                                  associatedFeatureId: nil)
        try manager.add(testView, options: optionsA)
        mapboxMap.optionsForViewAnnotationWithIdStub.defaultReturnValue = optionsA

        try manager.update(testView, options: updateOptions)

        XCTAssertEqual(testView, manager.view(forFeatureId: testIdA))
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
        let geometry = Point(CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
        let expectedOptions = ViewAnnotationOptions(geometry: geometry, associatedFeatureId: testFeatureIdOne)
        let annotationView = addTestAnnotationView(featureId: testFeatureIdOne)
        XCTAssertEqual(expectedOptions, manager.options(forFeatureId: testFeatureIdOne))
        manager.remove(annotationView)
        XCTAssertNil(manager.options(forFeatureId: testFeatureIdOne))
    }

    func testOptionsForView() {
        let testFeatureIdOne = "testFeatureIdOne"
        let geometry = Point(CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
        let expectedOptions = ViewAnnotationOptions(geometry: geometry, associatedFeatureId: testFeatureIdOne)
        let annotationView = addTestAnnotationView(featureId: testFeatureIdOne)
        XCTAssertEqual(expectedOptions, manager.options(for: annotationView))
        manager.remove(annotationView)
        XCTAssertNil(manager.options(for: annotationView))
    }

    func testValidateAnnotation() {
        let annotationView = addTestAnnotationView()
        let id = mapboxMap.addViewAnnotationStub.invocations.last!.parameters.id

        // Annotation is correctly hidden when first added to map
        XCTAssertTrue(annotationView.isHidden)

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
        let annotationView = addTestAnnotationView(id: "test-id")
        XCTAssertEqual(container.subviews.count, 1)
        XCTAssertEqual(annotationView.frame, CGRect.zero)

        manager.onViewAnnotationPositionsUpdate(forPositions: [ViewAnnotationPositionDescriptor(
            identifier: "test-id",
            width: 100,
            height: 50,
            leftTopCoordinate: CGPoint(x: 150.0, y: 200.0)
        )])

        XCTAssertEqual(annotationView.frame, CGRect(x: 150.0, y: 200.0, width: 100.0, height: 50.0))
    }

    func testAnnotationPlacementZOrder() {
        let annotationViewA = addTestAnnotationView(id: "test-id")
        let annotationViewB = addTestAnnotationView(id: "test-id2")

        XCTAssertEqual(container.subviews, [annotationViewA, annotationViewB])

        manager.onViewAnnotationPositionsUpdate(forPositions: [ViewAnnotationPositionDescriptor(
            identifier: "test-id2",
            width: 100,
            height: 50,
            leftTopCoordinate: CGPoint(x: 150.0, y: 200.0)
        ), ViewAnnotationPositionDescriptor(
            identifier: "test-id",
            width: 100,
            height: 50,
            leftTopCoordinate: CGPoint(x: 150.0, y: 200.0)
        )])

        XCTAssertEqual(container.subviews, [annotationViewB, annotationViewA])
    }

    func testPlacementHideMissingAnnotations() {
        let annotationViewA = addTestAnnotationView(id: "test-id")
        let annotationViewB = addTestAnnotationView()
        let annotationViewC = addTestAnnotationView()

        XCTAssertTrue(annotationViewA.isHidden)
        XCTAssertTrue(annotationViewB.isHidden)
        XCTAssertTrue(annotationViewC.isHidden)

        manager.onViewAnnotationPositionsUpdate(forPositions: [ViewAnnotationPositionDescriptor(
            identifier: "test-id",
            width: 100,
            height: 50,
            leftTopCoordinate: CGPoint(x: 150.0, y: 200.0)
        )])

        XCTAssertFalse(annotationViewA.isHidden)
        XCTAssertTrue(annotationViewB.isHidden)
        XCTAssertTrue(annotationViewC.isHidden)
    }

    func testViewAnnotationUpdateDoesNotUnhideHiddenViews() throws {
        let annotationView = addTestAnnotationView()
        let id = try XCTUnwrap(mapboxMap.addViewAnnotationStub.invocations.last?.parameters.id)

        manager.onViewAnnotationPositionsUpdate(forPositions: [])

        try manager.update(annotationView, options: ViewAnnotationOptions())

        XCTAssertTrue(annotationView.isHidden)
    }

    func testViewAnnotationUpdateObserverNotifiedAboutUpdatedFrames() throws {
        let annotationView = addTestAnnotationView()
        let id = try XCTUnwrap(mapboxMap.addViewAnnotationStub.invocations.last?.parameters.id)
        let observer = MockViewAnnotationUpdateObserver()
        manager.addViewAnnotationUpdateObserver(observer)

        triggerPositionUpdate(forId: id)

        XCTAssertEqual(observer.framesDidChangeStub.invocations.first?.parameters, [annotationView])
    }

    func testViewAnnotationUpdateObserverNotNotifiedAboutSameFrames() {
        _ = addTestAnnotationView()
        let id = mapboxMap.addViewAnnotationStub.invocations.last!.parameters.id
        let observer = MockViewAnnotationUpdateObserver()
        manager.addViewAnnotationUpdateObserver(observer)
        triggerPositionUpdate(forId: id)
        observer.framesDidChangeStub.reset()

        triggerPositionUpdate(forId: id)

        XCTAssertTrue(observer.framesDidChangeStub.invocations.isEmpty)
    }

    func testViewAnnotationUpdateObserverConfirmsNewlyAddedViewsAreHidden() {
        let annotationView = addTestAnnotationView()
        let observer = MockViewAnnotationUpdateObserver()
        manager.addViewAnnotationUpdateObserver(observer)

        manager.onViewAnnotationPositionsUpdate(forPositions: [])

        XCTAssertTrue(annotationView.isHidden)
        XCTAssertTrue(observer.visibilityDidChangeStub.invocations.isEmpty)
    }

    func testViewAnnotationUpdateObserverNotifiedAboutNewlyVisibleViews() {
        let annotationView = addTestAnnotationView()
        let id = mapboxMap.addViewAnnotationStub.invocations.last!.parameters.id
        let observer = MockViewAnnotationUpdateObserver()
        manager.addViewAnnotationUpdateObserver(observer)
        try? manager.update(annotationView, options: ViewAnnotationOptions(visible: false))

        triggerPositionUpdate(forId: id)

        XCTAssertFalse(annotationView.isHidden)
        XCTAssertEqual(observer.visibilityDidChangeStub.invocations.first?.parameters, [annotationView])
    }

    func testRemoveViewAnnotationUpdateObserver() {
        _ = addTestAnnotationView()
        let id = mapboxMap.addViewAnnotationStub.invocations.last!.parameters.id
        let observer = MockViewAnnotationUpdateObserver()
        manager.addViewAnnotationUpdateObserver(observer)

        manager.removeViewAnnotationUpdateObserver(observer)
        // triggers frame did change observation
        triggerPositionUpdate(forId: id)
        // triggers visibility update observation
        manager.onViewAnnotationPositionsUpdate(forPositions: [])

        XCTAssertTrue(observer.framesDidChangeStub.invocations.isEmpty)
        XCTAssertTrue(observer.visibilityDidChangeStub.invocations.isEmpty)
    }

    func testCameraForAnnotations() throws {
        let points: [CLLocationCoordinate2D] = .random(withLength: 4, generator: CLLocationCoordinate2D.random)
        for (index, point) in points.enumerated() {
            let options = ViewAnnotationOptions(geometry: Point(point).geometry, width: 40, height: 40)
            try manager.add(UIView(), id: "\(index)", options: options)
            mapboxMap.optionsForViewAnnotationWithIdStub.returnValueQueue.insert(options, at: 0)
        }

        let padding = UIEdgeInsets.random()
        let bearing = CGFloat.random(in: -180...180)
        let pitch = CGFloat.random(in: 0...90)
        _ = manager.camera(forAnnotations: ["0", "1", "2", "3"], padding: padding, bearing: bearing, pitch: pitch)

        let parameters = try XCTUnwrap(mapboxMap.cameraForGeometryStub.invocations.last).parameters
        XCTAssertEqual(parameters.bearing, bearing)
        XCTAssertEqual(parameters.pitch, pitch)

        let coordinates = try XCTUnwrap(MapboxCommon.Geometry(parameters.geometry).extractLocationsArray()).map(\.mkCoordinateValue)
        let north = try XCTUnwrap(coordinates.max(by: { $0.latitude < $1.latitude })).latitude
        let east = try XCTUnwrap(coordinates.max(by: { $0.longitude < $1.longitude })).longitude
        let south = try XCTUnwrap(coordinates.min(by: { $0.latitude < $1.latitude })).latitude
        let west = try XCTUnwrap(coordinates.min(by: { $0.longitude < $1.longitude })).longitude

        XCTAssertFalse(points.contains(where: { $0.latitude > north }))
        XCTAssertFalse(points.contains(where: { $0.longitude > east }))
        XCTAssertFalse(points.contains(where: { $0.latitude < south }))
        XCTAssertFalse(points.contains(where: { $0.longitude < west }))
    }

    // MARK: - Helper functions

    private func addTestAnnotationView(id: String? = nil, featureId: String? = nil) -> UIView {
        let geometry = Point(CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
        let options = ViewAnnotationOptions(geometry: geometry, associatedFeatureId: featureId)
        let view = UIView()
        try! manager.add(view, id: id, options: options)
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
