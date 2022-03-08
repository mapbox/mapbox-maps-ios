import XCTest
@testable import MapboxMaps

final class EmptyPinchBehaviorTests: BasePinchBehaviorTests {
    override func setUp() {
        super.setUp()
        behavior = EmptyPinchBehavior()
    }

    func testUpdate() {
        behavior.update(
            pinchMidpoint: .random(),
            pinchScale: .random(in: 0..<2),
            pinchAngle: .random(in: 0..<2 * .pi))

        XCTAssertTrue(mapboxMap.setCameraStub.invocations.isEmpty)
    }
}
