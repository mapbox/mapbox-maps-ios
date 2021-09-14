import XCTest
@testable import MapboxMaps

final class GestureManagerTests: XCTestCase {

    var view: UIView!
    var mapboxMap: MockMapboxMap!
    var cameraAnimationsManager: MockCameraAnimationsManager!
    var gestureManager: GestureManager!
    // swiftlint:disable:next weak_delegate
    var delegate: MockGestureManagerDelegate!

    override func setUp() {
        super.setUp()
        view = UIView()
        mapboxMap = MockMapboxMap()
        cameraAnimationsManager = MockCameraAnimationsManager()
        gestureManager = GestureManager(
            view: view,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
        delegate =  MockGestureManagerDelegate()
        gestureManager.delegate = delegate
    }

    override func tearDown() {
        delegate = nil
        gestureManager = nil
        cameraAnimationsManager = nil
        mapboxMap = nil
        view = nil
        super.tearDown()
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
