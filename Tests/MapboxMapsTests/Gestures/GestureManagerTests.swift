import XCTest
import UIKit
@testable import MapboxMaps

final class GestureManagerTests: XCTestCase {

    var mapView: MapView!
    var cameraAnimationsManager: MockCameraAnimationsManager!
    var initialGestureOptions: GestureOptions!
    var gestureManager: GestureManager!

    override func setUp() {
        super.setUp()
        mapView = MapView(
            frame: CGRect(x: 0, y: 0, width: 100, height: 100),
            mapInitOptions: MapInitOptions(
                resourceOptions: ResourceOptions(accessToken: "dummy"),
                styleURI: nil))
        cameraAnimationsManager = MockCameraAnimationsManager()
        initialGestureOptions = GestureOptions()
        gestureManager = GestureManager(
            view: mapView,
            cameraAnimationsManager: cameraAnimationsManager,
            mapboxMap: mapView.mapboxMap)
    }

    override func tearDown() {
        gestureManager = nil
        initialGestureOptions = nil
        cameraAnimationsManager = nil
        mapView = nil
        super.tearDown()
    }

    func testInitializer() {
        XCTAssert(gestureManager.gestureHandlers.count == 7)
        XCTAssert(gestureManager.gestureHandlers[.tap(numberOfTouches: 1)] is TapGestureHandler)
        XCTAssert(gestureManager.gestureHandlers[.tap(numberOfTouches: 2)] is TapGestureHandler)
        XCTAssert(gestureManager.gestureHandlers[.pan] is PanGestureHandler)
    }

    func testGestureRecognizersReturnedAreSameAsRecognizersPresentInGestureHandlers() {
        XCTAssertTrue(gestureManager.gestureHandlers[.tap(numberOfTouches: 1)]?.gestureRecognizer === gestureManager.doubleTapToZoomInGestureRecognizer)
        XCTAssertTrue(gestureManager.gestureHandlers[.tap(numberOfTouches: 2)]?.gestureRecognizer === gestureManager.doubleTapToZoomOutGestureRecognizer)
        XCTAssertTrue(gestureManager.gestureHandlers[.pan]?.gestureRecognizer === gestureManager.panGestureRecognizer)
        XCTAssertTrue(gestureManager.gestureHandlers[.pinch]?.gestureRecognizer === gestureManager.pinchGestureRecognizer)
        XCTAssertTrue(gestureManager.gestureHandlers[.pitch]?.gestureRecognizer === gestureManager.pitchGestureRecognizer)
        XCTAssertTrue(gestureManager.gestureHandlers[.quickZoom]?.gestureRecognizer === gestureManager.quickZoomGestureRecognizer)
        XCTAssertTrue(gestureManager.gestureHandlers[.rotate]?.gestureRecognizer === gestureManager.rotationGestureRecognizer)
    }

    func testUpdateOfGestureConfigByAddingNewGestures() {

        var options = GestureOptions()
        options.pitchEnabled = false
        let gestureManager = GestureManager(
            view: mapView,
            cameraAnimationsManager: cameraAnimationsManager,
            mapboxMap: mapView.mapboxMap)

        options.pitchEnabled = true
        gestureManager.options = options

        XCTAssert(gestureManager.gestureHandlers.count == 7)
    }

    func testUpdateOfGestureConfigByRemovingAllGestures() {
        var options = GestureOptions()
        options.pitchEnabled = false
        options.scrollEnabled = false
        options.zoomEnabled = false
        options.rotateEnabled = false

        gestureManager.options = options

        XCTAssert(gestureManager.gestureHandlers.count == 0)
    }
}
