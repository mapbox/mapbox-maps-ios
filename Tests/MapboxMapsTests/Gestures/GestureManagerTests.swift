import XCTest
import UIKit

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsGestures
import MapboxMapsFoundation
#endif

//swiftlint:disable explicit_acl explicit_top_level_acl
final class GestureManagerTests: XCTestCase {

    var mapView: MapView!
    // swiftlint:disable weak_delegate
    var delegate: GestureHandlerDelegateMock!
    var cameraManager: MockCameraManager!
    var initialGestureOptions: GestureOptions!
    var gestureManager: GestureManager!

    override func setUp() {
        mapView = MapView(frame: CGRect(x: 0, y: 0, width: 100, height: 100),
                          mapInitOptions: MapInitOptions(
                            resourceOptions: ResourceOptions(accessToken: "dummy"),
                            styleURI: nil))
        delegate = GestureHandlerDelegateMock()
        cameraManager = MockCameraManager()
        cameraManager.mapView = mapView
        initialGestureOptions = GestureOptions()
        gestureManager = GestureManager(for: mapView,
                                        cameraManager: cameraManager)
    }

    func testInitializer() {
        XCTAssert(gestureManager.gestureHandlers.count == 7)
        XCTAssert(gestureManager.gestureHandlers[.tap(numberOfTaps: 2, numberOfTouches: 1)] is TapGestureHandler)
        XCTAssert(gestureManager.gestureHandlers[.tap(numberOfTaps: 2, numberOfTouches: 2)] is TapGestureHandler)
        XCTAssert(gestureManager.gestureHandlers[.pan] is PanGestureHandler)
    }

    func testTapGesturesTypesAreEqual() {
        let singleTapA = GestureType.tap(numberOfTaps: 1, numberOfTouches: 1)
        let singleTapB = GestureType.tap(numberOfTaps: 1, numberOfTouches: 1)

        XCTAssert(singleTapA == singleTapB, "two tap gestures are identical")
    }

    func testTapGesturesTypesAreNotEqual() {
        let singleTapA = GestureType.tap(numberOfTaps: 1, numberOfTouches: 1)
        let singleTapB = GestureType.tap(numberOfTaps: 1, numberOfTouches: 2)

        XCTAssertFalse(singleTapA == singleTapB, "two tap gestures are different")
    }

    func testUpdateOfGestureConfigByAddingNewGestures() {

        var options = GestureOptions()
        options.pitchEnabled = false
        let gestureManager = GestureManager(
            for: mapView,
            cameraManager: cameraManager)

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

    func testSimultaneousRotationAndPanGestures() {
        let panGestureRecognizer = UIPanGestureRecognizer()
        let rotateGestureRecognizer = UIRotationGestureRecognizer()
        XCTAssertTrue(gestureManager.gestureRecognizer(panGestureRecognizer,
                                                       shouldRecognizeSimultaneouslyWith: rotateGestureRecognizer))
    }

    func testSimultaneousTapAndPanGestures() {
        let panGestureRecognizer = UIPanGestureRecognizer()
        let tapGestureRecognizer = UITapGestureRecognizer()
        XCTAssertFalse(gestureManager.gestureRecognizer(panGestureRecognizer,
                                                        shouldRecognizeSimultaneouslyWith: tapGestureRecognizer))
    }

    func testPinchScaleChanged_SetsCamera() {
        let zoom = CGFloat.random(in: 0...22)

        XCTAssertNotEqual(mapView.cameraState.zoom, zoom, "The map's zoom should not equal `zoom` before it is provided to the gesture manager.")
        gestureManager.pinchScaleChanged(with: zoom, andAnchor: .zero)

        XCTAssertEqual(mapView.cameraState.zoom, zoom, accuracy: 0.00001, "The map's zoom should equal the zoom level provided by the gesture manager.")
    }

    func testPinchEnded_SetsCamera() {
        let zoom = CGFloat.random(in: 0...22)

        XCTAssertNotEqual(mapView.cameraState.zoom, zoom, "The map's zoom should not equal `zoom` before it is provided to the gesture manager.")
        gestureManager.pinchEnded(with: zoom, andDrift: true, andAnchor: .zero)

        XCTAssertEqual(mapView.cameraState.zoom, zoom, accuracy: 0.00001, "The map's zoom should equal the zoom level provided by the gesture manager after the drift.")
    }
}
