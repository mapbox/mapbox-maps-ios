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

    func testMap() {
        let subj = SignalSubject<Int>()

        var received = [Int]()
        subj.signal
            .map { $0 * 2 }
            .observe { received.append($0) }
            .store(in: &cancellables)

        subj.send(1)
        XCTAssertEqual(received, [2])

        subj.send(2)
        XCTAssertEqual(received, [2, 4])
    }

    func testHandle() {
        class Handler {
            var received = [Int]()
            var token: AnyCancelable?
            init(_ signal: Signal<Int>) {
                token = signal.handle(in: Handler.handle, ofWeak: self)
            }
            func handle(_ payload: Int) {
                received.append(payload)
            }
        }

        let subj = SignalSubject<Int>()
        let handler = Handler(subj.signal)
        subj.send(0)
        subj.send(1)
        subj.send(2)
        XCTAssertEqual(handler.received, [0, 1, 2])
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

    func testRetaining() {
        let subj = SignalSubject<Int>()
        var token: AnyCancelable?

        weak var weakObject: ObjectWrapper<Int>?
        do {
            let object = ObjectWrapper(subject: 1)
            weakObject = object

            var received = [Int]()
            token = subj.signal
                .retaining(object)
                .map { $0 * 2 }
                .observe { received.append($0) }

            subj.send(2)
            XCTAssertEqual(received, [4])
        }

        XCTAssertNotNil(weakObject)

        token?.cancel()
        XCTAssertNil(weakObject)
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

    func testCombineLatest() {
        let subject1 = SignalSubject<Int>()
        let subject2 = SignalSubject<Int>()

        typealias P = Pair<Int, Int>

        var received = [P]()
        let token = Signal.combineLatest(subject1.signal, subject2.signal)
            .observe { received.append(Pair($0)) }

        subject1.send(1)
        XCTAssertEqual(received, [])

        subject2.send(2)
        XCTAssertEqual(received, [P(1, 2)])

        subject1.send(3)
        XCTAssertEqual(received, [P(1, 2), P(3, 2)])

        subject2.send(4)
        XCTAssertEqual(received, [P(1, 2), P(3, 2), P(3, 4)])

        subject2.send(5)
        XCTAssertEqual(received, [P(1, 2), P(3, 2), P(3, 4), P(3, 5)])

        token.cancel()

        subject1.send(6)
        subject1.send(7)
        XCTAssertEqual(received, [Pair(1, 2), Pair(3, 2), Pair(3, 4), Pair(3, 5)])
    }

    func testObserveWithCancellingHandler() {
        let subj = SignalSubject<Int>()

        var received = [Int]()
        let token = subj.signal.observeWithCancellingHandler { value in
            received.append(value)
            return value < 3
        }

        subj.send(1)
        subj.send(2)
        subj.send(3)
        subj.send(4)

        XCTAssertEqual(received, [1, 2, 3])
        token.cancel()
    }

    func testObserveWithCancellingHandlerSynchronous() {
        let subj = CurrentValueSignalSubject<Int>(1)
        var received = [Int]()

        weak var weakObject: ObjectWrapper<Int>?
        do {
            let object = ObjectWrapper(subject: 1)
            weakObject = object

          _ = subj.signal.observeWithCancellingHandler { value in
                XCTAssertEqual(object.subject, 1)
                received.append(value)
                return value != 1
            }
        }

        subj.value = 2
        XCTAssertEqual(received, [1])
        XCTAssertNil(weakObject)
    }

    func testSkipRepeats() {
        let subj = SignalSubject<Int>()

        var received = [Int]()
        subj.signal
            .skipRepeats()
            .observe { received.append($0) }
            .store(in: &cancellables)

        subj.send(1)
        XCTAssertEqual(received, [1])

        subj.send(1)
        XCTAssertEqual(received, [1])

        subj.send(2)
        XCTAssertEqual(received, [1, 2])
    }

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

    func testAssign() {
        class TestClass {
            var value: Int = 0
        }

        let testObject = TestClass()
        let subj = SignalSubject<Int>()

        let token = subj.signal.assign(to: \.value, ofWeak: testObject)

        subj.send(1)
        XCTAssertEqual(testObject.value, 1)

        subj.send(2)
        XCTAssertEqual(testObject.value, 2)

        token.cancel()

        subj.send(3)
        XCTAssertEqual(testObject.value, 2)
    }
}

private struct Pair<T: Equatable, U: Equatable>: Equatable {
    let first: T
    let second: U

    init(_ first: T, _ second: U) {
        self.first = first
        self.second = second
    }

    init(_ pair: (T, U)) {
        self.init(pair.0, pair.1)
    }
}
