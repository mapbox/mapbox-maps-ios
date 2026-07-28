import XCTest
import Combine
@testable import MapboxMaps

/// Concurrency tests for `ClosureHandlersStore`: add/cancel/send must be safe to call from any
/// thread without losing, duplicating, or corrupting handlers. Each test drives one racing pair;
/// without correct locking, these are expected to crash or fail.
final class ClosureHandlersStoreConcurrencyTests: XCTestCase {
    private let iterations = 3_000

    // MARK: - Calling ClosureHandlersStore directly

    /// add : add — many handlers added concurrently. Must all register, without losing any or crashing.
    func testConcurrentAddIsLossless() {
        let store = ClosureHandlersStore<Int, Void>()
        var cancelables = [AnyCancelable?](repeating: nil, count: iterations)

        DispatchQueue.concurrentPerform(iterations: iterations) { i in
            cancelables[i] = store.add { _ in }
        }

        XCTAssertEqual(Array(store).count, iterations)
    }

    /// cancel : cancel — many pre-added handlers cancelled concurrently. Must all be removed, without crashing.
    func testConcurrentCancelIsLossless() {
        let store = ClosureHandlersStore<Int, Void>()
        let cancelables = (0..<iterations).map { _ in store.add { _ in } }

        DispatchQueue.concurrentPerform(iterations: iterations) { i in
            cancelables[i].cancel()
        }

        XCTAssertEqual(Array(store).count, 0)
    }

    /// send : add — a growing set of handlers is added concurrently while `send` reads the array
    /// from this thread. Growing (instead of draining) the array forces periodic reallocations,
    /// which is what actually creates a collision window wide enough to hit — a small, stable
    /// array's `append` is too cheap an in-place write to reliably collide with.
    func testSendIsThreadSafeWhileHandlersAreAddedConcurrently() {
        let store = ClosureHandlersStore<Int, Void>()
        var cancelables = [AnyCancelable?](repeating: nil, count: iterations)

        let addingDone = expectation(description: "concurrent adds finished")
        DispatchQueue.global(qos: .userInitiated).async { [iterations] in
            DispatchQueue.concurrentPerform(iterations: iterations) { i in
                cancelables[i] = store.add { _ in }
            }
            addingDone.fulfill()
        }

        for i in 0..<iterations {
            store.send(i)
        }
        wait(for: [addingDone], timeout: 30)

        XCTAssertEqual(Array(store).count, iterations)
    }

    /// send : cancel — a full set of handlers is torn down concurrently while `send` reads the array
    /// from this thread. Mirrors closing a screen (mass cancel) while the map still emits camera
    /// changes (send). Must end with every handler removed, without crashing.
    func testSendIsThreadSafeWhileHandlersAreCancelledConcurrently() {
        let store = ClosureHandlersStore<Int, Void>()
        let cancelables = (0..<iterations).map { _ in store.add { _ in } }

        let teardownDone = expectation(description: "concurrent cancels finished")
        DispatchQueue.global(qos: .userInitiated).async { [iterations] in
            DispatchQueue.concurrentPerform(iterations: iterations) { i in
                cancelables[i].cancel()
            }
            teardownDone.fulfill()
        }

        for i in 0..<iterations {
            store.send(i)
        }
        wait(for: [teardownDone], timeout: 30)

        XCTAssertEqual(Array(store).count, 0)
    }

    /// add/cancel : onObserved — concurrent add/cancel must still fire `onObserved` exactly once
    /// per transition (true when becoming non-empty, false when becoming empty), without crashing.
    func testOnObservedFiresExactlyOncePerEdgeUnderConcurrency() {
        let store = ClosureHandlersStore<Int, Void>()
        let edgesLock = NSLock()
        var edges = [Bool]()
        store.onObserved = { isObserved in
            edgesLock.withLock { edges.append(isObserved) }
        }

        // Repeat the empty -> non-empty -> empty cycle many times, concurrently, so a race gets
        // many chances to happen.
        for _ in 0..<200 {
            var cancelables = [AnyCancelable?](repeating: nil, count: 20)
            DispatchQueue.concurrentPerform(iterations: 20) { i in
                cancelables[i] = store.add { _ in }
            }
            DispatchQueue.concurrentPerform(iterations: 20) { i in
                cancelables[i]?.cancel()
            }
        }

        // Edges triggered off the main thread are delivered asynchronously on the main queue;
        // drain it before asserting.
        let drained = expectation(description: "main queue drained")
        DispatchQueue.main.async { drained.fulfill() }
        wait(for: [drained], timeout: 5)

        let recordedEdges = edgesLock.withLock { edges }

        let expectedAlternating = (0..<recordedEdges.count).map { $0.isMultiple(of: 2) }
        XCTAssertEqual(recordedEdges, expectedAlternating, "onObserved should strictly alternate, starting with true")
        XCTAssertEqual(recordedEdges.last, false, "the store must end up empty once every handler is cancelled")
    }

