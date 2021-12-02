import XCTest
@_spi(Experimental) @testable import MapboxMaps

final class GestureManagerTests: XCTestCase {

    var mapboxMap: MockMapboxMap!
    var cameraAnimationsManager: MockCameraAnimationsManager!
    var panGestureHandler: MockPanGestureHandler!
    var pinchGestureHandler: MockPinchGestureHandler!
    var pitchGestureHandler: GestureHandler!
    var doubleTapToZoomInGestureHandler: GestureHandler!
    var doubleTouchToZoomOutGestureHandler: GestureHandler!
    var quickZoomGestureHandler: GestureHandler!
    var singleTapGestureHandler: GestureHandler!
    var animationLockoutGestureHandler: GestureHandler!
    var gestureManager: GestureManager!
    // swiftlint:disable:next weak_delegate
    var delegate: MockGestureManagerDelegate!

    override func setUp() {
        super.setUp()
        mapboxMap = MockMapboxMap()
        cameraAnimationsManager = MockCameraAnimationsManager()
        panGestureHandler = MockPanGestureHandler(
            gestureRecognizer: MockGestureRecognizer())
        pinchGestureHandler = MockPinchGestureHandler(
            gestureRecognizer: MockGestureRecognizer())
        pitchGestureHandler = makeGestureHandler()
        doubleTapToZoomInGestureHandler = makeGestureHandler()
        doubleTouchToZoomOutGestureHandler = makeGestureHandler()
        quickZoomGestureHandler = makeGestureHandler()
        singleTapGestureHandler = makeGestureHandler()
        animationLockoutGestureHandler = makeGestureHandler()
        gestureManager = GestureManager(
            panGestureHandler: panGestureHandler,
            pinchGestureHandler: pinchGestureHandler,
            pitchGestureHandler: pitchGestureHandler,
            doubleTapToZoomInGestureHandler: doubleTapToZoomInGestureHandler,
            doubleTouchToZoomOutGestureHandler: doubleTouchToZoomOutGestureHandler,
            quickZoomGestureHandler: quickZoomGestureHandler,
            singleTapGestureHandler: singleTapGestureHandler,
            animationLockoutGestureHandler: animationLockoutGestureHandler,
            mapboxMap: mapboxMap)
        delegate = MockGestureManagerDelegate()
        gestureManager.delegate = delegate
    }

    override func tearDown() {
        delegate = nil
        gestureManager = nil
        animationLockoutGestureHandler = nil
        singleTapGestureHandler = nil
        quickZoomGestureHandler = nil
        doubleTouchToZoomOutGestureHandler = nil
        doubleTapToZoomInGestureHandler = nil
        pitchGestureHandler = nil
        pinchGestureHandler = nil
        panGestureHandler = nil
        cameraAnimationsManager = nil
        mapboxMap = nil
        super.tearDown()
    }

    func makeGestureHandler() -> GestureHandler {
        return GestureHandler(gestureRecognizer: MockGestureRecognizer())
    }

    func testPanGestureRecognizer() {
        XCTAssertTrue(gestureManager.panGestureRecognizer === panGestureHandler.gestureRecognizer)
    }

    func testPinchGestureRecognizer() {
        XCTAssertTrue(gestureManager.pinchGestureRecognizer === pinchGestureHandler.gestureRecognizer)
    }

    func testPitchGestureRecognizer() {
        XCTAssertTrue(gestureManager.pitchGestureRecognizer === pitchGestureHandler.gestureRecognizer)
    }

    func testSingleTapGestureRecognizer() {
        XCTAssertTrue(gestureManager.singleTapGestureRecognizer === singleTapGestureHandler.gestureRecognizer)
    }

    func testDoubleTapToZoomInGestureRecognizer() {
        XCTAssertTrue(gestureManager.doubleTapToZoomInGestureRecognizer
                        === doubleTapToZoomInGestureHandler.gestureRecognizer)
    }

    func testDoubleTouchToZoomOutGestureRecognizer() {
        XCTAssertTrue(gestureManager.doubleTouchToZoomOutGestureRecognizer
                        === doubleTouchToZoomOutGestureHandler.gestureRecognizer)
    }

    func testQuickZoomGestureRecognizer() {
        XCTAssertTrue(gestureManager.quickZoomGestureRecognizer === quickZoomGestureHandler.gestureRecognizer)
    }

