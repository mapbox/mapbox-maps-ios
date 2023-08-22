@testable import MapboxMaps
import XCTest

final class CancelableTests: XCTestCase {
    func testBlockCancelable() {
        let blockStub = Stub<Void, Void>()
        let cancelable = BlockCancelable(block: blockStub.call)

        cancelable.cancel()

        XCTAssertEqual(blockStub.invocations.count, 1)
        blockStub.reset()

        cancelable.cancel()

        XCTAssertTrue(blockStub.invocations.isEmpty)
    }

    func testCompositeCancelable() {
        let child1 = MockCancelable()
        let child2 = MockCancelable()

        let cancelable = CompositeCancelable()

        cancelable.add(child1)
        cancelable.add(child2)

        cancelable.cancel()

        XCTAssertEqual(child1.cancelStub.invocations.count, 1)
        XCTAssertEqual(child2.cancelStub.invocations.count, 1)

        let child3 = MockCancelable()
        cancelable.add(child3)
        XCTAssertEqual(child3.cancelStub.invocations.count, 1)

        child1.cancelStub.reset()
        child2.cancelStub.reset()
        child3.cancelStub.reset()

        cancelable.cancel()

        XCTAssertTrue(child1.cancelStub.invocations.isEmpty)
        XCTAssertTrue(child2.cancelStub.invocations.isEmpty)
        XCTAssertTrue(child3.cancelStub.invocations.isEmpty)
    }
}
