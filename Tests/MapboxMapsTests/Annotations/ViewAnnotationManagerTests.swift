import XCTest
@testable import MapboxMaps

final class ViewAnnotationManagerTests: XCTestCase {

    var container: UIView!
    var mapboxMap: MockMapboxMap!
    var manager: ViewAnnotationManager!
    @TestSignal var displayLink: Signal<Void>

    override func setUp() {
        super.setUp()
        container = UIView()
        mapboxMap = MockMapboxMap()
        manager = ViewAnnotationManager(
            containerView: container,
            mapboxMap: mapboxMap,
            displayLink: displayLink)
    }

    override func tearDown() {
        container = nil
        mapboxMap = nil
        manager = nil
        super.tearDown()
    }

    @available(*, deprecated)
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

    @available(*, deprecated)
    func testAddExistingView() {
        let testView = UIView()
        let point = Point(.init(latitude: 0.0, longitude: 0.0))
        let options = ViewAnnotationOptions(annotatedFeature: .geometry(point))

        XCTAssertNoThrow(try manager.add(testView, options: options))
        XCTAssertThrowsError(try manager.add(testView, options: options))
    }

    @available(*, deprecated)
    func testAddViewWithExistingID() {
        let options = ViewAnnotationOptions(geometry: Point(.init(latitude: 0.0, longitude: 0.0)))

        XCTAssertNoThrow(try manager.add(UIView(), id: "test-id", options: options))
        XCTAssertThrowsError(try manager.add(UIView(), id: "test-id", options: options))
    }

