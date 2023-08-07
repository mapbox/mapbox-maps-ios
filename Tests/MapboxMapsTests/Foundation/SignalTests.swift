import XCTest
import Combine
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

        let subject = SignalSubject<Int>()
        subject.onObserved = { observedValues.append($0) }
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
        let succesSubj = SignalSubject<Int>()
        succesSubj.onObserved = { observedSuccess.append($0) }
        let errorSubj = SignalSubject<MyError>()
        errorSubj.onObserved = { observedError.append($0) }

        var received = [Result<Int, MyError>]()
        let combined = succesSubj.signal
            .join(withError: errorSubj.signal)
            .takeFirst()

        XCTAssertEqual(observedSuccess, [], "operators don't lead to subscription")
        XCTAssertEqual(observedError, [], "operators don't lead to subscription")

        combined
            .observe { received.append($0) }
            .store(in: &cancellables)

        XCTAssertEqual(observedSuccess, [true], "observing leads to subscription")
        XCTAssertEqual(observedError, [true], "observing leads to subscription")

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

    func testCompactMap() {
        let subj = SignalSubject<String>()

        var received = [Int]()
        subj.signal
            .compactMap { Int($0) }
            .observe { received.append($0) }
            .store(in: &cancellables)

        subj.send("0")
        XCTAssertEqual(received, [0])

        subj.send("1")
        XCTAssertEqual(received, [0, 1])

        subj.send("foo")
        XCTAssertEqual(received, [0, 1])

        subj.send("2")
        XCTAssertEqual(received, [0, 1, 2])
    }

    func testSkipNil() {
        let subj = SignalSubject<String?>()

        var received = [String]()
        subj.signal.skipNil().observe {
            received.append($0)
        }.store(in: &cancellables)

        subj.send("a")
        XCTAssertEqual(received, ["a"])

        subj.send(nil)
        XCTAssertEqual(received, ["a"])

        subj.send("b")
        XCTAssertEqual(received, ["a", "b"])
    }

    func testJust() {
        let signal = Signal(just: 5)

        var observed = [Int]()
        let token = signal.observe { observed.append($0) }

        XCTAssertEqual(observed, [5])

        XCTAssertEqual(signal.latestValue, 5)
        XCTAssertEqual(observed, [5], "Access to latestValue didn't have any side effects")
        token.cancel()
    }

    @available(iOS 13.0, *)
    func testCombineSupport() {
        var tokens = Set<AnyCancellable>()

        var observedValues = [Bool]()
        let subject = SignalSubject<Int>()
        subject.onObserved = { observedValues.append($0) }

        let signal = subject.signal

        XCTAssertEqual(observedValues, [])

        var values1 = [Int]()
        signal.sink { value in
            values1.append(value)
        }.store(in: &tokens)

        XCTAssertEqual(observedValues, [true], "onObserved is idempotent")

        var values2 = [Int]()
        signal.sink { value in
            values2.append(value)
        }.store(in: &tokens)

        var values3 = [Int]()
        signal.observe { value in // non-combine syntax
            values3.append(value)
        }.store(in: &tokens)

        XCTAssertEqual(observedValues, [true], "onObserved is idempotent")

        subject.send(0)

        XCTAssertEqual(values1, [0])
        XCTAssertEqual(values2, [0])
        XCTAssertEqual(values3, [0])

        subject.send(1)

        XCTAssertEqual(values1, [0, 1])
        XCTAssertEqual(values2, [0, 1])
        XCTAssertEqual(values3, [0, 1])

        tokens.removeAll()
        XCTAssertEqual(observedValues, [true, false])

        var values4 = [Int]()
        signal.sink { value in
            values4.append(value)
        }.store(in: &tokens)

        subject.send(2)
        XCTAssertEqual(values1, [0, 1])
        XCTAssertEqual(values2, [0, 1])
        XCTAssertEqual(values3, [0, 1])
        XCTAssertEqual(values4, [2])
        XCTAssertEqual(observedValues, [true, false, true])

        tokens.removeAll()
        XCTAssertEqual(observedValues, [true, false, true, false])
    }

    @available(iOS 13.0, *)
    func testCombineSupportWithOperators() {
        var tokens = Set<AnyCancellable>()

        var observedValues = [Bool]()
        let subject = SignalSubject<Int>()
        subject.onObserved = { observedValues.append($0) }

        var values = [String]()
        let mapped = subject.signal
            .map { $0 * 2 }
            .map { String($0) }

        XCTAssertEqual(observedValues, [], "mapping doesn't lead to subscription")

        mapped.prefix(2)
            .sink { values.append($0) }
            .store(in: &tokens)

        XCTAssertEqual(observedValues, [true], "sink leads to subscription")

        subject.send(1)
        subject.send(2)

        XCTAssertEqual(observedValues, [true, false], "prefixed publisher cancels itself")

        subject.send(3)

        XCTAssertEqual(values, ["2", "4"])
    }

    @available(iOS 13.0, *)
    func testEraseToSignal() throws {
        let subject = CurrentValueSubject<Int?, Never>(1)
        let signal = subject
            .compactMap { $0 }
            .map { "\($0)" }
            .eraseToSignal()

        var observed = [String]()
        signal.observe { observed.append($0) }.store(in: &cancellables)

        subject.value = 1
        subject.value = 42
        subject.value = nil
        subject.value = 5

        XCTAssertEqual(observed, ["1", "1", "42", "5"])

        XCTAssertEqual(try XCTUnwrap(signal.latestValue), "5")
    }
}