    func testPanGestureHandlerDelegate() {
        XCTAssertTrue(panGestureHandler.delegate === gestureManager)
    }

    func testPinchGestureHandlerDelegate() {
        XCTAssertTrue(pinchGestureHandler.delegate === gestureManager)
    }

    func testPitchGestureHandlerDelegate() {
        XCTAssertTrue(pitchGestureHandler.delegate === gestureManager)
    }

    func testDoubleTapToZoomInGestureHandlerDelegate() {
        XCTAssertTrue(doubleTapToZoomInGestureHandler.delegate === gestureManager)
    }

    func testDoubleTouchToZoomOutGestureHandlerDelegate() {
        XCTAssertTrue(doubleTouchToZoomOutGestureHandler.delegate === gestureManager)
    }

    func testSingleTapGestureHandlerDelegate() {
        XCTAssertTrue(singleTapGestureHandler.delegate === gestureManager)
    }

    func testQuickZoomGestureHandlerDelegate() {
        XCTAssertTrue(quickZoomGestureHandler.delegate === gestureManager)
    }

    func testPinchGestureRecognizerRequiresPanGestureRecognizerToFail() throws {
        let pinchGestureRecognizer = try XCTUnwrap(pinchGestureHandler.gestureRecognizer as? MockGestureRecognizer)

        XCTAssertEqual(pinchGestureRecognizer.requireToFailStub.invocations.count, 1)
        XCTAssertTrue(pinchGestureRecognizer.requireToFailStub.parameters.first
                        === panGestureHandler.gestureRecognizer)
    }

    func testPitchGestureRecognizerRequiresPanGestureRecognizerToFail() throws {
        let pitchGestureRecognizer = try XCTUnwrap(pitchGestureHandler.gestureRecognizer as? MockGestureRecognizer)

        XCTAssertEqual(pitchGestureRecognizer.requireToFailStub.invocations.count, 1)
        XCTAssertTrue(pitchGestureRecognizer.requireToFailStub.parameters.first
                        === panGestureHandler.gestureRecognizer)
    }

    func testQuickZoomGestureRecognizerRequiresDoubleTapToZoomInGestureRecognizerToFail() throws {
        let quickZoomGestureRecognizer = try XCTUnwrap(quickZoomGestureHandler.gestureRecognizer as? MockGestureRecognizer)

        XCTAssertEqual(quickZoomGestureRecognizer.requireToFailStub.invocations.count, 1)
        XCTAssertTrue(quickZoomGestureRecognizer.requireToFailStub.parameters.first
                        === doubleTapToZoomInGestureHandler.gestureRecognizer)
    }

    func testGestureBegan() {
        let gestureType = GestureType.allCases.randomElement()!

        gestureManager.gestureBegan(for: gestureType)

        XCTAssertEqual(delegate.gestureDidBeginStub.invocations.count, 1, "GestureBegan should have been invoked once. It was called \(delegate.gestureDidBeginStub.invocations.count) times.")
        XCTAssertTrue(delegate.gestureDidBeginStub.parameters.first?.gestureManager === gestureManager)
        XCTAssertEqual(delegate.gestureDidBeginStub.parameters.first?.gestureType, gestureType)
        XCTAssertEqual(mapboxMap.beginGestureStub.invocations.count, 1)
    }

    func testGestureEnded() throws {
        let gestureType = GestureType.allCases.randomElement()!
        let willAnimate = Bool.random()
        gestureManager.gestureEnded(for: gestureType, willAnimate: willAnimate)

        XCTAssertEqual(delegate.gestureDidEndStub.invocations.count, 1, "GestureEnded should have been invoked once. It was called \(delegate.gestureDidEndStub.invocations.count) times.")
        XCTAssertTrue(delegate.gestureDidEndStub.parameters.first?.gestureManager === gestureManager)
        XCTAssertEqual(delegate.gestureDidEndStub.parameters.first?.gestureType, gestureType)
        let willAnimateValue = try XCTUnwrap(delegate.gestureDidEndStub.parameters.first?.willAnimate)
        XCTAssertEqual(willAnimateValue, willAnimate)
        XCTAssertEqual(mapboxMap.endGestureStub.invocations.count, 1)
    }

