import XCTest
@testable import MapboxMaps

final class GestureManagerTests: XCTestCase {

    var mapboxMap: MockMapboxMap!
    var cameraAnimationsManager: MockCameraAnimationsManager!
    var panGestureHandler: MockPanGestureHandler!
    var pinchGestureHandler: GestureHandler!
    var pitchGestureHandler: GestureHandler!
    var doubleTapToZoomInGestureHandler: GestureHandler!
    var doubleTapToZoomOutGestureHandler: GestureHandler!
    var quickZoomGestureHandler: GestureHandler!
    var gestureManager: GestureManager!
    // swiftlint:disable:next weak_delegate
    var delegate: MockGestureManagerDelegate!

    override func setUp() {
        super.setUp()
        mapboxMap = MockMapboxMap()
        cameraAnimationsManager = MockCameraAnimationsManager()
        panGestureHandler = MockPanGestureHandler(
            gestureRecognizer: MockGestureRecognizer(),
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
        pinchGestureHandler = makeGestureHandler()
        pitchGestureHandler = makeGestureHandler()
        doubleTapToZoomInGestureHandler = makeGestureHandler()
        doubleTapToZoomOutGestureHandler = makeGestureHandler()
        quickZoomGestureHandler = makeGestureHandler()
        gestureManager = GestureManager(
            panGestureHandler: panGestureHandler,
            pinchGestureHandler: pinchGestureHandler,
            pitchGestureHandler: pitchGestureHandler,
            doubleTapToZoomInGestureHandler: doubleTapToZoomInGestureHandler,
            doubleTapToZoomOutGestureHandler: doubleTapToZoomOutGestureHandler,
            quickZoomGestureHandler: quickZoomGestureHandler)
        delegate =  MockGestureManagerDelegate()
        gestureManager.delegate = delegate
    }

    override func tearDown() {
        delegate = nil
        gestureManager = nil
        quickZoomGestureHandler = nil
        doubleTapToZoomOutGestureHandler = nil
        doubleTapToZoomInGestureHandler = nil
        pitchGestureHandler = nil
        pinchGestureHandler = nil
        panGestureHandler = nil
        cameraAnimationsManager = nil
        mapboxMap = nil
        super.tearDown()
    }

    func makeGestureHandler() -> GestureHandler {
        return GestureHandler(
            gestureRecognizer: MockGestureRecognizer(),
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
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

    func testDoubleTapToZoomInGestureRecognizer() {
        XCTAssertTrue(gestureManager.doubleTapToZoomInGestureRecognizer
                        === doubleTapToZoomInGestureHandler.gestureRecognizer)
    }

    func testDoubleTapToZoomOutGestureRecognizer() {
        XCTAssertTrue(gestureManager.doubleTapToZoomOutGestureRecognizer
                        === doubleTapToZoomOutGestureHandler.gestureRecognizer)
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

    func testDoubleTapToZoomOutGestureHandlerDelegate() {
        XCTAssertTrue(doubleTapToZoomOutGestureHandler.delegate === gestureManager)
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

        XCTAssertEqual(delegate.gestureBeganStub.parameters, [gestureType])
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

    func testOptionsDoubleTapToZoomOutEnabled() {
        XCTAssertTrue(gestureManager.options.doubleTapToZoomOutEnabled)
        XCTAssertTrue(gestureManager.doubleTapToZoomOutGestureRecognizer.isEnabled)

        gestureManager.options.doubleTapToZoomOutEnabled = false

        XCTAssertFalse(gestureManager.options.doubleTapToZoomOutEnabled)
        XCTAssertFalse(gestureManager.doubleTapToZoomOutGestureRecognizer.isEnabled)

        gestureManager.options.doubleTapToZoomOutEnabled = true

        XCTAssertTrue(gestureManager.options.doubleTapToZoomOutEnabled)
        XCTAssertTrue(gestureManager.doubleTapToZoomOutGestureRecognizer.isEnabled)

        gestureManager.doubleTapToZoomOutGestureRecognizer.isEnabled = false

        XCTAssertFalse(gestureManager.options.doubleTapToZoomOutEnabled)
        XCTAssertFalse(gestureManager.doubleTapToZoomOutGestureRecognizer.isEnabled)

        gestureManager.doubleTapToZoomOutGestureRecognizer.isEnabled = true

        XCTAssertTrue(gestureManager.options.doubleTapToZoomOutEnabled)
        XCTAssertTrue(gestureManager.doubleTapToZoomOutGestureRecognizer.isEnabled)
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
}
