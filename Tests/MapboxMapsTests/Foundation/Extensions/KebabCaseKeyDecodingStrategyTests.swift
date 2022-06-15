import XCTest
import Foundation
@testable import MapboxMaps

class KebabCaseKeyDecodingStrategyTests: XCTestCase {
    private struct TestingKey: CodingKey {
        var stringValue: String
        var intValue: Int?

        init?(stringValue: String) {
            self.stringValue = stringValue
            self.intValue = nil
        }

        init?(intValue: Int) {
            self.stringValue = String(intValue)
            self.intValue = intValue
        }

        init(_ value: String) {
            self.stringValue = value
        }
    }

    func testStringConversion() throws {
        guard case let JSONDecoder.KeyDecodingStrategy.custom(converter) = .convertFromKebabCase else {
            XCTFail("Kebab case strategy is a not custom decoding strategy.")
            return
        }

        XCTAssertEqual(converter([TestingKey("")]).stringValue, "")
        XCTAssertEqual(converter([TestingKey("key")]).stringValue, "key")
        XCTAssertEqual(converter([TestingKey("-key")]).stringValue, "key")
        XCTAssertEqual(converter([TestingKey("key-")]).stringValue, "key")
        XCTAssertEqual(converter([TestingKey("-key-")]).stringValue, "key")
        XCTAssertEqual(converter([TestingKey("a-key")]).stringValue, "aKey")
        XCTAssertEqual(converter([TestingKey("a-long-key")]).stringValue, "aLongKey")
        XCTAssertEqual(converter([TestingKey("a-very-long-key")]).stringValue, "aVeryLongKey")
        XCTAssertEqual(converter([TestingKey("12-3-a-numkey")]).stringValue, "123ANumkey")
        XCTAssertEqual(converter([TestingKey("a-numkey-1-23")]).stringValue, "aNumkey123")
    }

    func testIntConversion() throws {
        guard case let JSONDecoder.KeyDecodingStrategy.custom(converter) = .convertFromKebabCase else {
            XCTFail("Kebab case strategy is a not custom decoding strategy.")
            return
        }

        XCTAssertEqual(converter([TestingKey(intValue: 10325346)!]).stringValue, "10325346")
    }

    func testMultipleKeys() throws {
        guard case let JSONDecoder.KeyDecodingStrategy.custom(converter) = .convertFromKebabCase else {
            XCTFail("Kebab case strategy is a not custom decoding strategy.")
            return
        }

        XCTAssertEqual(converter([TestingKey("first-key"), TestingKey("second-key")]).stringValue, "secondKey")
    }
}
