@_spi(Experimental) @testable import MapboxMaps
import SwiftUI
import XCTest

final class ViewAnnotationTests: XCTestCase {
    var mapboxMap: MockMapboxMap!
    @TestSignal var displayLink: Signal<Void>
    var removeCount = 0
    var deps: ViewAnnotation.Deps!

    let availableSize = CGSize(width: 1000, height: 1000)

    override func setUp() {
        mapboxMap = MockMapboxMap()
        removeCount = 0
        deps = ViewAnnotation.Deps(
            superview: UIView(),
            mapboxMap: mapboxMap,
            displayLink: displayLink,
            onRemove: { [weak self] in
                self?.removeCount += 1
            })

        deps.superview.bounds = CGRect(origin: .init(x: 0, y: 0), size: availableSize)
    }

    override func tearDown() {
        mapboxMap = nil
        deps = nil
    }

    func testAddUpdateRemoveAddLifecycle() throws {
        let actualSize = CGSize(width: 100, height: 100)

        let view = DummyAnnotationView()
        view.actualSize = actualSize

        let point = Point(.init(latitude: 1, longitude: 2))
        let va = ViewAnnotation(annotatedFeature: .geometry(point), view: view)
        va.allowOverlap = true
        va.visible = true
        va.priority = 4
        va.allowZElevate = true
        let variableAnchors = [ViewAnnotationAnchorConfig(anchor: .bottom, offsetX: 10, offsetY: 20)]
        va.variableAnchors = variableAnchors
        va.allowOverlapWithPuck = true
        va.ignoreCameraPadding = true

        XCTAssertEqual(va.allowOverlap, true)
        XCTAssertEqual(va.visible, true)
        XCTAssertEqual(va.priority, 4)
        XCTAssertEqual(va.allowZElevate, true)

        // Add annotation
        va.bind(deps)

        XCTAssertEqual(deps.superview.subviews.first, view)
        XCTAssertEqual(deps.superview.bounds.size, view.providedAvailableSize)

        XCTAssertEqual(mapboxMap.addViewAnnotationStub.invocations.count, 1)
        let addParameters = try XCTUnwrap(mapboxMap.addViewAnnotationStub.invocations.last).parameters
        XCTAssertEqual(addParameters.id, va.id)
        XCTAssertEqual(addParameters.options.annotatedFeature, .geometry(point))
        XCTAssertEqual(addParameters.options.width, actualSize.width)
        XCTAssertEqual(addParameters.options.height, actualSize.height)
        XCTAssertEqual(addParameters.options.allowOverlap, true)
        XCTAssertEqual(addParameters.options.allowOverlapWithPuck, true)
        XCTAssertEqual(addParameters.options.allowZElevate, true)
        XCTAssertEqual(addParameters.options.ignoreCameraPadding, true)
        XCTAssertEqual(addParameters.options.priority, 4)
        XCTAssertEqual(addParameters.options.visible, true)
        XCTAssertEqual(addParameters.options.variableAnchors, variableAnchors)

        XCTAssertEqual(mapboxMap.updateViewAnnotationStub.invocations.count, 0)

        // Update
        va.annotatedFeature = .layerFeature(layerId: "foo", featureId: "bar")
        va.allowOverlap = true // no update
        va.visible = false
        va.priority = -1
        va.allowZElevate = false
        XCTAssertEqual(va.allowOverlap, true)
        XCTAssertEqual(va.visible, false)
        XCTAssertEqual(va.priority, -1)
        XCTAssertEqual(va.allowZElevate, false)

        // no update without display link
        XCTAssertEqual(mapboxMap.updateViewAnnotationStub.invocations.count, 0)

        $displayLink.send()
        XCTAssertEqual(mapboxMap.updateViewAnnotationStub.invocations.count, 1)
        let updParameters = try XCTUnwrap(mapboxMap.updateViewAnnotationStub.invocations.last).parameters
        XCTAssertEqual(updParameters.id, va.id)
        var expectedOptions = ViewAnnotationOptions(
            annotatedFeature: .layerFeature(layerId: "foo", featureId: "bar"),
            visible: false,
            priority: -1)
        expectedOptions.allowZElevate = false
        XCTAssertEqual(updParameters.options, expectedOptions)

        // Remove
        XCTAssertEqual(self.removeCount, 0)
        XCTAssertEqual(mapboxMap.removeViewAnnotationStub.invocations.count, 0)

        va.remove()
        XCTAssertEqual(self.removeCount, 1)
        XCTAssertEqual(deps.superview.subviews.count, 0)
        XCTAssertEqual(mapboxMap.removeViewAnnotationStub.invocations.count, 1)
        XCTAssertEqual(mapboxMap.removeViewAnnotationStub.invocations.first?.parameters, va.id)

        // Add again
        va.bind(deps)
        XCTAssertEqual(mapboxMap.addViewAnnotationStub.invocations.count, 2)
        let addParameters2 = try XCTUnwrap(mapboxMap.addViewAnnotationStub.invocations.last).parameters
        XCTAssertEqual(addParameters2.id, va.id)
        XCTAssertEqual(addParameters2.options.annotatedFeature, .layerFeature(layerId: "foo", featureId: "bar"))
        XCTAssertEqual(addParameters2.options.width, actualSize.width)
        XCTAssertEqual(addParameters2.options.height, actualSize.height)
        XCTAssertEqual(addParameters2.options.allowOverlap, true)
        XCTAssertEqual(addParameters2.options.allowZElevate, false)
        XCTAssertEqual(addParameters2.options.priority, -1)
        XCTAssertEqual(addParameters2.options.visible, false)
        XCTAssertEqual(addParameters2.options.variableAnchors, variableAnchors)
    }

