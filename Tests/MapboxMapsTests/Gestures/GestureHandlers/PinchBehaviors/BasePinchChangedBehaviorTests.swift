import XCTest
@testable import MapboxMaps

class BasePinchChangedBehaviorTests: XCTestCase {
    var initialCameraState: CameraState!
    var initialPinchMidpoint: CGPoint!
    var initialPinchAngle: CGFloat!
    var mapboxMap: MockMapboxMap!
    var behavior: PinchBehavior!

    override func setUp() {
        super.setUp()
        initialCameraState = .random()
        initialPinchMidpoint = .random()
        initialPinchAngle = .random(in: 0..<360)
        mapboxMap = MockMapboxMap()
    }

    override func tearDown() {
        behavior = nil
        mapboxMap = nil
        initialPinchAngle = nil
        initialPinchMidpoint = nil
        initialCameraState = nil
        super.tearDown()
    }
}
