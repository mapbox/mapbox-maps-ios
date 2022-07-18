import XCTest
@testable import MapboxMaps

final class DictionaryEncoderTests: XCTestCase {

    // MARK: Encode Integers.

    func testEncodeInt() throws {
        let intValue = Int.random(in: Int.min...Int.max)
        XCTAssertEqual(
            try DictionaryEncoder().encode(DummyEncodable(value: intValue)) as? [String: Int],
            ["value": intValue]
        )
    }

    func testEncodeInt8() throws {
        let int8Value = Int8.random(in: Int8.min...Int8.max)
        XCTAssertEqual(
            try DictionaryEncoder().encode(DummyEncodable(value: int8Value)) as? [String: Int8],
            ["value": int8Value]
        )
    }

    func testEncodeInt16() throws {
        let int16Value = Int16.random(in: Int16.min...Int16.max)
        XCTAssertEqual(
            try DictionaryEncoder().encode(DummyEncodable(value: int16Value)) as? [String: Int16],
            ["value": int16Value]
        )
    }

    func testEncodeInt32() throws {
        let int32Value = Int32.random(in: Int32.min...Int32.max)
        XCTAssertEqual(
            try DictionaryEncoder().encode(DummyEncodable(value: int32Value)) as? [String: Int32],
            ["value": int32Value]
        )
    }

    func testEncodeInt64() throws {
        let int64Value = Int64.random(in: Int64.min...Int64.max)
        XCTAssertEqual(
            try DictionaryEncoder().encode(DummyEncodable(value: int64Value)) as? [String: Int64],
            ["value": int64Value]
        )
    }

    func testEncodeUInt() throws {
        let uintValue = UInt.random(in: UInt.min...UInt.max)
        XCTAssertEqual(
            try DictionaryEncoder().encode(DummyEncodable(value: uintValue)) as? [String: UInt],
            ["value": uintValue]
        )
    }

    func testEncodeUInt8() throws {
        let uint8Value = UInt8.random(in: UInt8.min...UInt8.max)
        XCTAssertEqual(
            try DictionaryEncoder().encode(DummyEncodable(value: uint8Value)) as? [String: UInt8],
            ["value": uint8Value]
        )
    }

    func testEncodeUInt16() throws {
        let uint16Value = UInt16.random(in: UInt16.min...UInt16.max)
        XCTAssertEqual(
            try DictionaryEncoder().encode(DummyEncodable(value: uint16Value)) as? [String: UInt16],
            ["value": uint16Value]
        )
    }

    func testEncodeUInt32() throws {
        let uint32Value = UInt32.random(in: UInt32.min...UInt32.max)
        XCTAssertEqual(
            try DictionaryEncoder().encode(DummyEncodable(value: uint32Value)) as? [String: UInt32],
            ["value": uint32Value]
        )
    }

    func testEncodeUInt64() throws {
        let uint64Value = UInt64.random(in: UInt64.min...UInt64.max)
        XCTAssertEqual(
            try DictionaryEncoder().encode(DummyEncodable(value: uint64Value)) as? [String: UInt64],
            ["value": uint64Value]
        )
    }

    // MARK: Encode Float

    func testEncodeFloat() throws {
        let floatValue = Float.random(in: 0...100)
        XCTAssertEqual(
            try DictionaryEncoder().encode(DummyEncodable(value: floatValue)) as? [String: Float],
            ["value": floatValue]
        )

        XCTAssertEqual(
            try DictionaryEncoder().encode(DummyEncodable(value: Float.infinity)) as? [String: Float],
            ["value": Float.infinity]
        )
    }

    func testEncodeNaNFloat() throws {
        let encodedDictionary = try XCTUnwrap(try DictionaryEncoder().encode(DummyEncodable(value: Float.nan)) as? [String: Float])
        XCTAssertTrue(encodedDictionary["value"]!.isNaN)
    }

    // MARK: Encode Double

    func testEncodeDouble() throws {
        let doubleValue = Double.random(in: 0...100)
        XCTAssertEqual(
            try DictionaryEncoder().encode(DummyEncodable(value: doubleValue)) as? [String: Double],
            ["value": doubleValue]
        )

        XCTAssertEqual(
            try DictionaryEncoder().encode(DummyEncodable(value: Double.infinity)) as? [String: Double],
            ["value": Double.infinity]
        )
    }

    func testEncodeNaNDouble() throws {
        let encodedDictionary = try XCTUnwrap(try DictionaryEncoder().encode(DummyEncodable(value: Double.nan)) as? [String: Double])
        XCTAssertTrue(encodedDictionary["value"]!.isNaN)
    }

    // MARK: Encode Others

    func testEncodeString() throws {
        let stringValue = String.randomAlphanumeric(withLength: 10)
        XCTAssertEqual(
            try DictionaryEncoder().encode(DummyEncodable(value: stringValue)) as? [String: String],
            ["value": stringValue]
        )
    }

    func testEncodeData() throws {
        let data = try XCTUnwrap(String.randomAlphanumeric(withLength: 10).data(using: .utf8))
        XCTAssertEqual(
            try DictionaryEncoder().encode(DummyEncodable(value: data)) as? [String: Data],
            ["value": data]
        )
    }

    func testEncodeURL() throws {
        let url = URL(string: "dummy-mapbox.com")!
        XCTAssertEqual(
            try DictionaryEncoder().encode(DummyEncodable(value: url)) as? [String: URL],
            ["value": url]
        )
    }

    func testEncodeDate() throws {
        let date = Date(timeIntervalSince1970: .random(in: 0...100))
        XCTAssertEqual(
            try DictionaryEncoder().encode(DummyEncodable(value: date)) as? [String: Date],
            ["value": date]
        )
    }

    func testEncodeNilAlways() throws {
        let sut = DictionaryEncoder()
        sut.userInfo[.shouldEncodeNilValues] = true

        XCTAssertEqual(
            try sut.encode(DummyNilable(value: "hilla")) as? [String: String?],
            ["value": "hilla"]
        )
        XCTAssertEqual(
            try sut.encode(DummyNilable<String>(value: nil)) as? [String: String?],
            ["value": nil]
        )
    }

    func testEncodeNilOnlyIfPresent() throws {
        let sut = DictionaryEncoder()
        sut.userInfo[.shouldEncodeNilValues] = false

        XCTAssertEqual(
            try sut.encode(DummyNilable(value: "hilla")) as? [String: String?],
            ["value": "hilla"]
        )
        XCTAssertEqual(
            try sut.encode(DummyNilable<String>(value: nil)) as? [String: String?],
            [:]
        )
    }
}

// MARK: Supported Types.

private struct DummyEncodable<T: Encodable>: Encodable {
    let value: T
}

private struct DummyNilable<T: Encodable>: Encodable {
    let value: T?

    enum Keys: String, CodingKey {
        case value
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Keys.self)
        try container.encodeIfPresent(value, forKey: .value)
    }
}