    func testUpdateSize() throws {
        let view = DummyAnnotationView()
        view.actualSize = CGSize(width: 100, height: 100)

        let va = ViewAnnotation(coordinate: .init(latitude: 3, longitude: 4), view: view)

        va.bind(deps)

        // annotation is sized in superview bounds.
        XCTAssertEqual(deps.superview.bounds.size, view.providedAvailableSize)
        view.providedAvailableSize = nil

        view.actualSize = CGSize(width: 200, height: 300)
        va.setNeedsUpdateSize()
        va.setNeedsUpdateSize()

        // no update without display link
        XCTAssertEqual(mapboxMap.updateViewAnnotationStub.invocations.count, 0)

        $displayLink.send()
        XCTAssertEqual(mapboxMap.updateViewAnnotationStub.invocations.count, 1)
        let updParameters = try XCTUnwrap(mapboxMap.updateViewAnnotationStub.invocations.last).parameters
        XCTAssertEqual(updParameters.id, va.id)
        let expectedOptions = ViewAnnotationOptions(
            width: 200,
            height: 300)
        XCTAssertEqual(updParameters.options, expectedOptions)
    }

    func testPlacement() {
        let view = DummyAnnotationView()
        view.actualSize = CGSize(width: 100, height: 100)

        let va = ViewAnnotation(coordinate: .init(latitude: 1, longitude: 2), view: view)

        // Add annotation
        va.bind(deps)

        XCTAssertEqual(view.isHidden, true)

        var anchors = [ViewAnnotationAnchorConfig]()
        var frames = [CGRect]()
        var anchorCoordinates = [CLLocationCoordinate2D]()
        var visibilities = [Bool]()

        va.onFrameChanged = { frames.append($0) }
        va.onAnchorChanged = { anchors.append($0) }
        va.onVisibilityChanged = { visibilities.append($0) }
        va.onAnchorCoordinateChanged = { anchorCoordinates.append($0) }

        // Place 1
        let descriotor1 = ViewAnnotationPositionDescriptor(
            identifier: va.id,
            frame: CGRect(x: 1, y: 2, width: 3, height: 4),
            anchorCoordinate: .init(latitude: 5, longitude: 6),
            anchorConfig: .init(anchor: .bottom, offsetX: 7, offsetY: 8))
        va.place(with: descriotor1)

        XCTAssertEqual(view.frame, descriotor1.frame)
        XCTAssertEqual(va.anchorConfig, descriotor1.anchorConfig)
        XCTAssertEqual(va.anchorCoordinate, descriotor1.anchorCoordinate)
        XCTAssertEqual(view.isHidden, false)

        XCTAssertEqual(frames, [descriotor1.frame])
        XCTAssertEqual(anchors, [descriotor1.anchorConfig])
        XCTAssertEqual(anchorCoordinates, [descriotor1.anchorCoordinate])
        XCTAssertEqual(visibilities, [true])

        // Place 1, again, no updates
        va.place(with: descriotor1)
        XCTAssertEqual(frames, [descriotor1.frame])
        XCTAssertEqual(anchors, [descriotor1.anchorConfig])
        XCTAssertEqual(anchorCoordinates, [descriotor1.anchorCoordinate])
        XCTAssertEqual(visibilities, [true])

        // Place 2
        let descriotor2 = ViewAnnotationPositionDescriptor(
            identifier: va.id,
            frame: CGRect(x: 10, y: 20, width: 30, height: 40),
            anchorCoordinate: .init(latitude: 50, longitude: 60),
            anchorConfig: .init(anchor: .top, offsetX: 70, offsetY: 80))
        va.place(with: descriotor2)

        XCTAssertEqual(view.frame, descriotor2.frame)
        XCTAssertEqual(va.anchorConfig, descriotor2.anchorConfig)
        XCTAssertEqual(va.anchorCoordinate, descriotor2.anchorCoordinate)

        XCTAssertEqual(frames, [descriotor1.frame, descriotor2.frame])
        XCTAssertEqual(anchors, [descriotor1.anchorConfig, descriotor2.anchorConfig])
        XCTAssertEqual(anchorCoordinates, [descriotor1.anchorCoordinate, descriotor2.anchorCoordinate])
        XCTAssertEqual(visibilities, [true])
    }

