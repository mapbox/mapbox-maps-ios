import XCTest
@testable import MapboxMaps

final class CurrentValueSignalSubjectTests: XCTestCase {
    var cancellables = Set<AnyCancelable>()

    override func tearDown() {
        cancellables.removeAll()
    }

    func testBasicCases() {
        let subj = CurrentValueSignalSubject(5)
        let signal = subj.signal
        XCTAssertEqual(subj.value, 5)

        var values = [Int]()
        signal.observe { v in
            values.append(v)
        }.store(in: &cancellables)

        XCTAssertEqual(values, [5])

        subj.value = 5
        XCTAssertEqual(values, [5, 5])

        subj.value = 6
        XCTAssertEqual(values, [5, 5, 6])

        subj.value = 7
        XCTAssertEqual(values, [5, 5, 6, 7])

        XCTAssertEqual(signal.latestValue, 7)
    }

    func testNullable() {
        let subj = CurrentValueSignalSubject<Int?>(5)
        let signal = subj.signal
        XCTAssertEqual(subj.value, 5)

        var values = [Int?]()
        signal.observe { v in
            values.append(v)
        }.store(in: &cancellables)

        XCTAssertEqual(values, [5])

        subj.value = nil
        XCTAssertEqual(values, [5, nil])

        subj.value = nil
        XCTAssertEqual(values, [5, nil, nil])

        var values2 = [Int?]()
        signal.observe { v in
            values2.append(v)
        }.store(in: &cancellables)
        XCTAssertEqual(values2, [nil])

        subj.value = 42
        XCTAssertEqual(values2, [nil, 42])
        XCTAssertEqual(values, [5, nil, nil, 42])
    }

    func testOnObserved() {
        var values1 = [String]()
        var values2 = [String]()
        var obObservedValues = [Bool]()
        let subj = CurrentValueSignalSubject<String>("foo")
        subj.onObserved = { observed in
            obObservedValues.append(observed)
        }

        XCTAssertEqual(obObservedValues, [])

        subj.signal.observe {
            values1.append($0)
        }.store(in: &cancellables)

        XCTAssertEqual(values1, ["foo"])
        XCTAssertEqual(obObservedValues, [true])

        subj.value = "bar"

        let t = subj.signal.observe {
            values2.append($0)
        }
        t.store(in: &cancellables)

        XCTAssertEqual(values1, ["foo", "bar"])
        XCTAssertEqual(values2, ["bar"])
        XCTAssertEqual(obObservedValues, [true])

        t.cancel()

        XCTAssertEqual(obObservedValues, [true])

        cancellables.removeAll()

        XCTAssertEqual(obObservedValues, [true, false])
    }
}
