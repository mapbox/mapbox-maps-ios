import XCTest
import UIKit

#if canImport(MapboxMaps)
@testable import MapboxMaps
#else
@testable import MapboxMapsGestures
import MapboxMapsFoundation
#endif

//swiftlint:disable explicit_acl explicit_top_level_acl
class GestureManagerTests: XCTestCase {

    var view: BaseMapView!
    // swiftlint:disable weak_delegate
    var delegate: GestureHandlerDelegateMock!
    var cameraManager: CameraManager!

    override func setUp() {
        let resourceOptions = ResourceOptions(accessToken: "")
        self.view = BaseMapView(with: CGRect(x: 0, y: 0, width: 100, height: 100),
                                resourceOptions: resourceOptions,
                                glyphsRasterizationOptions: GlyphsRasterizationOptions.default,
                                styleURL: nil)
        self.delegate = GestureHandlerDelegateMock()
        let options = MapCameraOptions()
        self.cameraManager = CameraManager(for: self.view, with: options)
    }

    func testInitializer() {
        let options = GestureOptions()
        let gestureManager = GestureManager(for: self.view, options: options, cameraManager: cameraManager)

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
        let gestureManager = GestureManager(for: self.view, options: options, cameraManager: self.cameraManager)

        options.pitchEnabled = true
        gestureManager.updateGestureOptions(with: options)

        XCTAssert(gestureManager.gestureHandlers.count == 7)
    }

    func testUpdateOfGestureConfigByRemovingAllGestures() {

        var options = GestureOptions()
        let gestureManager = GestureManager(for: self.view, options: options, cameraManager: self.cameraManager)

        options.pitchEnabled = false
        options.scrollEnabled = false
        options.zoomEnabled = false
        options.rotateEnabled = false

        gestureManager.updateGestureOptions(with: options)

        XCTAssert(gestureManager.gestureHandlers.count == 0)
    }

    func testSimultaneousRotationAndPanGestures() {
        let options = GestureOptions()
        let gestureManager = GestureManager(for: self.view, options: options, cameraManager: self.cameraManager)

        let panGestureRecognizer = UIPanGestureRecognizer()
        let rotateGestureRecognizer = UIRotationGestureRecognizer()
        XCTAssertTrue(gestureManager.gestureRecognizer(panGestureRecognizer,
                                                       shouldRecognizeSimultaneouslyWith: rotateGestureRecognizer))
    }

    func testSimultaneousTapAndPanGestures() {
        let options = GestureOptions()
        let gestureManager = GestureManager(for: self.view, options: options, cameraManager: self.cameraManager)

        let panGestureRecognizer = UIPanGestureRecognizer()
        let tapGestureRecognizer = UITapGestureRecognizer()
        XCTAssertFalse(gestureManager.gestureRecognizer(panGestureRecognizer,
                                                        shouldRecognizeSimultaneouslyWith: tapGestureRecognizer))
    }
}