    func testMultiplePropertyChangesBatchedIntoSingleUpdate() throws {
        let view = DummyAnnotationView()
        view.actualSize = CGSize(width: 100, height: 100)
        let va = ViewAnnotation(coordinate: .init(latitude: 1, longitude: 2), view: view)
        va.bind(deps)

        va.allowOverlap = true
        va.visible = false
        va.priority = 5
        va.ignoreCameraPadding = true

        XCTAssertEqual(mapboxMap.updateViewAnnotationStub.invocations.count, 0)
        $displayLink.send()
        XCTAssertEqual(mapboxMap.updateViewAnnotationStub.invocations.count, 1)

        let options = try XCTUnwrap(mapboxMap.updateViewAnnotationStub.invocations.last).parameters.options
        XCTAssertEqual(options.allowOverlap, true)
        XCTAssertEqual(options.visible, false)
        XCTAssertEqual(options.priority, 5)
        XCTAssertEqual(options.ignoreCameraPadding, true)
    }

    // MARK: - Collision Boxes

    func testCollisionBoxesNoneMarked() throws {
        let view = DummyAnnotationView()
        view.actualSize = CGSize(width: 100, height: 100)

        let va = ViewAnnotation(coordinate: .init(latitude: 0, longitude: 0), view: view)
        va.bind(deps)

        let options = try XCTUnwrap(mapboxMap.addViewAnnotationStub.invocations.last).parameters.options
        XCTAssertNil(options.collisionBoxes)
    }

    func testCollisionBoxesSingleSubviewMarked() throws {
        let view = DummyAnnotationView()
        view.actualSize = CGSize(width: 100, height: 100)
        let innerFrame = CGRect(x: 10, y: 10, width: 30, height: 30)
        let inner = UIView()
        inner.frame = innerFrame
        inner.mbxViewAnnotationCollisionBox = true
        view.addSubview(inner)

        let va = ViewAnnotation(coordinate: .init(latitude: 0, longitude: 0), view: view)
        va.bind(deps)

        let options = try XCTUnwrap(mapboxMap.addViewAnnotationStub.invocations.last).parameters.options
        XCTAssertEqual(options.collisionBoxes, [innerFrame])
    }

