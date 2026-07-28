import XCTest
import Combine
@testable import MapboxMaps

final class AnyCancelableTests: XCTestCase {
    func testBlockCancellation() {
        var cancelCount = 0
        let c = AnyCancelable {
            cancelCount += 1
        }

        XCTAssertEqual(cancelCount, 0)

        c.cancel()
        XCTAssertEqual(cancelCount, 1)

        c.cancel()
        XCTAssertEqual(cancelCount, 1)
    }

    func testSequenceCancellable() {
        let counter1 = CancelCounter()
        let counter2 = CancelCounter()

        let cancelable = AnyCancelable([counter1, counter2])

        XCTAssertEqual(counter1.value, 0)
        XCTAssertEqual(counter2.value, 0)

        cancelable.cancel()
        XCTAssertEqual(counter1.value, 1)
        XCTAssertEqual(counter2.value, 1)

        cancelable.cancel()
        XCTAssertEqual(counter1.value, 1)
        XCTAssertEqual(counter2.value, 1)
    }

    func testSequenceCancelable() {
        let counter1 = CancelCounter()
        let counter2 = CancelCounter()

        let cancelable = AnyCancelable([counter1, counter2])

        XCTAssertEqual(counter1.value, 0)
        XCTAssertEqual(counter2.value, 0)

        cancelable.cancel()
        XCTAssertEqual(counter1.value, 1)
        XCTAssertEqual(counter2.value, 1)

        cancelable.cancel()
        XCTAssertEqual(counter1.value, 1)
        XCTAssertEqual(counter2.value, 1)
    }

    func testCancelableObjectInit() {
        let counter = CancelCounter()

        let cancelable = AnyCancelable(counter)

        XCTAssertEqual(counter.value, 0)

        cancelable.cancel()
        XCTAssertEqual(counter.value, 1)

        cancelable.cancel()
        XCTAssertEqual(counter.value, 1)
    }

    func testDeinit() {
        let counter1 = CancelCounter()
        let counter2 = CancelCounter()

        var cancelable: AnyCancelable! = AnyCancelable([counter1, counter2])

        XCTAssertEqual(counter1.value, 0)
        XCTAssertEqual(counter2.value, 0)

        cancelable.cancel()
        cancelable = nil
        XCTAssertEqual(counter1.value, 1)
        XCTAssertEqual(counter2.value, 1)
    }

    func testIdempotency() {
        let counter = CancelCounter()
        let cancelable = AnyCancelable(counter.cancel)

        cancelable.cancel()
        cancelable.cancel()

        XCTAssertEqual(counter.value, 1)
    }

    /// cancel : cancel — the same cancellable cancelled from several threads at once
    /// must run its closure exactly once.
    func testConcurrentCancelRunsClosureExactlyOnce() {
        for _ in 0..<1_000 {
            let countLock = NSLock()
            var count = 0
            let cancelable = AnyCancelable {
                countLock.withLock { count += 1 }
            }

            DispatchQueue.concurrentPerform(iterations: 8) { _ in
                cancelable.cancel()
            }

            XCTAssertEqual(count, 1, "concurrent cancels must run the closure exactly once")
        }
    }

    func testReentrantCancel() {
        var cancelCount = 0
        var cancelable: AnyCancelable!
        cancelable = AnyCancelable {
            cancelCount += 1
            cancelable.cancel() // cancellation chains may loop back; must be a no-op
        }

        cancelable.cancel()
        XCTAssertEqual(cancelCount, 1)
    }

    func testStoreInCollection() {
        let counter = CancelCounter()
        var set = Set<AnyCancelable>()
        AnyCancelable(counter.cancel).store(in: &set)

        XCTAssertEqual(counter.value, 0)
        set.removeAll()
        XCTAssertEqual(counter.value, 1)

        var collection = [AnyCancelable]()
        autoreleasepool {
            AnyCancelable(counter.cancel).store(in: &collection)
        }
        XCTAssertEqual(counter.value, 1)
        collection.removeAll()
        XCTAssertEqual(counter.value, 2)
    }

    @available(iOS 13, *)
    func testStoreInCollectionOfCombineCancelables() {
        let counter = CancelCounter()
        var set = Set<AnyCancellable>()
        AnyCancelable(counter.cancel).store(in: &set)

        XCTAssertEqual(counter.value, 0)
        set.removeAll()
        XCTAssertEqual(counter.value, 1)

        var collection = [AnyCancellable]()
        autoreleasepool {
            AnyCancelable(counter.cancel).store(in: &collection)
        }
        XCTAssertEqual(counter.value, 1)
        collection.removeAll()
        XCTAssertEqual(counter.value, 2)
    }

    @available(iOS 13, *)
    func testStoreCombineCancellableInSet() {
        var counter = 0
        var disposeBag: Set<AnyCancelable> = []
        Combine.AnyCancellable {
            counter += 1
        }.store(in: &disposeBag)

        XCTAssertEqual(counter, 0)
        disposeBag.removeAll()
        XCTAssertEqual(counter, 1)
    }

    @available(iOS 13, *)
    func testStoreCombineCancellableInCollection() {
        var counter = 0
        var disposeBag: [AnyCancelable] = []
        Combine.AnyCancellable {
            counter += 1
        }.store(in: &disposeBag)

        XCTAssertEqual(counter, 0)
        disposeBag.removeAll()
        XCTAssertEqual(counter, 1)
    }
}

private final class CancelCounter: Cancelable {
    var value = 0
    func cancel() {
        value += 1
    }
}
