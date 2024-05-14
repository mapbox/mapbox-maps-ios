import XCTest
@testable import MapboxMaps

final class DictionaryEncoderTests: XCTestCase {

    func testEncode() throws {
        let value = Everything(
            string: "test",
            int: -123456, int8: -123, int16: -12345, int32: -123456, int64: -123456789,
            uint: 123456, uint8: 123, uint16: 12345, uint32: 123456, uint64: 123456789,
            float: 123.456, double: 12345.6789,
            bool: true,
            date: Date(timeIntervalSinceReferenceDate: 123456.789),
            data: Data("test".utf8),
            url: URL(string: "dummy-mapbox.com")
        )

        let encoded = try DictionaryEncoder().encode(value)

        XCTAssertEqual(encoded["string"] as? String, value.string)
        XCTAssertEqual(encoded["int"] as? Int, value.int)
        XCTAssertEqual(encoded["int8"] as? Int8, value.int8)
        XCTAssertEqual(encoded["int16"] as? Int16, value.int16)
        XCTAssertEqual(encoded["int32"] as? Int32, value.int32)
        XCTAssertEqual(encoded["int64"] as? Int64, value.int64)
        XCTAssertEqual(encoded["uint"] as? UInt, value.uint)
        XCTAssertEqual(encoded["uint8"] as? UInt8, value.uint8)
        XCTAssertEqual(encoded["uint16"] as? UInt16, value.uint16)
        XCTAssertEqual(encoded["uint32"] as? UInt32, value.uint32)
        XCTAssertEqual(encoded["uint64"] as? UInt64, value.uint64)
        XCTAssertEqual(encoded["float"] as? Float, value.float)
        XCTAssertEqual(encoded["bool"] as? Bool, value.bool)
        XCTAssertEqual(encoded["date"] as? Double, value.date?.timeIntervalSinceReferenceDate)
        XCTAssertEqual(encoded["data"] as? String, value.data?.base64EncodedString())
        XCTAssertEqual(encoded["url"] as? String, value.url?.absoluteString)
    }

    // MARK: Encode Float

    func testEncodeInfinityFloat() throws {
        XCTAssertEqual(
            try DictionaryEncoder().encode(FloatEncodable(value: Float.infinity)) as? [String: Float],
            ["value": Float.infinity]
        )
    }

    func testEncodeNaNFloat() throws {
        let encodedDictionary = try XCTUnwrap(try DictionaryEncoder().encode(FloatEncodable(value: Float.nan)) as? [String: Float])
        XCTAssertTrue(encodedDictionary["value"]!.isNaN)
    }

    // MARK: Encode Double

    func testEncodeInfinityDouble() throws {
        XCTAssertEqual(
            try DictionaryEncoder().encode(DoubleEncodable(value: Double.infinity)) as? [String: Double],
            ["value": Double.infinity]
        )
    }

    func testEncodeNaNDouble() throws {
        let encodedDictionary = try XCTUnwrap(try DictionaryEncoder().encode(DoubleEncodable(value: Double.nan)) as? [String: Double])
        XCTAssertTrue(encodedDictionary["value"]!.isNaN)
    }

    func testEncodeNilAlways() throws {
        let sut = DictionaryEncoder()
        sut.shouldEncodeNilValues = true

        let value = Everything(
            string: nil,
            int: nil, int8: nil, int16: nil, int32: nil, int64: nil,
            uint: nil, uint8: nil, uint16: nil, uint32: nil, uint64: nil,
            float: nil, double: nil,
            bool: nil,
            date: nil,
            data: nil,
            url: nil
        )

        let encoded = try sut.encode(value)
        let allKeys = Everything.Keys.allCases.map(\.stringValue)

        func verify(element: Dictionary<String, Any>.Element) -> Bool {
            guard allKeys.contains(element.key) else { return false }

            switch element.value {
            case Optional<Any>.none: return true
            default: return false
            }
        }

        XCTAssertFalse(encoded.isEmpty)
        XCTAssertTrue(encoded.allSatisfy(verify(element:)))
        XCTAssertTrue(allKeys.allSatisfy(encoded.keys.contains(_:)))
    }

    func testEncodeNilOnlyIfPresent() throws {
        let sut = DictionaryEncoder()
        sut.shouldEncodeNilValues = false

        let value = Everything(
            string: nil,
            int: nil, int8: nil, int16: nil, int32: nil, int64: nil,
            uint: nil, uint8: nil, uint16: nil, uint32: nil, uint64: nil,
            float: nil, double: nil,
            bool: nil,
            date: nil,
            data: nil,
            url: nil
        )

        let encoded = try sut.encode(value)
        XCTAssertTrue(encoded.isEmpty)
    }

    func testEncodeNilNestedLevel() throws {
        struct TopLevel: Encodable {
            let everything: Everything?
        }

        let sut = DictionaryEncoder()
        sut.shouldEncodeNilValues = true

        let everything = Everything(
            string: nil,
            int: nil, int8: nil, int16: nil, int32: nil, int64: nil,
            uint: nil, uint8: nil, uint16: nil, uint32: nil, uint64: nil,
            float: nil, double: nil,
            bool: nil,
            date: nil,
            data: nil,
            url: nil
        )

        let encoded = try sut.encode(TopLevel(everything: everything))
        XCTAssertTrue(try XCTUnwrap(encoded["everything"] as? [String: Any]).isEmpty)
    }
}

// MARK: Supported Types.

private struct FloatEncodable: Encodable {
    let value: Float
}

private struct DoubleEncodable: Encodable {
    let value: Double
}

private struct Everything: Encodable {
    let string: String?
    let int: Int?
    let int8: Int8?
    let int16: Int16?
    let int32: Int32?
    let int64: Int64?
    let uint: UInt?
    let uint8: UInt8?
    let uint16: UInt16?
    let uint32: UInt32?
    let uint64: UInt64?
    let float: Float?
    let double: Double?
    let bool: Bool?
    let date: Date?
    let data: Data?
    let url: URL?

    enum Keys: String, CodingKey, CaseIterable {
        case string
        case int, int8, int16, int32, int64
        case uint, uint8, uint16, uint32, uint64
        case float, double
        case bool
        case date
        case data
        case url
    }
}