    func testCollisionBoxesTwoSubviewsMarked() throws {
        let view = DummyAnnotationView()
        view.actualSize = CGSize(width: 100, height: 100)
        let frame1 = CGRect(x: 0, y: 0, width: 40, height: 40)
        let inner1 = UIView()
        inner1.frame = frame1
        inner1.mbxViewAnnotationCollisionBox = true
        view.addSubview(inner1)
        let frame2 = CGRect(x: 60, y: 60, width: 40, height: 40)
        let inner2 = UIView()
        inner2.frame = frame2
        inner2.mbxViewAnnotationCollisionBox = true
        view.addSubview(inner2)

        let va = ViewAnnotation(coordinate: .init(latitude: 0, longitude: 0), view: view)
        va.bind(deps)

        let options = try XCTUnwrap(mapboxMap.addViewAnnotationStub.invocations.last).parameters.options
        XCTAssertEqual(options.collisionBoxes, [frame1, frame2])
    }

    func testCollisionBoxesRootViewMarked() throws {
        let view = DummyAnnotationView()
        view.actualSize = CGSize(width: 100, height: 100)
        view.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        view.mbxViewAnnotationCollisionBox = true

        let va = ViewAnnotation(coordinate: .init(latitude: 0, longitude: 0), view: view)
        va.bind(deps)

        let options = try XCTUnwrap(mapboxMap.addViewAnnotationStub.invocations.last).parameters.options
        XCTAssertEqual(options.collisionBoxes, [view.bounds])
    }

    func testCollisionBoxesOverrideTakesPrecedence() throws {
        let view = DummyAnnotationView()
        view.actualSize = CGSize(width: 100, height: 100)
        let inner = UIView()
        inner.frame = CGRect(x: 5, y: 5, width: 20, height: 20)
        inner.mbxViewAnnotationCollisionBox = true
        view.addSubview(inner)
        let overrideBoxes = [CGRect(x: 10, y: 20, width: 30, height: 40), CGRect(x: 50, y: 60, width: 10, height: 10)]
        view.overrideCollisionBoxes = overrideBoxes

        let va = ViewAnnotation(coordinate: .init(latitude: 0, longitude: 0), view: view)
        va.bind(deps)

        let options = try XCTUnwrap(mapboxMap.addViewAnnotationStub.invocations.last).parameters.options
        XCTAssertEqual(options.collisionBoxes, overrideBoxes)
    }

    func testCollisionBoxesOverrideEmpty() throws {
        let view = DummyAnnotationView()
        view.actualSize = CGSize(width: 100, height: 100)
        view.overrideCollisionBoxes = []

        let va = ViewAnnotation(coordinate: .init(latitude: 0, longitude: 0), view: view)
        va.bind(deps)

        let options = try XCTUnwrap(mapboxMap.addViewAnnotationStub.invocations.last).parameters.options
        XCTAssertNil(options.collisionBoxes)
    }

    func testCollisionBoxesUpdatedOnSetNeedsUpdateSize() throws {
        let view = DummyAnnotationView()
        view.actualSize = CGSize(width: 100, height: 100)
        let va = ViewAnnotation(coordinate: .init(latitude: 0, longitude: 0), view: view)
        va.bind(deps)

        XCTAssertNil(mapboxMap.addViewAnnotationStub.invocations.last?.parameters.options.collisionBoxes)

        let newFrame = CGRect(x: 5, y: 5, width: 20, height: 20)
        let newBox = UIView()
        newBox.frame = newFrame
        newBox.mbxViewAnnotationCollisionBox = true
        view.addSubview(newBox)

        va.setNeedsUpdateSize()
        $displayLink.send()

        let updOptions = try XCTUnwrap(mapboxMap.updateViewAnnotationStub.invocations.last).parameters.options
        XCTAssertEqual(updOptions.collisionBoxes, [newFrame])
    }

    // MARK: - enableSymbolLayerCollision

    func testEnableSymbolLayerCollisionDefaultFalse() {
        let view = DummyAnnotationView()
        view.actualSize = CGSize(width: 100, height: 100)
        let va = ViewAnnotation(coordinate: .init(latitude: 0, longitude: 0), view: view)

        XCTAssertEqual(va.enableSymbolLayerCollision, false)
    }

