import XCTest
@testable import MapboxMaps

final class CancelableConatinerTests: XCTestCase {

    func testCancelAll() {
        let cancelables = Array.random(withLength: .random(in: 1...10), generator: MockCancelable.init)
        let container = CancelableContainer()
        cancelables.forEach(container.add(_:))

        container.cancelAll()

        for cancelable in cancelables {
            assertMethodCall(cancelable.cancelStub)
        }

        // subsequent invocation only cancels newly-added cancelables
        let otherCancelables = Array.random(withLength: .random(in: 1...10), generator: MockCancelable.init)
        otherCancelables.forEach(container.add(_:))

        container.cancelAll()

        for cancelable in cancelables + otherCancelables {
            assertMethodCall(cancelable.cancelStub)
        }
    }

    func testCancelsAllUponDeinit() {
        let cancelables = Array.random(withLength: .random(in: 1...10), generator: MockCancelable.init)

        do {
            let container = CancelableContainer()
            cancelables.forEach(container.add(_:))
        }

        for cancelable in cancelables {
            assertMethodCall(cancelable.cancelStub)
        }
    }

    func testCancelAllReleasesStrongReferenceToAddedCancelables() {
        let deinitStub: Stub<Void, Void>

        let container = CancelableContainer()
        do {
            let cancelable = MockCancelable()
            deinitStub = cancelable.deinitStub
            container.add(cancelable)
        }

        container.cancelAll()

        assertMethodCall(deinitStub)
    }

    func testAddingSameCancelableMultipleTimesHasNoEffect() {
        let cancelable = MockCancelable()
        let container = CancelableContainer()
        container.add(cancelable)
        container.add(cancelable)

        container.cancelAll()

        assertMethodCall(cancelable.cancelStub)
    }
}