    func testAnimationEnded() {
        let gestureType = GestureType.allCases.randomElement()!

        gestureManager.animationEnded(for: gestureType)

        XCTAssertEqual(delegate.gestureDidEndAnimatingStub.invocations.count, 1, "animationEnded should have been invoked once. It was called \(delegate.gestureDidEndAnimatingStub.invocations.count) times.")
        XCTAssertTrue(delegate.gestureDidEndAnimatingStub.parameters.first?.gestureManager === gestureManager)
        XCTAssertEqual(delegate.gestureDidEndAnimatingStub.parameters.first?.gestureType, gestureType)
    }

    func testOptionsPanEnabled() {
        XCTAssertTrue(gestureManager.options.panEnabled)
        XCTAssertTrue(gestureManager.panGestureRecognizer.isEnabled)

        gestureManager.options.panEnabled = false

        XCTAssertFalse(gestureManager.options.panEnabled)
        XCTAssertFalse(gestureManager.panGestureRecognizer.isEnabled)

        gestureManager.options.panEnabled = true

        XCTAssertTrue(gestureManager.options.panEnabled)
        XCTAssertTrue(gestureManager.panGestureRecognizer.isEnabled)

        gestureManager.panGestureRecognizer.isEnabled = false

        XCTAssertFalse(gestureManager.options.panEnabled)
        XCTAssertFalse(gestureManager.panGestureRecognizer.isEnabled)

        gestureManager.panGestureRecognizer.isEnabled = true

        XCTAssertTrue(gestureManager.options.panEnabled)
        XCTAssertTrue(gestureManager.panGestureRecognizer.isEnabled)
    }

    func testOptionsPinchEnabled() {
        XCTAssertTrue(gestureManager.options.pinchEnabled)
        XCTAssertTrue(gestureManager.pinchGestureRecognizer.isEnabled)

        gestureManager.options.pinchEnabled = false

        XCTAssertFalse(gestureManager.options.pinchEnabled)
        XCTAssertFalse(gestureManager.pinchGestureRecognizer.isEnabled)

        gestureManager.options.pinchEnabled = true

        XCTAssertTrue(gestureManager.options.pinchEnabled)
        XCTAssertTrue(gestureManager.pinchGestureRecognizer.isEnabled)

        gestureManager.pinchGestureRecognizer.isEnabled = false

        XCTAssertFalse(gestureManager.options.pinchEnabled)
        XCTAssertFalse(gestureManager.pinchGestureRecognizer.isEnabled)

        gestureManager.pinchGestureRecognizer.isEnabled = true

        XCTAssertTrue(gestureManager.options.pinchEnabled)
        XCTAssertTrue(gestureManager.pinchGestureRecognizer.isEnabled)
    }

    func testOptionsPitchEnabled() {
        XCTAssertTrue(gestureManager.options.pitchEnabled)
        XCTAssertTrue(gestureManager.pitchGestureRecognizer.isEnabled)

        gestureManager.options.pitchEnabled = false

        XCTAssertFalse(gestureManager.options.pitchEnabled)
        XCTAssertFalse(gestureManager.pitchGestureRecognizer.isEnabled)

        gestureManager.options.pitchEnabled = true

        XCTAssertTrue(gestureManager.options.pitchEnabled)
        XCTAssertTrue(gestureManager.pitchGestureRecognizer.isEnabled)

        gestureManager.pitchGestureRecognizer.isEnabled = false

        XCTAssertFalse(gestureManager.options.pitchEnabled)
        XCTAssertFalse(gestureManager.pitchGestureRecognizer.isEnabled)

        gestureManager.pitchGestureRecognizer.isEnabled = true

        XCTAssertTrue(gestureManager.options.pitchEnabled)
        XCTAssertTrue(gestureManager.pitchGestureRecognizer.isEnabled)
    }