    @available(*, deprecated)
    func testAddViewReadSize() {
        let testView = UIView()
        let geometry = Point(CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
        let expectedSize = CGSize(width: 32.0, height: 64.0)
        testView.bounds.size = expectedSize
        try? manager.add(testView, options: ViewAnnotationOptions(geometry: geometry))

        XCTAssertEqual(mapboxMap.addViewAnnotationStub.invocations.first?.parameters.options, ViewAnnotationOptions(geometry: geometry, width: expectedSize.width, height: expectedSize.height))
    }

    @available(*, deprecated)
    func testAddViewMissingGeometry() {
        XCTAssertThrowsError(try manager.add(UIView(), options: ViewAnnotationOptions()))
        XCTAssertEqual(mapboxMap.addViewAnnotationStub.invocations.count, 0)
        XCTAssertEqual(container.subviews.count, 0)
    }

    @available(*, deprecated)
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

    @available(*, deprecated)
    func testRemoveNoAnnotationViews() {
        // Removing a view which wasn't added should not call internal remove method
        let view = UIView()

        manager.remove(view)

        XCTAssertEqual(mapboxMap.removeViewAnnotationStub.invocations.count, 0)
    }

    @available(*, deprecated)
    func testRemoveAll() {
        _ = addTestAnnotationView()
        _ = addTestAnnotationView()
        _ = addTestAnnotationView()
        let viewIds = mapboxMap.addViewAnnotationStub.invocations.map(\.parameters.id)

        manager.removeAll()

        XCTAssertEqual(Set(mapboxMap.removeViewAnnotationStub.invocations.map(\.parameters)), Set(viewIds))
        XCTAssertTrue(container.subviews.isEmpty)
        XCTAssertTrue(manager.allAnnotations.isEmpty)
    }

    func testRemoveAllObjectAnnotations() {
        let va1 = ViewAnnotation(
            annotatedFeature: .geometry(Point(CLLocationCoordinate2D(latitude: -34, longitude: -25))),
            view: UIView()
        )
        let va2 = ViewAnnotation(
            annotatedFeature: .geometry(Point(CLLocationCoordinate2D(latitude: 83, longitude: 120))),
            view: UIView()
        )
        manager.add(va1)
        manager.add(va2)

        XCTAssertFalse(manager.allAnnotations.isEmpty)
        manager.removeAll()

        XCTAssertTrue(manager.allAnnotations.isEmpty)
    }

    func testRemoveAllNoAnnotationViews() {
        manager.removeAll()

        XCTAssertTrue(mapboxMap.removeViewAnnotationStub.invocations.isEmpty)
        XCTAssertTrue(manager.allAnnotations.isEmpty)
    }

    @available(*, deprecated)
    func testGetViewByID() {
        let testView = addTestAnnotationView(id: "test-id")

        XCTAssertEqual(manager.view(forId: "test-id"), testView)
        XCTAssertNotEqual(manager.view(forId: "other-id"), testView)
    }

    @available(*, deprecated)
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

    @available(*, deprecated)
    func testOptionsForView() {
        let testFeatureIdOne = "testFeatureIdOne"
        let geometry = Point(CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
        let expectedOptions = ViewAnnotationOptions(geometry: geometry, associatedFeatureId: testFeatureIdOne)
        let annotationView = addTestAnnotationView(featureId: testFeatureIdOne)
        XCTAssertEqual(expectedOptions, manager.options(for: annotationView))
        manager.remove(annotationView)
        XCTAssertNil(manager.options(for: annotationView))
    }

    @available(*, deprecated)
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

    @available(*, deprecated)
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
        mapboxMap.simulateAnnotationPositionsUpdate([ViewAnnotationPositionDescriptor(
            identifier: "arbitraryId",
            frame: CGRect(x: 0, y: 0, width: 0, height: 0)
        )])
    }

    @available(*, deprecated)
    func testPlacementPosition() {
        let annotationView = addTestAnnotationView(id: "test-id")
        XCTAssertEqual(container.subviews.count, 1)
        XCTAssertEqual(annotationView.frame, CGRect.zero)

        mapboxMap.simulateAnnotationPositionsUpdate([ViewAnnotationPositionDescriptor(
            identifier: "test-id",
            frame: CGRect(x: 150, y: 200, width: 100, height: 50)
        )])

        XCTAssertEqual(annotationView.frame, CGRect(x: 150.0, y: 200.0, width: 100.0, height: 50.0))
    }

    @available(*, deprecated)
    func testAnnotationPlacementZOrder() {
        let annotationViewA = addTestAnnotationView(id: "test-id")
        let annotationViewB = addTestAnnotationView(id: "test-id2")

        XCTAssertEqual(container.subviews, [annotationViewA, annotationViewB])

        mapboxMap.simulateAnnotationPositionsUpdate([ViewAnnotationPositionDescriptor(
            identifier: "test-id2",
            frame: CGRect(x: 150, y: 200, width: 100, height: 50)
        ), ViewAnnotationPositionDescriptor(
            identifier: "test-id",
            frame: CGRect(x: 150, y: 200, width: 100, height: 50)
        )])

        XCTAssertEqual(container.subviews, [annotationViewB, annotationViewA])
    }

    @available(*, deprecated)
    func testPlacementHideMissingAnnotations() {
        let annotationViewA = addTestAnnotationView(id: "test-id")
        let annotationViewB = addTestAnnotationView()
        let annotationViewC = addTestAnnotationView()

        XCTAssertTrue(annotationViewA.isHidden)
        XCTAssertTrue(annotationViewB.isHidden)
        XCTAssertTrue(annotationViewC.isHidden)

        mapboxMap.simulateAnnotationPositionsUpdate([ViewAnnotationPositionDescriptor(
            identifier: "test-id",
            frame: CGRect(x: 150, y: 200, width: 100, height: 50)
        )])

        XCTAssertFalse(annotationViewA.isHidden)
        XCTAssertTrue(annotationViewB.isHidden)
        XCTAssertTrue(annotationViewC.isHidden)
    }

    @available(*, deprecated)
    func testDisplaysAnnotationProperty() {
        XCTAssertEqual(manager.displaysAnnotations.value, false)
        let annotationViewA = addTestAnnotationView(id: "test-id")

        XCTAssertEqual(manager.displaysAnnotations.value, false)

        mapboxMap.simulateAnnotationPositionsUpdate([ViewAnnotationPositionDescriptor(
            identifier: "test-id",
            frame: CGRect(x: 150, y: 200, width: 100, height: 50)
        )])

        XCTAssertEqual(manager.displaysAnnotations.value, true)

        mapboxMap.simulateAnnotationPositionsUpdate([])

        XCTAssertEqual(manager.displaysAnnotations.value, false)
    }

    @available(*, deprecated)
    func testViewAnnotationUpdateDoesNotUnhideHiddenViews() throws {
        let annotationView = addTestAnnotationView()

        mapboxMap.simulateAnnotationPositionsUpdate([])

        try manager.update(annotationView, options: ViewAnnotationOptions())

        XCTAssertTrue(annotationView.isHidden)
    }

    @available(*, deprecated)
    func testViewAnnotationUpdateObserverNotifiedAboutUpdatedFrames() throws {
        let annotationView = addTestAnnotationView()
        let id = try XCTUnwrap(mapboxMap.addViewAnnotationStub.invocations.last?.parameters.id)
        let observer = MockViewAnnotationUpdateObserver()
        manager.addViewAnnotationUpdateObserver(observer)

        triggerPositionUpdate(forId: id)

        XCTAssertEqual(observer.framesDidChangeStub.invocations.first?.parameters, [annotationView])
    }

    @available(*, deprecated)
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

    @available(*, deprecated)
    func testViewAnnotationUpdateObserverConfirmsNewlyAddedViewsAreHidden() {
        let annotationView = addTestAnnotationView()
        let observer = MockViewAnnotationUpdateObserver()
        manager.addViewAnnotationUpdateObserver(observer)

        mapboxMap.simulateAnnotationPositionsUpdate([])

        XCTAssertTrue(annotationView.isHidden)
        XCTAssertTrue(observer.visibilityDidChangeStub.invocations.isEmpty)
    }

    @available(*, deprecated)
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

    @available(*, deprecated)
    func testRemoveViewAnnotationUpdateObserver() {
        _ = addTestAnnotationView()
        let id = mapboxMap.addViewAnnotationStub.invocations.last!.parameters.id
        let observer = MockViewAnnotationUpdateObserver()
        manager.addViewAnnotationUpdateObserver(observer)

        manager.removeViewAnnotationUpdateObserver(observer)
        // triggers frame did change observation
        triggerPositionUpdate(forId: id)
        // triggers visibility update observation
        mapboxMap.simulateAnnotationPositionsUpdate([])

        XCTAssertTrue(observer.framesDidChangeStub.invocations.isEmpty)
        XCTAssertTrue(observer.visibilityDidChangeStub.invocations.isEmpty)
    }

    @available(*, deprecated)
    func testCameraForAnnotations() throws {
        // For annotation that has not been added or has incorrect geometry (must be a single Point)
        // we will not calculate camera.
        XCTAssertNil(manager.camera(forAnnotations: ["dummy"]))

        // Annotations that have been added and are valid.
        let points = Array.random(
            withLength: 10,
            generator: { CLLocationCoordinate2D(latitude: 24, longitude: 84) }
        )
        let boundingBox = try XCTUnwrap(BoundingBox(from: points))

        for (index, point) in points.enumerated() {
            let options = ViewAnnotationOptions(geometry: Point(point).geometry, width: 60, height: 80)
            try manager.add(UIView(), id: "\(index)", options: options)
            mapboxMap.optionsForViewAnnotationWithIdStub.returnValueQueue.insert(options, at: 0)
        }

        mapboxMap.cameraForCoordinateBoundsStub.defaultSideEffect = { [mapboxMap] invocation in
            let camera = MapboxMaps.CameraOptions(
                center: invocation.parameters.coordinateBounds.center,
                padding: invocation.parameters.padding,
                zoom: 3,
                bearing: invocation.parameters.bearing,
                pitch: CGFloat(invocation.parameters.pitch ?? 0)
            )
            mapboxMap?.cameraForCoordinateBoundsStub.defaultReturnValue = camera
        }

        let bearing = 160.0
        let pitch = 30.0
        _ = manager.camera(forAnnotations: ["0", "1", "2", "3"], padding: .zero, bearing: bearing, pitch: pitch)

        let parameters = try XCTUnwrap(mapboxMap.cameraForCoordinateBoundsStub.invocations.last).parameters
        XCTAssertEqual(parameters.bearing, bearing)
        XCTAssertEqual(parameters.pitch, pitch)

        // Coordinate bounds from all annotation's points.
        let bounds = CoordinateBounds(southwest: boundingBox.southWest, northeast: boundingBox.northEast)
        // Final camera's inner bounds.
        let innerBounds = parameters.coordinateBounds

        XCTAssertTrue(bounds.contains(forArea: innerBounds, wrappedCoordinates: true))
    }

    // MARK: - Helper functions

    @available(*, deprecated)
    private func addTestAnnotationView(id: String? = nil, featureId: String? = nil) -> UIView {
        let geometry = Point(CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))
        let options = ViewAnnotationOptions(geometry: geometry, associatedFeatureId: featureId)
        let view = UIView()
        try! manager.add(view, id: id, options: options)
        mapboxMap.optionsForViewAnnotationWithIdStub.defaultReturnValue = options
        return view
    }

    private func triggerPositionUpdate(forId id: String) {
        mapboxMap.simulateAnnotationPositionsUpdate([ViewAnnotationPositionDescriptor(
            identifier: id,
            frame: CGRect(x: 150, y: 200, width: 100, height: 50)
        )])
    }
}
