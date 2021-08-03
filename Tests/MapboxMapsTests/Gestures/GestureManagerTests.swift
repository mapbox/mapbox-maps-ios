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
    var cameraAnimationsManager: MockCameraAnimationsManager!
    var initialGestureOptions: GestureOptions!
    var gestureManager: GestureManager!

    override func setUp() {
        mapView = MapView(
            frame: CGRect(x: 0, y: 0, width: 100, height: 100),
            mapInitOptions: MapInitOptions(
                resourceOptions: ResourceOptions(accessToken: "dummy"),
                styleURI: nil))
        delegate = GestureHandlerDelegateMock()
        cameraAnimationsManager = MockCameraAnimationsManager()
        initialGestureOptions = GestureOptions()
        gestureManager = GestureManager(
            view: mapView,
            cameraAnimationsManager: cameraAnimationsManager,
            mapboxMap: mapView.mapboxMap)
    }

    func testInitializer() {
        XCTAssert(gestureManager.gestureHandlers.count == 7)
        XCTAssert(gestureManager.gestureHandlers[.tap(numberOfTaps: 2, numberOfTouches: 1)] is TapGestureHandler)
        XCTAssert(gestureManager.gestureHandlers[.tap(numberOfTaps: 2, numberOfTouches: 2)] is TapGestureHandler)
        XCTAssert(gestureManager.gestureHandlers[.pan] is PanGestureHandler)
    }

    func testGestureRecognizersReturnedAreSameAsRecognizersPresentInGestureHandlers() {
        XCTAssertTrue(gestureManager.gestureHandlers[.tap(numberOfTaps: 2, numberOfTouches: 1)]?.gestureRecognizer === gestureManager.doubleTapToZoomInGestureRecognizer)
        XCTAssertTrue(gestureManager.gestureHandlers[.tap(numberOfTaps: 2, numberOfTouches: 2)]?.gestureRecognizer === gestureManager.doubleTapToZoomOutGestureRecognizer)
        XCTAssertTrue(gestureManager.gestureHandlers[.pan]?.gestureRecognizer === gestureManager.panGestureRecognizer)
        XCTAssertTrue(gestureManager.gestureHandlers[.pinch]?.gestureRecognizer === gestureManager.pinchGestureRecognizer)
        XCTAssertTrue(gestureManager.gestureHandlers[.pitch]?.gestureRecognizer === gestureManager.pitchGestureRecognizer)
        XCTAssertTrue(gestureManager.gestureHandlers[.quickZoom]?.gestureRecognizer === gestureManager.quickZoomGestureRecognizer)
        XCTAssertTrue(gestureManager.gestureHandlers[.rotate]?.gestureRecognizer === gestureManager.rotationGestureRecognizer)
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

    func testAllowedSimultaneousGestures() {
        let pinchGestureRecognizer = UIPinchGestureRecognizer()
        let rotateGestureRecognizer = UIRotationGestureRecognizer()
        XCTAssertTrue(gestureManager.gestureRecognizer(pinchGestureRecognizer,
                                                       shouldRecognizeSimultaneouslyWith: rotateGestureRecognizer))
    }

    func testDisallowedSimultaneousGestures() {
        let panGestureRecognizer = UIPanGestureRecognizer()
        let tapGestureRecognizer = UITapGestureRecognizer()
        let pinchGestureRecognizer = UIPinchGestureRecognizer()
        let rotateGestureRecognizer = UIRotationGestureRecognizer()

        XCTAssertFalse(gestureManager.gestureRecognizer(panGestureRecognizer,
                                                       shouldRecognizeSimultaneouslyWith: pinchGestureRecognizer))
        XCTAssertFalse(gestureManager.gestureRecognizer(panGestureRecognizer,
                                                       shouldRecognizeSimultaneouslyWith: rotateGestureRecognizer))
        XCTAssertFalse(gestureManager.gestureRecognizer(panGestureRecognizer,
                                                       shouldRecognizeSimultaneouslyWith: tapGestureRecognizer))

        XCTAssertFalse(gestureManager.gestureRecognizer(tapGestureRecognizer,
                                                       shouldRecognizeSimultaneouslyWith: pinchGestureRecognizer))
        XCTAssertFalse(gestureManager.gestureRecognizer(tapGestureRecognizer,
                                                       shouldRecognizeSimultaneouslyWith: rotateGestureRecognizer))
    }

    func testSimultaneousTapAndPanGestures() {
        let panGestureRecognizer = UIPanGestureRecognizer()
        let tapGestureRecognizer = UITapGestureRecognizer()
        XCTAssertFalse(gestureManager.gestureRecognizer(panGestureRecognizer,
                                                        shouldRecognizeSimultaneouslyWith: tapGestureRecognizer))
    }

    func testPinchChangedSetsCamera() {
        let zoom = 10.0
        let increment = 0.1

        XCTAssertNotEqual(mapView.cameraState.zoom,
                          CGFloat(zoom),
                          "The map's zoom should not equal `zoom` before it is provided to the gesture manager.")

        let cameraState = MapboxCoreMaps.CameraState(center: .init(latitude: 0.0, longitude: 0.0),
                                                     padding: EdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
                                                     zoom: Double(zoom),
                                                     bearing: 0.0,
                                                     pitch: 0.0)

        gestureManager.pinchChanged(withZoomIncrement: CGFloat(increment),
                                    targetAnchor: .zero,
                                    initialAnchor: .zero,
                                    initialCameraState: CameraState(cameraState))

        XCTAssertEqual(mapView.cameraState.zoom,
                       10.1,
                       accuracy: 0.00001,
                       "The map's zoom should equal the zoom level provided by the gesture manager.")
    }

    func testPinchEndedDoesNotUnrotate() {
        mapView.mapboxMap.setCamera(to: CameraOptions(zoom: 3.0,
                                                      bearing: CLLocationDirection(5.0)))

        let newOptions = CameraBoundsOptions(minZoom: 2.0)
        try! mapView.mapboxMap.setCameraBounds(for: newOptions)

        gestureManager.pinchEnded()

        XCTAssertEqual(mapView.mapboxMap.cameraState.bearing,
                       5.0,
                       "The maps bearing should not reset")
    }
}
