import XCTest
@testable import MapboxMaps

class UIEdgeInsetsCodableTest: XCTestCase {
    func testEquatableSupport() throws {
        let value1 = UIEdgeInsetsCodable(top: 10, left: 11, bottom: 12, right: 13)
        let value2 = UIEdgeInsetsCodable(top: 20, left: 21, bottom: 22, right: 23)
        let value3 = UIEdgeInsetsCodable(top: 10, left: 11, bottom: 12, right: 13)

        XCTAssertNotEqual(value1, value2)
        XCTAssertNotEqual(value3, value2)
        XCTAssertEqual(value1, value3)
    }

    func testHashableSupport() throws {
        let value1 = UIEdgeInsetsCodable(top: 10, left: 11, bottom: 12, right: 13)
        let value2 = UIEdgeInsetsCodable(top: 20, left: 21, bottom: 22, right: 23)
        let value3 = UIEdgeInsetsCodable(top: 10, left: 11, bottom: 12, right: 13)

        var dict: [AnyHashable: String] = [:]
        dict[value1] = "value1"
        dict[value2] = "value2"
        dict[value3] = "value3"

        XCTAssertEqual(dict.count, 2)
        XCTAssertEqual(dict[value1], "value3")
        XCTAssertEqual(dict[value2], "value2")
        XCTAssertEqual(dict[value3], "value3")
    }

    func testCodableSupport() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let value = UIEdgeInsetsCodable(top: .greatestFiniteMagnitude,
                                        left: .greatestFiniteMagnitude,
                                        bottom: .leastNormalMagnitude,
                                        right: .leastNormalMagnitude)

        let data = try encoder.encode(value)
        let decodedValue = try decoder.decode(UIEdgeInsetsCodable.self, from: data)

        XCTAssertEqual(value, decodedValue)
    }

    func testUIEdgeInsetsConversion() throws {
        let value = UIEdgeInsets.random()
        let codableValue = UIEdgeInsetsCodable(value)

        XCTAssertEqual(value, codableValue.edgeInsets)
    }

    func testUIEdgeInsetsMutation() throws {
        let value = UIEdgeInsets(top: 10, left: 11, bottom: 12, right: 13)
        let newValue = UIEdgeInsets(top: 20, left: 21, bottom: 22, right: 23)
        var codableValue = UIEdgeInsetsCodable(value)
        codableValue.edgeInsets = newValue

        XCTAssertEqual(codableValue.edgeInsets, newValue)
        XCTAssertNotEqual(codableValue.edgeInsets, value)
    }
}
