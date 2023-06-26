import XCTest
@testable import MapboxMaps

class CGPointCodableTest: XCTestCase {
    func testEquatableSupport() throws {
        let value1 = CGPointCodable(x: 10, y: 11)
        let value2 = CGPointCodable(x: 20, y: 21)
        let value3 = CGPointCodable(x: 10, y: 11)

        XCTAssertNotEqual(value1, value2)
        XCTAssertNotEqual(value3, value2)
        XCTAssertEqual(value1, value3)
    }

    func testHashableSupport() throws {
        let value1 = CGPointCodable(x: 10, y: 11)
        let value2 = CGPointCodable(x: 20, y: 21)
        let value3 = CGPointCodable(x: 10, y: 11)

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

        let value = CGPointCodable(x: .greatestFiniteMagnitude,
                                   y: .leastNormalMagnitude)

        let data = try encoder.encode(value)
        let decodedValue = try decoder.decode(CGPointCodable.self, from: data)

        XCTAssertEqual(value.x, decodedValue.x)
        XCTAssertEqual(value.y, decodedValue.y)
        XCTAssertEqual(value, decodedValue)
    }

    func testCGPointConversion() throws {
        let value = CGPoint.random()
        let codableValue = CGPointCodable(value)

        XCTAssertEqual(value, codableValue.point)
    }

    func testCGPointMutation() throws {
        let value = CGPoint(x: 42, y: 666)
        let newValue = CGPoint(x: 21, y: 333)
        var codableValue = CGPointCodable(value)
        codableValue.point = newValue

        XCTAssertEqual(codableValue.point, newValue)
        XCTAssertNotEqual(codableValue.point, value)
    }
}
