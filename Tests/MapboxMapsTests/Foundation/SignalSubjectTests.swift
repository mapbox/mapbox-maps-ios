import XCTest
@testable import MapboxMaps

final class SignalSubjectTests: XCTestCase {
    var cancellables = Set<AnyCancelable>()

    override func tearDown() {
        cancellables.removeAll()
    }

    func testSend() {
        let subject = SignalSubject<String>()
        let stub1 = Stub<String, Void>()
        let stub2 = Stub<String, Void>()

        let c1 = subject.signal.observe(stub1.call(with:))
        cancellables.insert(c1)
        subject.signal.observe(stub2.call(with:)).store(in: &cancellables)

        subject.send("Foo")
        XCTAssertEqual(stub1.invocations.count, 1)
        XCTAssertEqual(stub1.invocations[0].parameters, "Foo")
        XCTAssertEqual(stub2.invocations.count, 1)
        XCTAssertEqual(stub2.invocations[0].parameters, "Foo")

        c1.cancel()

        subject.send("Bar")
        XCTAssertEqual(stub1.invocations.count, 1)
        XCTAssertEqual(stub2.invocations.count, 2)
        XCTAssertEqual(stub2.invocations[1].parameters, "Bar")

        cancellables.removeAll()

        subject.send("Bar")
        XCTAssertEqual(stub1.invocations.count, 1)
        XCTAssertEqual(stub2.invocations.count, 2)
    }

    func testOnObservedCallback() {
        var observed = false
        var observedCalls = 0
        let subject = SignalSubject<Int>()
        subject.onObserved = { obs in
            observed = obs
            observedCalls += 1
        }

        XCTAssertEqual(observedCalls, 0)

        subject.signal.observe({ _ in }).store(in: &cancellables)
        XCTAssertEqual(observedCalls, 1)
        XCTAssertTrue(observed)

        subject.signal.observe({ _ in }).store(in: &cancellables)
        let c = subject.signal.observe({ _ in })
        cancellables.insert(c)
        XCTAssertEqual(observedCalls, 1)
        XCTAssertTrue(observed)

        c.cancel()
        XCTAssertEqual(observedCalls, 1)

        cancellables.removeAll()
        XCTAssertEqual(observedCalls, 2)
        XCTAssertFalse(observed)
    }

    func testCancellationUponNotification() {
        weak var cancellable: AnyCancelable?

        var observedValues = [Bool]()
        var values = [Int]()

        let subject = SignalSubject<Int>()
        subject.onObserved = { observed in
            observedValues.append(observed)
        }

        let c = subject.signal.observe { newValue in
            values.append(newValue)
            cancellable?.cancel()
        }
        cancellable = c
        cancellables.insert(c)

        XCTAssertEqual(observedValues, [true])
        XCTAssertEqual(values, [])

        subject.send(0)
        XCTAssertEqual(observedValues, [true, false])
        XCTAssertEqual(values, [0])

        subject.send(1)
        XCTAssertEqual(values, [0])
    }

    func testNewSubscriptionUponNotification() {
        var values = [Int]()
        var innerValues = [Int]()

        let subject = SignalSubject<Int>()

        subject.signal.observeNext { [weak subject, weak self] newValue in
            values.append(newValue)
            guard let subject = subject, let self = self else { return }
            subject.signal.observe { newValue in
                innerValues.append(newValue)
            }.store(in: &self.cancellables)
        }.store(in: &cancellables)

        XCTAssertEqual(values, [])
        XCTAssertEqual(innerValues, [])

        subject.send(0)
        XCTAssertEqual(values, [0])
        XCTAssertEqual(innerValues, [])

        subject.send(1)
        XCTAssertEqual(values, [0])
        XCTAssertEqual(innerValues, [1])

        subject.send(2)
        XCTAssertEqual(values, [0])
        XCTAssertEqual(innerValues, [1, 2])

        cancellables.removeAll()

        subject.send(2)
        XCTAssertEqual(values, [0])
        XCTAssertEqual(innerValues, [1, 2])
    }

    func testInitWithObserveMethod() {
        let producer = MockEventsProducer()

        let fooSubject = SignalSubject.from(parameter: "foo", method: producer.subscribe(toEvent:handler:))
        let barSubject = SignalSubject.from(parameter: "bar", method: producer.subscribe(toEvent:handler:))

        var fooValues = [String]()
        var barValues = [String]()
        fooSubject.signal.observe { newValue in
            fooValues.append(newValue)
        }.store(in: &cancellables)
        barSubject.signal.observe { newValue in
            barValues.append(newValue)
        }.store(in: &cancellables)

        producer.send(name: "foo", payload: "a")
        producer.send(name: "bar", payload: "b")

        XCTAssertEqual(fooValues, ["a"])
        XCTAssertEqual(barValues, ["b"])

        producer.send(name: "foo", payload: "c")
        producer.send(name: "foo", payload: "d")
        producer.send(name: "bar", payload: "e")
        producer.send(name: "bar", payload: "f")

        XCTAssertEqual(fooValues, ["a", "c", "d"])
        XCTAssertEqual(barValues, ["b", "e", "f"])

        cancellables.removeAll()
        producer.send(name: "foo", payload: "x")
        producer.send(name: "bar", payload: "x")

        XCTAssertEqual(fooValues, ["a", "c", "d"])
        XCTAssertEqual(barValues, ["b", "e", "f"])
    }

    func testForEach() {
        let store = ClosureHandlersStore<Int, Bool>()

        var observed1 = [Int]()
        store.add { value in
            observed1.append(value)
            return value < 0 // Don't let the following observers to handle negative values.
        }.store(in: &cancellables)

        var observed2 = [Int]()
        store.add { value in
            observed2.append(value)
            return true
        }.store(in: &cancellables)

        store.forEach { $0(-21) }
        store.forEach { $0(2) }
        store.forEach { $0(3) }
        store.forEach { $0(-1) }
        store.forEach { $0(5) }

        XCTAssertEqual(observed1, [-21, 2, 3, -1, 5])
        XCTAssertEqual(observed2, [2, 3, 5])
    }
}

private class MockEventsProducer {
    private var subjects = [String: SignalSubject<String>]()
    func subscribe(toEvent name: String, handler: @escaping (String) -> Void) -> Cancelable {
        let subject = SignalSubject<String>()
        subjects[name] = subject
        return subject.signal.observe(handler)
    }

    func send(name: String, payload: String) {
        subjects[name]?.send(payload)
    }
}