    func testEnableSymbolLayerCollisionSetBeforeBind() throws {
        let view = DummyAnnotationView()
        view.actualSize = CGSize(width: 100, height: 100)
        let va = ViewAnnotation(coordinate: .init(latitude: 0, longitude: 0), view: view)
        va.enableSymbolLayerCollision = true

        va.bind(deps)

        let options = try XCTUnwrap(mapboxMap.addViewAnnotationStub.invocations.last).parameters.options
        XCTAssertEqual(options.enableSymbolLayerCollision, true)
    }

    func testEnableSymbolLayerCollisionSetAfterBind() throws {
        let view = DummyAnnotationView()
        view.actualSize = CGSize(width: 100, height: 100)
        let va = ViewAnnotation(coordinate: .init(latitude: 0, longitude: 0), view: view)
        va.bind(deps)

        va.enableSymbolLayerCollision = true
        XCTAssertEqual(mapboxMap.updateViewAnnotationStub.invocations.count, 0)

        $displayLink.send()

        let updParams = try XCTUnwrap(mapboxMap.updateViewAnnotationStub.invocations.last).parameters
        XCTAssertEqual(updParams.options.enableSymbolLayerCollision, true)
    }

    func testEnableSymbolLayerCollisionNoUpdateWhenUnchanged() throws {
        let view = DummyAnnotationView()
        view.actualSize = CGSize(width: 100, height: 100)
        let va = ViewAnnotation(coordinate: .init(latitude: 0, longitude: 0), view: view)
        va.enableSymbolLayerCollision = true
        va.bind(deps)

        va.enableSymbolLayerCollision = true // no change
        $displayLink.send()

        XCTAssertEqual(mapboxMap.updateViewAnnotationStub.invocations.count, 0)
    }

    // MARK: - Drag

    func testIsDraggableAddsAndRemovesGestureRecognizer() throws {
        let view = DummyAnnotationView()
        view.actualSize = CGSize(width: 100, height: 100)
        let va = ViewAnnotation(coordinate: .init(latitude: 0, longitude: 0), view: view)

        XCTAssertEqual(va.isDraggable, false) // false by default
        XCTAssertEqual(view.gestureRecognizers?.count ?? 0, 0)

        va.isDraggable = true

        XCTAssertEqual(view.gestureRecognizers?.count, 1)
        let recognizer = try XCTUnwrap(view.gestureRecognizers?.first as? UILongPressGestureRecognizer)
        XCTAssertEqual(recognizer.minimumPressDuration, 0.3)
        XCTAssertEqual(recognizer.allowableMovement, .greatestFiniteMagnitude)

        va.isDraggable = false

        XCTAssertEqual(view.gestureRecognizers?.count ?? 0, 0)
    }

    func testIsDraggableSettingSameValueDoesNotDuplicateRecognizer() {
        let view = DummyAnnotationView()
        view.actualSize = CGSize(width: 100, height: 100)
        let va = ViewAnnotation(coordinate: .init(latitude: 0, longitude: 0), view: view)
        va.isDraggable = true

        XCTAssertEqual(view.gestureRecognizers?.count, 1)

        va.isDraggable = true

        XCTAssertEqual(view.gestureRecognizers?.count, 1)
    }

    func testDragBeganChangedEndedUpdatesCoordinateAndFiresCallbacks() throws {
        let view = DummyAnnotationView()
        view.actualSize = CGSize(width: 100, height: 100)
        let va = ViewAnnotation(coordinate: .init(latitude: 1, longitude: 2), view: view)
        va.bind(deps)

        var draggingChanges = [Bool]()
        var draggedCoordinates = [CLLocationCoordinate2D]()
        va.onDraggingChanged = { draggingChanges.append($0) }
        va.onDragCoordinateChanged = { draggedCoordinates.append($0) }

        let recognizer = MockLongPressGestureRecognizer()

        XCTAssertFalse(va.isDragging)

        recognizer.getStateStub.defaultReturnValue = .began
        recognizer.locationStub.defaultReturnValue = CGPoint(x: 100, y: 100)
        va.handleDragGesture(recognizer)

        XCTAssertEqual(draggingChanges, [true])
        XCTAssertTrue(va.isDragging)

        let newCoordinate = CLLocationCoordinate2D(latitude: 3, longitude: 4)
        mapboxMap.pointStub.defaultReturnValue = CGPoint(x: 100, y: 100)
        mapboxMap.coordinateForPointStub.defaultReturnValue = newCoordinate
        recognizer.getStateStub.defaultReturnValue = .changed
        recognizer.locationStub.defaultReturnValue = CGPoint(x: 110, y: 105) // moved by (10, 5)
        va.handleDragGesture(recognizer)

        let params = try XCTUnwrap(mapboxMap.coordinateForPointStub.invocations.last).parameters
        XCTAssertEqual(params, CGPoint(x: 110, y: 105))
        XCTAssertEqual(draggedCoordinates, [newCoordinate])
        XCTAssertEqual(va.annotatedFeature, .geometry(Point(newCoordinate))) // dragCommitsGeometry defaults to true

        recognizer.getStateStub.defaultReturnValue = .ended
        va.handleDragGesture(recognizer)

        XCTAssertEqual(draggingChanges, [true, false])
        XCTAssertFalse(va.isDragging)
    }

