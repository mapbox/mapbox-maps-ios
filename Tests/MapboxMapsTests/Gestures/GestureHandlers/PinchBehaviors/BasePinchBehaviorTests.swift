import XCTest
@testable import MapboxMaps

class BasePinchBehaviorTests: XCTestCase {
    var initialCameraState: CameraState!
    var initialPinchMidpoint: CGPoint!
    var initialPinchAngle: CGFloat!
    var mapboxMap: MockMapboxMap!
    var behavior: PinchBehavior!
    var cameraChangedCount = 0

    override func setUp() {
        super.setUp()
        initialCameraState = .random()
        initialPinchMidpoint = .random()
        initialPinchAngle = .random(in: 0..<360)
        mapboxMap = MockMapboxMap()
        cameraChangedCount = 0
        var shouldIncrement = true
        mapboxMap.performWithoutNotifyingWillInvokeBlock = {
            // notifications should only be ignored *before* the
            // setCamera that emits the .cameraChanged so that
            // listeners receive the final camera state
            XCTAssertEqual(self.cameraChangedCount, 0)
            shouldIncrement = false
        }
        mapboxMap.performWithoutNotifyingDidInvokeBlock = {
            shouldIncrement = true
        }
        mapboxMap.setCameraStub.defaultSideEffect = { _ in
            if shouldIncrement {
                self.cameraChangedCount += 1
            }
        }
    }

    override func tearDown() {
        cameraChangedCount = 0
        behavior = nil
        mapboxMap = nil
        initialPinchAngle = nil
        initialPinchMidpoint = nil
        initialCameraState = nil
        super.tearDown()
    }
}
