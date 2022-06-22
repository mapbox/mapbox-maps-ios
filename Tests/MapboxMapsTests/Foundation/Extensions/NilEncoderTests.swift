import XCTest
@testable import MapboxMaps

final class NilEncoderTests: XCTestCase {

    func testEncodeNilOnlyIfPresent() throws {
        let sut = NilEncoder(shouldEncodeNil: false)
        var encoder = MockKeyedEncodingContainer()
        var valueToEncode: Int? = 1

        try sut.encode(valueToEncode, forKey: .one, to: &encoder)
        XCTAssertEqual(encoder.encodeStub.invocations.last?.parameters.value as? Int, valueToEncode)
        XCTAssertEqual(encoder.encodeStub.invocations.last?.parameters.key, .one)

        encoder.encodeStub.reset()
        valueToEncode = nil
        try sut.encode(valueToEncode, forKey: .one, to: &encoder)
        XCTAssertTrue(encoder.encodeStub.invocations.isEmpty)
    }

    func testEncodeNilAlways() throws {
        let sut = NilEncoder(shouldEncodeNil: true)
        var encoder = MockKeyedEncodingContainer()
        let valueToEncode: Int? = nil

        try sut.encode(valueToEncode, forKey: .one, to: &encoder)
        XCTAssertEqual(encoder.encodeStub.invocations.last?.parameters.value as? Int, valueToEncode)
        XCTAssertEqual(encoder.encodeStub.invocations.last?.parameters.key, .one)
    }
}

private class MockKeyedEncodingContainer: KeyedEncodingContainerProtocol {
    enum Key: String, CodingKey {
        case one
    }
    var codingPath: [CodingKey] = []

    let encodeNilStub = Stub<Key, Void>()
    func encodeNil(forKey key: Key) throws {
        encodeNilStub.call(with: key)
    }

    struct EncodeParameters {
        let value: Encodable
        let key: Key
    }
    let encodeStub = Stub<EncodeParameters, Void>()

    func encode(_ value: Bool, forKey key: Key) throws {
        encodeStub.call(with: EncodeParameters(value: value, key: key))
    }

    func encode(_ value: String, forKey key: Key) throws {
        encodeStub.call(with: EncodeParameters(value: value, key: key))
    }

    func encode(_ value: Double, forKey key: Key) throws {
        encodeStub.call(with: EncodeParameters(value: value, key: key))
    }

    func encode(_ value: Float, forKey key: Key) throws {
        encodeStub.call(with: EncodeParameters(value: value, key: key))
    }

    func encode(_ value: Int, forKey key: Key) throws {
        encodeStub.call(with: EncodeParameters(value: value, key: key))
    }

    func encode(_ value: Int8, forKey key: Key) throws {
        encodeStub.call(with: EncodeParameters(value: value, key: key))
    }

    func encode(_ value: Int16, forKey key: Key) throws {
        encodeStub.call(with: EncodeParameters(value: value, key: key))
    }

    func encode(_ value: Int32, forKey key: Key) throws {
        encodeStub.call(with: EncodeParameters(value: value, key: key))
    }

    func encode(_ value: Int64, forKey key: Key) throws {
        encodeStub.call(with: EncodeParameters(value: value, key: key))
    }

    func encode(_ value: UInt, forKey key: Key) throws {
        encodeStub.call(with: EncodeParameters(value: value, key: key))
    }

    func encode(_ value: UInt8, forKey key: Key) throws {
        encodeStub.call(with: EncodeParameters(value: value, key: key))
    }

    func encode(_ value: UInt16, forKey key: Key) throws {
        encodeStub.call(with: EncodeParameters(value: value, key: key))
    }

    func encode(_ value: UInt32, forKey key: Key) throws {
        encodeStub.call(with: EncodeParameters(value: value, key: key))
    }

    func encode(_ value: UInt64, forKey key: Key) throws {
        encodeStub.call(with: EncodeParameters(value: value, key: key))
    }

    func encode<T>(_ value: T, forKey key: Key) throws where T: Encodable {
        encodeStub.call(with: EncodeParameters(value: value, key: key))
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        fatalError()
    }

    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        fatalError()
    }

    func superEncoder() -> Encoder {
        fatalError()
    }

    func superEncoder(forKey key: Key) -> Encoder {
        fatalError()
    }
}
