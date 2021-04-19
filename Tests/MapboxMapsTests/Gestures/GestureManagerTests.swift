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

    var mapView: BaseMapView!
    // swiftlint:disable weak_delegate
    var delegate: GestureHandlerDelegateMock!
    var cameraManager: MockCameraManager!
    var initialGestureOptions: GestureOptions!
    var gestureManager: GestureManager!

    override func setUp() {
        mapView = BaseMapView(frame: CGRect(x: 0, y: 0, width: 100, height: 100),
                              mapInitOptions: MapInitOptions(),
                              styleURI: nil)
        delegate = GestureHandlerDelegateMock()
        cameraManager = MockCameraManager()
        cameraManager.mapView = mapView
        initialGestureOptions = GestureOptions()
        gestureManager = GestureManager(for: mapView,
                                        options: initialGestureOptions,
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
        let gestureManager = GestureManager(for: mapView, options: options, cameraManager: cameraManager)

        options.pitchEnabled = true
        gestureManager.updateGestureOptions(with: options)

        XCTAssert(gestureManager.gestureHandlers.count == 7)
    }

    func testUpdateOfGestureConfigByRemovingAllGestures() {
        var options = GestureOptions()
        options.pitchEnabled = false
        options.scrollEnabled = false
        options.zoomEnabled = false
        options.rotateEnabled = false

        gestureManager.updateGestureOptions(with: options)

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

        gestureManager.pinchScaleChanged(with: zoom, andAnchor: .zero)

        XCTAssertEqual(cameraManager.setCameraStub.invocations.count, 1)
        XCTAssertEqual(cameraManager.setCameraStub.parameters.first?.camera.zoom, zoom)
        XCTAssertEqual(cameraManager.setCameraStub.parameters.first?.camera.anchor, .zero)
    }

    func testPinchEnded_SetsCamera() {
        let zoom = CGFloat.random(in: 0...22)

        gestureManager.pinchEnded(with: zoom, andDrift: true, andAnchor: .zero)

        XCTAssertEqual(cameraManager.setCameraStub.invocations.count, 1)
        XCTAssertEqual(cameraManager.setCameraStub.parameters.first?.camera.zoom, zoom)
        XCTAssertEqual(cameraManager.setCameraStub.parameters.first?.camera.anchor, .zero)
    }
}