    // Guards against computing the drag delta from the gesture's start instead of the previous frame.
    func testDragChangedUsesDeltaSinceLastFrame() throws {
        let view = DummyAnnotationView()
        view.actualSize = CGSize(width: 100, height: 100)
        let va = ViewAnnotation(coordinate: .init(latitude: 0, longitude: 0), view: view)
        va.bind(deps)

        let recognizer = MockLongPressGestureRecognizer()
        recognizer.getStateStub.defaultReturnValue = .began
        recognizer.locationStub.defaultReturnValue = CGPoint(x: 0, y: 0)
        va.handleDragGesture(recognizer)

        recognizer.getStateStub.defaultReturnValue = .changed
        mapboxMap.pointStub.returnValueQueue = [CGPoint(x: 0, y: 0), CGPoint(x: 50, y: 50)]
        mapboxMap.coordinateForPointStub.returnValueQueue = [
            CLLocationCoordinate2D(latitude: 1, longitude: 1),
            CLLocationCoordinate2D(latitude: 2, longitude: 2)
        ]

        recognizer.locationStub.defaultReturnValue = CGPoint(x: 10, y: 10)
        va.handleDragGesture(recognizer)
        let frame1 = try XCTUnwrap(mapboxMap.coordinateForPointStub.invocations.first).parameters
        XCTAssertEqual(frame1, CGPoint(x: 10, y: 10)) // point(0, 0) + delta(10, 10)

        recognizer.locationStub.defaultReturnValue = CGPoint(x: 15, y: 30)
        va.handleDragGesture(recognizer)
        let frame2 = try XCTUnwrap(mapboxMap.coordinateForPointStub.invocations.last).parameters
        XCTAssertEqual(frame2, CGPoint(x: 55, y: 70)) // point(50, 50) + delta(5, 20), not delta(15, 30) since .began
    }

    func testDragChangedWithDragCommitsGeometryFalseOnlyCallsBack() {
        let view = DummyAnnotationView()
        view.actualSize = CGSize(width: 100, height: 100)
        let coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        let va = ViewAnnotation(coordinate: coordinate, view: view)
        va.dragCommitsGeometry = false
        va.bind(deps)

        var draggedCoordinates = [CLLocationCoordinate2D]()
        va.onDragCoordinateChanged = { draggedCoordinates.append($0) }

        let recognizer = MockLongPressGestureRecognizer()
        recognizer.getStateStub.defaultReturnValue = .began
        recognizer.locationStub.defaultReturnValue = .zero
        va.handleDragGesture(recognizer)

        let newCoordinate = CLLocationCoordinate2D(latitude: 5, longitude: 6)
        mapboxMap.coordinateForPointStub.defaultReturnValue = newCoordinate
        recognizer.getStateStub.defaultReturnValue = .changed
        recognizer.locationStub.defaultReturnValue = CGPoint(x: 10, y: 10)
        va.handleDragGesture(recognizer)

        XCTAssertEqual(draggedCoordinates, [newCoordinate])
        XCTAssertEqual(va.annotatedFeature, .geometry(Point(coordinate))) // unchanged, consumer's Binding owns it
    }

