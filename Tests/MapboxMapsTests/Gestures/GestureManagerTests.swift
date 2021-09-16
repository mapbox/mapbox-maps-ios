import XCTest
@testable import MapboxMaps

final class GestureManagerTests: XCTestCase {

    var mapboxMap: MockMapboxMap!
    var cameraAnimationsManager: MockCameraAnimationsManager!
    var decelerationRate: CGFloat!
    var panScrollingMode: PanScrollingMode!
    var panGestureHandler: GestureHandler!
    var pinchGestureHandler: GestureHandler!
    var rotationGestureHandler: GestureHandler!
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
        decelerationRate = .random(in: 0.99...0.999)
        panScrollingMode = .allCases.randomElement()
        panGestureHandler = makeGestureHandler()
        pinchGestureHandler = makeGestureHandler()
        rotationGestureHandler = makeGestureHandler()
        pitchGestureHandler = makeGestureHandler()
        doubleTapToZoomInGestureHandler = makeGestureHandler()
        doubleTapToZoomOutGestureHandler = makeGestureHandler()
        quickZoomGestureHandler = makeGestureHandler()
        gestureManager = GestureManager(
            decelerationRate: decelerationRate,
            panScrollingMode: panScrollingMode,
            panGestureHandler: panGestureHandler,
            pinchGestureHandler: pinchGestureHandler,
            rotationGestureHandler: rotationGestureHandler,
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
        rotationGestureHandler = nil
        pinchGestureHandler = nil
        panGestureHandler = nil
        panScrollingMode = nil
        decelerationRate = nil
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

    func testDecelerationRate() {
        XCTAssertEqual(gestureManager.decelerationRate, decelerationRate)
        XCTAssertEqual(gestureManager.options.decelerationRate, decelerationRate)

        gestureManager.options.decelerationRate = .random(in: 0..<1)

        XCTAssertEqual(gestureManager.decelerationRate, gestureManager.options.decelerationRate)
    }

    func testPanScrollingMode() {
        XCTAssertEqual(gestureManager.panScrollingMode, panScrollingMode)
        XCTAssertEqual(gestureManager.options.scrollingMode, panScrollingMode)

        gestureManager.options.scrollingMode = .allCases.randomElement()!

        XCTAssertEqual(gestureManager.panScrollingMode, gestureManager.options.scrollingMode)
    }

    func testPanGestureRecognizer() {
        XCTAssertTrue(gestureManager.panGestureRecognizer === panGestureHandler.gestureRecognizer)
    }

    func testPinchGestureRecognizer() {
        XCTAssertTrue(gestureManager.pinchGestureRecognizer === pinchGestureHandler.gestureRecognizer)
    }

    func testRotationGestureRecognizer() {
        XCTAssertTrue(gestureManager.rotationGestureRecognizer === rotationGestureHandler.gestureRecognizer)
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

    func testRotationGestureHandlerDelegate() {
        XCTAssertTrue(rotationGestureHandler.delegate === gestureManager)
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

    func testOptionsRotateEnabled() {
        XCTAssertTrue(gestureManager.options.rotateEnabled)
        XCTAssertTrue(gestureManager.rotationGestureRecognizer.isEnabled)

        gestureManager.options.rotateEnabled = false

        XCTAssertFalse(gestureManager.options.rotateEnabled)
        XCTAssertFalse(gestureManager.rotationGestureRecognizer.isEnabled)

        gestureManager.options.rotateEnabled = true

        XCTAssertTrue(gestureManager.options.rotateEnabled)
        XCTAssertTrue(gestureManager.rotationGestureRecognizer.isEnabled)

        gestureManager.rotationGestureRecognizer.isEnabled = false

        XCTAssertFalse(gestureManager.options.rotateEnabled)
        XCTAssertFalse(gestureManager.rotationGestureRecognizer.isEnabled)

        gestureManager.rotationGestureRecognizer.isEnabled = true

        XCTAssertTrue(gestureManager.options.rotateEnabled)
        XCTAssertTrue(gestureManager.rotationGestureRecognizer.isEnabled)
    }

    func testOptionsScrollEnabled() {
        let scrollingGestureRecognizers: [UIGestureRecognizer] = [
            gestureManager.panGestureRecognizer,
            gestureManager.pinchGestureRecognizer]

        XCTAssertTrue(gestureManager.options.scrollEnabled)
        XCTAssertTrue(scrollingGestureRecognizers.allSatisfy { $0.isEnabled })

        gestureManager.options.scrollEnabled = false

        XCTAssertFalse(gestureManager.options.scrollEnabled)
        XCTAssertTrue(scrollingGestureRecognizers.allSatisfy { !$0.isEnabled })

        gestureManager.options.scrollEnabled = true

        XCTAssertTrue(gestureManager.options.scrollEnabled)
        XCTAssertTrue(scrollingGestureRecognizers.allSatisfy { $0.isEnabled })

        let recognizer = scrollingGestureRecognizers.randomElement()!
        recognizer.isEnabled = false

        XCTAssertTrue(gestureManager.options.scrollEnabled)
        XCTAssertFalse(recognizer.isEnabled)
        XCTAssertTrue(scrollingGestureRecognizers.filter { $0 !== recognizer }.allSatisfy { $0.isEnabled })

        recognizer.isEnabled = true

        XCTAssertTrue(gestureManager.options.scrollEnabled)
        XCTAssertTrue(scrollingGestureRecognizers.allSatisfy { $0.isEnabled })

        scrollingGestureRecognizers.forEach { $0.isEnabled = false }

        XCTAssertFalse(gestureManager.options.scrollEnabled)
        XCTAssertTrue(scrollingGestureRecognizers.allSatisfy { !$0.isEnabled })

        scrollingGestureRecognizers.forEach { $0.isEnabled = true }

        XCTAssertTrue(gestureManager.options.scrollEnabled)
        XCTAssertTrue(scrollingGestureRecognizers.allSatisfy { $0.isEnabled })
    }

    func testOptionsZoomEnabled() {
        let zoomingGestureRecognizers: [UIGestureRecognizer] = [
            gestureManager.pinchGestureRecognizer,
            gestureManager.quickZoomGestureRecognizer,
            gestureManager.doubleTapToZoomOutGestureRecognizer,
            gestureManager.doubleTapToZoomInGestureRecognizer]

        XCTAssertTrue(gestureManager.options.zoomEnabled)
        XCTAssertTrue(zoomingGestureRecognizers.allSatisfy { $0.isEnabled })

        gestureManager.options.zoomEnabled = false

        XCTAssertFalse(gestureManager.options.zoomEnabled)
        XCTAssertTrue(zoomingGestureRecognizers.allSatisfy { !$0.isEnabled })

        gestureManager.options.zoomEnabled = true

        XCTAssertTrue(gestureManager.options.zoomEnabled)
        XCTAssertTrue(zoomingGestureRecognizers.allSatisfy { $0.isEnabled })

        let recognizer = zoomingGestureRecognizers.randomElement()!
        recognizer.isEnabled = false

        XCTAssertTrue(gestureManager.options.zoomEnabled)
        XCTAssertFalse(recognizer.isEnabled)
        XCTAssertTrue(zoomingGestureRecognizers.filter { $0 !== recognizer }.allSatisfy { $0.isEnabled })

        recognizer.isEnabled = true

        XCTAssertTrue(gestureManager.options.zoomEnabled)
        XCTAssertTrue(zoomingGestureRecognizers.allSatisfy { $0.isEnabled })

        zoomingGestureRecognizers.forEach { $0.isEnabled = false }

        XCTAssertFalse(gestureManager.options.zoomEnabled)
        XCTAssertTrue(zoomingGestureRecognizers.allSatisfy { !$0.isEnabled })

        zoomingGestureRecognizers.forEach { $0.isEnabled = true }

        XCTAssertTrue(gestureManager.options.zoomEnabled)
        XCTAssertTrue(zoomingGestureRecognizers.allSatisfy { $0.isEnabled })
    }
}
