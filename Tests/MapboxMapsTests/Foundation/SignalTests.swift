import XCTest
@testable import MapboxMaps

final class SignalTests: XCTestCase {
    var cancellables = Set<AnyCancelable>()

    override func setUp() {
        cancellables.removeAll()
    }

    override func tearDown() {
        cancellables.removeAll()
    }

    func testSignal() {
        var cancelled = false
        let signal = Signal<Int> { handler in
            handler(1)
            return AnyCancelable {
                cancelled = true
            }
        }

        var values = [Int]()
        let c = signal.observe { newValue in
            values.append(newValue)
        }

        XCTAssertEqual(values, [1])
        XCTAssertFalse(cancelled)

        c.cancel()
        XCTAssertTrue(cancelled)
    }

    func testTakeFirst() {
        var observedValues = [Bool]()
        var values1 = [Int]()
        var values2 = [Int]()

        let subject = SignalSubject<Int> { observedValues.append( $0) }
        // Here we test multiple subscriptions
        let first = subject.signal.takeFirst()
        first
            .observe { values1.append($0) }
            .store(in: &cancellables)
        first
            .observe { values2.append($0) }
            .store(in: &cancellables)

        subject.send(1)

        XCTAssertEqual(observedValues, [true, false])
        XCTAssertEqual(values1, [1])
        XCTAssertEqual(values2, [1])

        var values3 = [Int]()
        subject.signal.observeNext { values3.append($0) }.store(in: &cancellables)

        subject.send(2)
        subject.send(3)

        XCTAssertEqual(values1, [1])
        XCTAssertEqual(values2, [1])
        XCTAssertEqual(values3, [2])
        XCTAssertEqual(observedValues, [true, false, true, false])
    }

    func testFilter() {
        let subj = SignalSubject<Int>()

        var received = [Int]()
        subj.signal
            .filter { $0 % 2 == 0 }
            .observe { received.append($0) }
            .store(in: &cancellables)

        subj.send(0)
        XCTAssertEqual(received, [0])

        subj.send(1)
        XCTAssertEqual(received, [0])

        subj.send(2)
        XCTAssertEqual(received, [0, 2])
    }

    func testFilterTakeFirst() {
        let subj = SignalSubject<Int>()

        var received = [Int]()
        subj.signal
            .filter { $0 % 2 == 0 }
            .takeFirst()
            .observe { received.append($0) }
            .store(in: &cancellables)

        subj.send(1)
        XCTAssertEqual(received, [], "ignored")

        subj.send(10)
        XCTAssertEqual(received, [10])

        subj.send(20)
        XCTAssertEqual(received, [10], "self-canceled")
    }

    func testConditional() {
        @MutableRef var condition = true
        let subj = SignalSubject<Int>()

        var received = [Int]()
        subj.signal
            .conditional($condition)
            .observe { received.append($0) }
            .store(in: &cancellables)

        subj.send(0)
        XCTAssertEqual(received, [0])

        condition = false
        subj.send(1)
        XCTAssertEqual(received, [0])

        condition = true
        subj.send(1)
        XCTAssertEqual(received, [0, 1])
    }

    func testJoinWithError() {
        enum MyError: Error, Equatable {
            case foo
            case bar
        }
        let succesSubj = SignalSubject<Int>()
        let errorSubj = SignalSubject<MyError>()

        var received = [Result<Int, MyError>]()
        succesSubj.signal
            .join(withError: errorSubj.signal)
            .observe { received.append($0) }
            .store(in: &cancellables)

        succesSubj.send(0)
        errorSubj.send(.foo)
        succesSubj.send(1)
        errorSubj.send(.bar)

        XCTAssertEqual(received, [.success(0), .failure(.foo), .success(1), .failure(.bar)])
    }

    func testJoinWithErrorTakeFirst() {
        // This test checks that .combine(with error:).takeFirst() works like a future -
        // it combines two streams of events, handles the first, and properyly unsubscribed from
        // both streams.
        enum MyError: Error, Equatable {
            case foo
            case bar
        }

        var observedSuccess = [Bool]()
        var observedError = [Bool]()
        let succesSubj = SignalSubject<Int> { observedSuccess.append($0) }
        let errorSubj = SignalSubject<MyError> { observedError.append($0) }

        var received = [Result<Int, MyError>]()
        succesSubj.signal
            .join(withError: errorSubj.signal)
            .takeFirst()
            .observe { received.append($0) }
            .store(in: &cancellables)

        succesSubj.send(0)
        errorSubj.send(.foo)
        succesSubj.send(1)

        XCTAssertEqual(received, [.success(0)], "received only first success")
        XCTAssertEqual(observedSuccess, [true, false], "unsubscribed from success signal")
        XCTAssertEqual(observedError, [true, false], "unsubscribed from error signal")

        // clean
        received.removeAll()
        observedSuccess.removeAll()
        observedError.removeAll()

        succesSubj.signal
            .join(withError: errorSubj.signal)
            .takeFirst()
            .observe { received.append($0) }
            .store(in: &cancellables)

        errorSubj.send(.foo)
        succesSubj.send(0)
        errorSubj.send(.bar)

        XCTAssertEqual(received, [.failure(.foo)], "received only first failure")
        XCTAssertEqual(observedSuccess, [true, false], "unsubscribed from success signal")
        XCTAssertEqual(observedError, [true, false], "unsubscribed from error signal")
    }
}
