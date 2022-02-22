@testable import MapboxMaps
import XCTest

final class CancelableTests: XCTestCase {
    func testBlockCancelable() {
        let blockStub = Stub<Void, Void>()
        let cancelable = BlockCancelable(block: blockStub.call)

        cancelable.cancel()

        assertMethodCall(blockStub)
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

        assertMethodCall(child1.cancelStub)
        assertMethodCall(child2.cancelStub)

        let child3 = MockCancelable()
        cancelable.add(child3)
        assertMethodCall(child3.cancelStub)

        child1.cancelStub.reset()
        child2.cancelStub.reset()
        child3.cancelStub.reset()

        cancelable.cancel()

        XCTAssertTrue(child1.cancelStub.invocations.isEmpty)
        XCTAssertTrue(child2.cancelStub.invocations.isEmpty)
        XCTAssertTrue(child3.cancelStub.invocations.isEmpty)
    }

    func testAddToCancelableCollection() {
        let cancelable = MockCancelable()
        let container = CancelableContainer()

        cancelable.add(to: container)

        container.cancelAll()

        assertMethodCall(cancelable.cancelStub)
    }
}