    /// add : cancel — an add overlaps the cancel of the last handler on the empty edge.
    /// `onObserved` must be delivered in the order it happened (true, false, true), not reordered.
    func testOnObservedIsNotReorderedWhenAddOverlapsTheEmptyEdge() {
        let store = ClosureHandlersStore<Int, Void>()

        let edgesLock = NSLock()
        var edges = [Bool]()
        store.onObserved = { observed in
            edgesLock.withLock { edges.append(observed) }
        }

        let firstHandler = store.add { _ in } // main → `true` (delivered inline)

        // Empty the store off the main thread; this commits and queues the `false` edge.
        let emptied = expectation(description: "empty edge committed off the main thread")
        DispatchQueue.global().async {
            firstHandler.cancel()
            emptied.fulfill()
        }
        wait(for: [emptied], timeout: 5)

        // Re-fill the store; its `true` edge must arrive after the `false` one, not before.
        let secondHandler = store.add { _ in }

        let drained = expectation(description: "main queue drained")
        DispatchQueue.main.async { drained.fulfill() }
        wait(for: [drained], timeout: 5)

        withExtendedLifetime(secondHandler) {
            let recordedEdges = edgesLock.withLock { edges }
            XCTAssertEqual(recordedEdges, [true, false, true], "onObserved was delivered out of order")
        }
    }

    /// onObserved (read) : onObserved (write) — reassigning the handler while it's concurrently
    /// read and invoked must not crash.
    func testOnObservedPropertyIsThreadSafeUnderConcurrentReassignment() {
        // A distinct captured object per closure forces a real heap allocation, so each
        // reassignment is a genuine ARC retain/release — not just rewriting the same static value.
        final class Box {}
        let store = ClosureHandlersStore<Int, Void>()
        store.onObserved = { _ in }

        DispatchQueue.concurrentPerform(iterations: iterations) { i in
            if i.isMultiple(of: 2) {
                let box = Box()
                store.onObserved = { _ in withExtendedLifetime(box) {} }
            } else {
                store.onObserved?(true)
            }
        }
    }

    // MARK: - Subscribing through Combine's `.subscribe(on:)`

    /// add : send, through `.subscribe(on:)`.
    /// Scenario: subscribing while the map keeps emitting changes.
    func testCombineSubscribeOnRacesWithSend() {
        let subject = SignalSubject<Int>()
        let bgQueue = DispatchQueue(label: "com.mapbox.test.closureHandlersStore.subscribeOn", attributes: .concurrent)
        var cancellables = [AnyCancellable]()

        // Subscriptions accumulate rather than being cancelled: a growing array forces periodic
        // reallocation, which is what creates a collision window wide enough to hit a concurrent
        // `send` — a small, stable array's `add` is too cheap an in-place write to reliably collide with.
        for i in 0..<iterations {
            cancellables.append(subject.signal.subscribe(on: bgQueue).sink { _ in })
            subject.send(i)
        }

        waitUntil(drainedBy: bgQueue) { Array(subject).count == iterations }
        XCTAssertEqual(Array(subject).count, iterations)
    }

    /// cancel : cancel, through `.subscribe(on:)`.
    /// Scenario: subscribed multiple times, then the screen closes and every subscription cancels at once.
    func testCombineSubscribeOnConcurrentTeardownIsLossless() {
        let subject = SignalSubject<Int>()
        let bgQueue = DispatchQueue(label: "com.mapbox.test.closureHandlersStore.teardown", attributes: .concurrent)
        let subscriptionCount = 300

        // Subscribe one at a time, waiting for each to land before starting the next, so this setup
        // doesn't itself race (`.subscribe(on:)` performs the real `add` asynchronously on `bgQueue`,
        // which is concurrent).
        let cancellables = (0..<subscriptionCount).map { i in
            let cancellable = subject.signal.subscribe(on: bgQueue).sink { _ in }
            waitUntil(drainedBy: bgQueue) { Array(subject).count == i + 1 }
            return cancellable
        }
        XCTAssertEqual(Array(subject).count, subscriptionCount, "sanity check: all subscriptions completed before teardown")

        DispatchQueue.concurrentPerform(iterations: subscriptionCount) { i in
            cancellables[i].cancel()
        }
        waitUntil(drainedBy: bgQueue) { Array(subject).count == 0 }

        XCTAssertEqual(Array(subject).count, 0)
    }

    // MARK: - Helper Methods

    /// `.subscribe(on:)`/`.cancel()` can involve more than one level of async dispatch onto the
    /// given queue (e.g. subscribing to the upstream, then forwarding pending demand) — a single
    /// barrier only waits for what was already queued, not for work queued as a result of running
    /// it. Draining repeatedly until `condition` holds catches any number of such levels.
    private func waitUntil(drainedBy queue: DispatchQueue, timeout: TimeInterval = 5, _ condition: () -> Bool) {
        let deadline = Date().addingTimeInterval(timeout)
        while !condition() {
            guard Date() < deadline else {
                XCTFail("timed out waiting for condition")
                return
            }
            queue.sync(flags: .barrier) {}
        }
    }
}