    func testOptionsDoubleTapToZoomInEnabled() {
        XCTAssertTrue(gestureManager.options.doubleTapToZoomInEnabled)
        XCTAssertTrue(gestureManager.doubleTapToZoomInGestureRecognizer.isEnabled)

        gestureManager.options.doubleTapToZoomInEnabled = false

        XCTAssertFalse(gestureManager.options.doubleTapToZoomInEnabled)
        XCTAssertFalse(gestureManager.doubleTapToZoomInGestureRecognizer.isEnabled)

        gestureManager.options.doubleTapToZoomInEnabled = true

        XCTAssertTrue(gestureManager.options.doubleTapToZoomInEnabled)
        XCTAssertTrue(gestureManager.doubleTapToZoomInGestureRecognizer.isEnabled)

        gestureManager.doubleTapToZoomInGestureRecognizer.isEnabled = false

        XCTAssertFalse(gestureManager.options.doubleTapToZoomInEnabled)
        XCTAssertFalse(gestureManager.doubleTapToZoomInGestureRecognizer.isEnabled)

        gestureManager.doubleTapToZoomInGestureRecognizer.isEnabled = true

        XCTAssertTrue(gestureManager.options.doubleTapToZoomInEnabled)
        XCTAssertTrue(gestureManager.doubleTapToZoomInGestureRecognizer.isEnabled)
    }

    func testOptionsDoubleTouchToZoomOutEnabled() {
        XCTAssertTrue(gestureManager.options.doubleTouchToZoomOutEnabled)
        XCTAssertTrue(gestureManager.doubleTouchToZoomOutGestureRecognizer.isEnabled)

        gestureManager.options.doubleTouchToZoomOutEnabled = false

        XCTAssertFalse(gestureManager.options.doubleTouchToZoomOutEnabled)
        XCTAssertFalse(gestureManager.doubleTouchToZoomOutGestureRecognizer.isEnabled)

        gestureManager.options.doubleTouchToZoomOutEnabled = true

        XCTAssertTrue(gestureManager.options.doubleTouchToZoomOutEnabled)
        XCTAssertTrue(gestureManager.doubleTouchToZoomOutGestureRecognizer.isEnabled)

        gestureManager.doubleTouchToZoomOutGestureRecognizer.isEnabled = false

        XCTAssertFalse(gestureManager.options.doubleTouchToZoomOutEnabled)
        XCTAssertFalse(gestureManager.doubleTouchToZoomOutGestureRecognizer.isEnabled)

        gestureManager.doubleTouchToZoomOutGestureRecognizer.isEnabled = true

        XCTAssertTrue(gestureManager.options.doubleTouchToZoomOutEnabled)
        XCTAssertTrue(gestureManager.doubleTouchToZoomOutGestureRecognizer.isEnabled)
    }

    func testOptionsQuickZoomEnabled() {
        XCTAssertTrue(gestureManager.options.quickZoomEnabled)
        XCTAssertTrue(gestureManager.quickZoomGestureRecognizer.isEnabled)

        gestureManager.options.quickZoomEnabled = false

        XCTAssertFalse(gestureManager.options.quickZoomEnabled)
        XCTAssertFalse(gestureManager.quickZoomGestureRecognizer.isEnabled)

        gestureManager.options.quickZoomEnabled = true

        XCTAssertTrue(gestureManager.options.quickZoomEnabled)
        XCTAssertTrue(gestureManager.quickZoomGestureRecognizer.isEnabled)

        gestureManager.quickZoomGestureRecognizer.isEnabled = false

        XCTAssertFalse(gestureManager.options.quickZoomEnabled)
        XCTAssertFalse(gestureManager.quickZoomGestureRecognizer.isEnabled)

        gestureManager.quickZoomGestureRecognizer.isEnabled = true

        XCTAssertTrue(gestureManager.options.quickZoomEnabled)
        XCTAssertTrue(gestureManager.quickZoomGestureRecognizer.isEnabled)
    }

    func testPanDecelerationFactor() {
        XCTAssertEqual(gestureManager.options.panDecelerationFactor, UIScrollView.DecelerationRate.normal.rawValue)
        XCTAssertEqual(panGestureHandler.decelerationFactor, UIScrollView.DecelerationRate.normal.rawValue)

        gestureManager.options.panDecelerationFactor = UIScrollView.DecelerationRate.fast.rawValue

        XCTAssertEqual(gestureManager.options.panDecelerationFactor, UIScrollView.DecelerationRate.fast.rawValue)
        XCTAssertEqual(panGestureHandler.decelerationFactor, UIScrollView.DecelerationRate.fast.rawValue)

        gestureManager.options.panDecelerationFactor = UIScrollView.DecelerationRate.normal.rawValue

        XCTAssertEqual(gestureManager.options.panDecelerationFactor, UIScrollView.DecelerationRate.normal.rawValue)
        XCTAssertEqual(panGestureHandler.decelerationFactor, UIScrollView.DecelerationRate.normal.rawValue)

        panGestureHandler.decelerationFactor = UIScrollView.DecelerationRate.fast.rawValue

        XCTAssertEqual(gestureManager.options.panDecelerationFactor, UIScrollView.DecelerationRate.fast.rawValue)
        XCTAssertEqual(panGestureHandler.decelerationFactor, UIScrollView.DecelerationRate.fast.rawValue)

        panGestureHandler.decelerationFactor = UIScrollView.DecelerationRate.normal.rawValue

        XCTAssertEqual(gestureManager.options.panDecelerationFactor, UIScrollView.DecelerationRate.normal.rawValue)
        XCTAssertEqual(panGestureHandler.decelerationFactor, UIScrollView.DecelerationRate.normal.rawValue)
    }

