import XCTest
@testable import MapboxMaps

class CurrentValueSignalProxyTests: XCTestCase {
    func testProxy() {
        var s1Observed = [Bool]()
        var s2Observed = [Bool]()
        let s1 = SignalSubject<Int>()
        let s2 = CurrentValueSignalSubject<Int>(42)

        s1.onObserved = { s1Observed.append($0) }
        s2.onObserved = { s2Observed.append($0) }

        let proxy = CurrentValueSignalProxy<Int>()

        proxy.proxied = s2.signal
        proxy.proxied = s1.signal

        // Proxy don't eagerly observe proxied signal.
        XCTAssertEqual(s1Observed, [])
        XCTAssertEqual(s2Observed, [])

        var observedValues = [Int]()
        let token = proxy.signal.observe { observedValues.append($0) }

        XCTAssertEqual(s1Observed, [true])
        XCTAssertEqual(s2Observed, [])
        XCTAssertEqual(observedValues, [])

        s1.send(1)
        XCTAssertEqual(observedValues, [1])

        s1.send(2)
        XCTAssertEqual(observedValues, [1, 2])

        proxy.proxied = s2.signal

        XCTAssertEqual(s1Observed, [true, false])
        XCTAssertEqual(s2Observed, [true])
        XCTAssertEqual(observedValues, [1, 2, 42])

        s1.send(2)
        s2.value = 43
        s2.value = 43

        XCTAssertEqual(observedValues, [1, 2, 42, 43, 43])

        proxy.proxied = nil
        XCTAssertEqual(s2Observed, [true, false])

        proxy.proxied = s1.signal
        XCTAssertEqual(observedValues, [1, 2, 42, 43, 43])

        s1.send(3)
        token.cancel()

        XCTAssertEqual(observedValues, [1, 2, 42, 43, 43, 3])
        XCTAssertEqual(s1Observed, [true, false, true, false])
        XCTAssertEqual(s2Observed, [true, false])
    }

    func testMultipleObservers() {
        let source = CurrentValueSignalSubject(5)
        let proxy = CurrentValueSignalProxy<Int>()

        proxy.proxied = source.signal

        var observed1 = [Int]()
        var observed2 = [Int]()
        var tokens = Set<AnyCancelable>()
        proxy.signal.observe { observed1.append($0) }.store(in: &tokens)
        proxy.signal.observe { observed2.append($0) }.store(in: &tokens)

        XCTAssertEqual(observed1, observed2)
        XCTAssertEqual(observed1, [5])
        XCTAssertEqual(proxy.signal.latestValue, 5)

        source.value = 42

        XCTAssertEqual(observed1, observed2)
        XCTAssertEqual(observed1, [5, 42])
        XCTAssertEqual(proxy.signal.latestValue, 42)

        proxy.proxied = Signal(just: 3)

        XCTAssertEqual(observed1, observed2)
        XCTAssertEqual(observed1, [5, 42, 3])
        XCTAssertEqual(proxy.signal.latestValue, 3)

        tokens.removeAll()

        XCTAssertEqual(proxy.signal.latestValue, 3)

        proxy.proxied = Signal(just: 5)
        XCTAssertEqual(proxy.signal.latestValue, 5)
    }

    func testLazyObserving() {
        let source = SignalSubject<Int>()
        let proxy = CurrentValueSignalProxy<Int>()

        proxy.proxied = source.signal
        source.send(1)

        XCTAssertEqual(proxy.signal.latestValue, nil, "no observation during the send")

        var observed = [Int]()
        var token = proxy.signal.observe { observed.append($0) }

        source.send(2)
        XCTAssertEqual(observed, [2])
        XCTAssertEqual(proxy.signal.latestValue, 2)

        token.cancel()

        source.send(3)
        source.send(5)

        XCTAssertEqual(proxy.signal.latestValue, 2, "no observation during the send")

        token = proxy.signal.observe { observed.append($0) }
        source.send(8)
        source.send(13)
        token.cancel()

        XCTAssertEqual(observed, [2, 2, 8, 13])
    }
}