    func testDragBeganOnLayerFeatureIsNoOp() {
        let view = DummyAnnotationView()
        view.actualSize = CGSize(width: 100, height: 100)
        let va = ViewAnnotation(annotatedFeature: .layerFeature(layerId: "foo", featureId: "bar"), view: view)
        va.bind(deps)

        var draggingChanges = [Bool]()
        va.onDraggingChanged = { draggingChanges.append($0) }

        let recognizer = MockLongPressGestureRecognizer()
        recognizer.getStateStub.defaultReturnValue = .began
        va.handleDragGesture(recognizer)

        XCTAssertTrue(draggingChanges.isEmpty)

        // The gesture still reaches .ended - it must not fire a spurious onDraggingChanged(false).
        recognizer.getStateStub.defaultReturnValue = .ended
        va.handleDragGesture(recognizer)

        XCTAssertTrue(draggingChanges.isEmpty)
    }

    // The teardown callback may re-enter the annotation (e.g. remove it) - it must not double-fire.
    func testRemoveInsideOnDraggingChangedDoesNotDoubleFire() {
        let view = DummyAnnotationView()
        view.actualSize = CGSize(width: 100, height: 100)
        let va = ViewAnnotation(coordinate: .init(latitude: 0, longitude: 0), view: view)
        va.isDraggable = true
        va.bind(deps)

        var draggingChanges = [Bool]()
        va.onDraggingChanged = { [weak va] isDragging in
            draggingChanges.append(isDragging)
            if !isDragging { va?.remove() }
        }

        let recognizer = MockLongPressGestureRecognizer()
        recognizer.getStateStub.defaultReturnValue = .began
        recognizer.locationStub.defaultReturnValue = .zero
        va.handleDragGesture(recognizer)
        XCTAssertEqual(draggingChanges, [true])

        va.isDraggable = false

        XCTAssertEqual(draggingChanges, [true, false])
    }

    func testRemoveMidDragFiresOnDraggingChangedFalse() {
        let view = DummyAnnotationView()
        view.actualSize = CGSize(width: 100, height: 100)
        let va = ViewAnnotation(coordinate: .init(latitude: 0, longitude: 0), view: view)
        va.bind(deps)

        var draggingChanges = [Bool]()
        let onFalse = expectation(description: "onDraggingChanged(false) after remove() mid-drag")
        va.onDraggingChanged = { isDragging in
            draggingChanges.append(isDragging)
            if isDragging == false { onFalse.fulfill() }
        }

        let recognizer = MockLongPressGestureRecognizer()
        recognizer.getStateStub.defaultReturnValue = .began
        recognizer.locationStub.defaultReturnValue = .zero
        va.handleDragGesture(recognizer)
        XCTAssertEqual(draggingChanges, [true])

        va.remove()

        wait(for: [onFalse], timeout: 1)
        XCTAssertEqual(draggingChanges, [true, false])
    }

    func testIsDraggableFalseMidDragFiresOnDraggingChangedFalse() {
        let view = DummyAnnotationView()
        view.actualSize = CGSize(width: 100, height: 100)
        let va = ViewAnnotation(coordinate: .init(latitude: 0, longitude: 0), view: view)
        va.isDraggable = true
        va.bind(deps)

        var draggingChanges = [Bool]()
        let onFalse = expectation(description: "onDraggingChanged(false) after isDraggable = false mid-drag")
        va.onDraggingChanged = { isDragging in
            draggingChanges.append(isDragging)
            if isDragging == false { onFalse.fulfill() }
        }

        let recognizer = MockLongPressGestureRecognizer()
        recognizer.getStateStub.defaultReturnValue = .began
        recognizer.locationStub.defaultReturnValue = .zero
        va.handleDragGesture(recognizer)
        XCTAssertEqual(draggingChanges, [true])

        va.isDraggable = false

        wait(for: [onFalse], timeout: 1)
        XCTAssertEqual(draggingChanges, [true, false])
    }
}

class DummyAnnotationView: UIView {
    var actualSize: CGSize = .zero
    var providedAvailableSize: CGSize?

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        providedAvailableSize = size
        return actualSize
    }
}