    func testPanMode() {
        XCTAssertEqual(gestureManager.options.panMode, .horizontalAndVertical)
        XCTAssertEqual(panGestureHandler.panMode, .horizontalAndVertical)

        gestureManager.options.panMode = .horizontal

        XCTAssertEqual(gestureManager.options.panMode, .horizontal)
        XCTAssertEqual(panGestureHandler.panMode, .horizontal)

        gestureManager.options.panMode = .vertical

        XCTAssertEqual(gestureManager.options.panMode, .vertical)
        XCTAssertEqual(panGestureHandler.panMode, .vertical)

        panGestureHandler.panMode = .horizontalAndVertical

        XCTAssertEqual(gestureManager.options.panMode, .horizontalAndVertical)
        XCTAssertEqual(panGestureHandler.panMode, .horizontalAndVertical)

        panGestureHandler.panMode = [.horizontal, .vertical].randomElement()!

        XCTAssertEqual(gestureManager.options.panMode, panGestureHandler.panMode)
    }

    func testPinchRotateEnabled() {
        XCTAssertEqual(gestureManager.options.pinchRotateEnabled, true)
        XCTAssertEqual(pinchGestureHandler.rotateEnabled, true)

        gestureManager.options.pinchRotateEnabled = false

        XCTAssertEqual(gestureManager.options.pinchRotateEnabled, false)
        XCTAssertEqual(pinchGestureHandler.rotateEnabled, false)

        gestureManager.options.pinchRotateEnabled = true

        XCTAssertEqual(gestureManager.options.pinchRotateEnabled, true)
        XCTAssertEqual(pinchGestureHandler.rotateEnabled, true)

        pinchGestureHandler.rotateEnabled = false

        XCTAssertEqual(gestureManager.options.pinchRotateEnabled, pinchGestureHandler.rotateEnabled)

        pinchGestureHandler.rotateEnabled = true

        XCTAssertEqual(gestureManager.options.pinchRotateEnabled, pinchGestureHandler.rotateEnabled)
    }

    func testPinchBehavior() {
        XCTAssertEqual(gestureManager.options.pinchBehavior, .tracksTouchLocationsWhenPanningAfterZoomChange)
        XCTAssertEqual(pinchGestureHandler.behavior, .tracksTouchLocationsWhenPanningAfterZoomChange)

        gestureManager.options.pinchBehavior = .doesNotResetCameraAtEachFrame

        XCTAssertEqual(gestureManager.options.pinchBehavior, .doesNotResetCameraAtEachFrame)
        XCTAssertEqual(pinchGestureHandler.behavior, .doesNotResetCameraAtEachFrame)

        gestureManager.options.pinchBehavior = .tracksTouchLocationsWhenPanningAfterZoomChange

        XCTAssertEqual(gestureManager.options.pinchBehavior, .tracksTouchLocationsWhenPanningAfterZoomChange)
        XCTAssertEqual(pinchGestureHandler.behavior, .tracksTouchLocationsWhenPanningAfterZoomChange)

        pinchGestureHandler.behavior = .doesNotResetCameraAtEachFrame

        XCTAssertEqual(gestureManager.options.pinchBehavior, pinchGestureHandler.behavior)

        pinchGestureHandler.behavior = .tracksTouchLocationsWhenPanningAfterZoomChange

        XCTAssertEqual(gestureManager.options.pinchBehavior, pinchGestureHandler.behavior)
    }
}
