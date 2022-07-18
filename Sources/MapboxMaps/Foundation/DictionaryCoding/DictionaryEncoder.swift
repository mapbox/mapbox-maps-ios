import Foundation

private protocol EncoderContainer {
    func toAny() throws -> Any
}

internal final class DictionaryEncoder {
    var userInfo: [CodingUserInfoKey: Any] = [:]
    init() {}

    func encode<T>(_ value: T) throws -> [String: Any] where T: Encodable {
        guard let dictionary = try Encoder(userInfo: userInfo).encode(value) as? [String: Any] else {
            throw Error.unexpectedType
        }

        return dictionary
    }

    enum Error: Swift.Error {
        case unexpectedType
        case incomplete(at: [CodingKey])
    }

    private static func isSupportedType<T: Encodable>(_ type: T.Type) -> Bool {
        T.self == Data.self || T.self == NSData.self ||
        T.self == Date.self || T.self == NSDate.self ||
        T.self == Decimal.self || T.self == NSDecimalNumber.self ||
        T.self == URL.self || T.self == NSURL.self
    }
}

private extension DictionaryEncoder {

    enum Storage: EncoderContainer {
        case value(Any)
        case container(EncoderContainer)

        func toAny() throws -> Any {
            switch self {
            case .value(let value): return value
            case .container(let container): return try container.toAny()
            }
        }
    }

    final class Encoder: Swift.Encoder, EncoderContainer {
        let codingPath: [CodingKey]
        let userInfo: [CodingUserInfoKey: Any]

        private(set) var container: EncoderContainer? {
            didSet { precondition(oldValue == nil) }
        }

        init(codingPath: [CodingKey] = [], userInfo: [CodingUserInfoKey: Any]) {
            self.codingPath = codingPath
            self.userInfo = userInfo
        }

        func toAny() throws -> Any {
            guard let container = container else { throw Error.incomplete(at: codingPath) }

            return try container.toAny()
        }

        func container<Key: CodingKey>(keyedBy type: Key.Type) -> Swift.KeyedEncodingContainer<Key> {
            let keyed = KeyedEncodingContainer<Key>(codingPath: codingPath, userInfo: userInfo)
            container = keyed
            return Swift.KeyedEncodingContainer(keyed)
        }

        func unkeyedContainer() -> UnkeyedEncodingContainer {
            let unkeyed = UnkeyedContainer(codingPath: codingPath, userInfo: userInfo)
            container = unkeyed
            return unkeyed
        }

        func singleValueContainer() -> SingleValueEncodingContainer {
            let single = SingleContainer(codingPath: codingPath, userInfo: userInfo)
            container = single
            return single
        }

        fileprivate func encode<T>(_ value: T) throws -> Any where T: Encodable {
            try value.encode(to: self)
            return try toAny()
        }
    }
}

private extension DictionaryEncoder {

    final class KeyedEncodingContainer<Key: CodingKey>: KeyedEncodingContainerProtocol, EncoderContainer {
        let codingPath: [CodingKey]
        private let userInfo: [CodingUserInfoKey: Any]
        private var storage: [String: Storage] = [:]

        init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey: Any]) {
            self.codingPath = codingPath
            self.userInfo = userInfo
        }

        func toAny() throws -> Any {
            try storage.mapValues { try $0.toAny() }
        }

        func encodeNil(forKey key: Key) throws {
            storage[key.stringValue] = .value(Any?.none as Any)
        }

        func encode(_ value: Bool, forKey key: Key) throws {
            storage[key.stringValue] = .value(value)
        }

        func encode(_ value: Int, forKey key: Key) throws {
            storage[key.stringValue] = .value(value)
        }

        func encode(_ value: Int8, forKey key: Key) throws {
            storage[key.stringValue] = .value(value)
        }

        func encode(_ value: Int16, forKey key: Key) throws {
            storage[key.stringValue] = .value(value)
        }

        func encode(_ value: Int32, forKey key: Key) throws {
            storage[key.stringValue] = .value(value)
        }

        func encode(_ value: Int64, forKey key: Key) throws {
            storage[key.stringValue] = .value(value)
        }

        func encode(_ value: UInt, forKey key: Key) throws {
            storage[key.stringValue] = .value(value)
        }

        func encode(_ value: UInt8, forKey key: Key) throws {
            storage[key.stringValue] = .value(value)
        }

        func encode(_ value: UInt16, forKey key: Key) throws {
            storage[key.stringValue] = .value(value)
        }

        func encode(_ value: UInt32, forKey key: Key) throws {
            storage[key.stringValue] = .value(value)
        }

        func encode(_ value: UInt64, forKey key: Key) throws {
            storage[key.stringValue] = .value(value)
        }

        func encode(_ value: String, forKey key: Key) throws {
            storage[key.stringValue] = .value(value)
        }

        func encode(_ value: Float, forKey key: Key) throws {
            storage[key.stringValue] = .value(value)
        }

        func encode(_ value: Double, forKey key: Key) throws {
            storage[key.stringValue] = .value(value)
        }

        func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
            if DictionaryEncoder.isSupportedType(T.self) {
                storage[key.stringValue] = .value(value)
            } else {
                let result = try Encoder(codingPath: codingPath.appending(key: key), userInfo: userInfo).encode(value)
                storage[key.stringValue] = .value(result)
            }
        }

        func encodeIfPresent<T: Encodable>(_ value: T?, forKey key: Key) throws {
            let shouldEncodeNilValue = userInfo[.shouldEncodeNilValues] as? Bool ?? false
            if value != nil || shouldEncodeNilValue {
                try encode(value, forKey: key)
            }
        }

        func nestedContainer<NestedKey>(
            keyedBy keyType: NestedKey.Type,
            forKey key: Key
        ) -> Swift.KeyedEncodingContainer<NestedKey> {

            let keyed = KeyedEncodingContainer<NestedKey>(
                codingPath: codingPath.appending(key: key),
                userInfo: userInfo)
            storage[key.stringValue] = .container(keyed)
            return Swift.KeyedEncodingContainer(keyed)
        }

        func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
            let unkeyed = UnkeyedContainer(codingPath: codingPath.appending(key: key), userInfo: userInfo)
            storage[key.stringValue] = .container(unkeyed)
            return unkeyed
        }

        func superEncoder() -> Swift.Encoder {
            superEncoder(forKey: Key(stringValue: "super")!)
        }

        func superEncoder(forKey key: Key) -> Swift.Encoder {
            let encoder = Encoder(codingPath: codingPath.appending(key: key), userInfo: userInfo)
            storage[key.stringValue] = .container(encoder)
            return encoder
        }
    }

    final class UnkeyedContainer: Swift.UnkeyedEncodingContainer, EncoderContainer {
        let codingPath: [CodingKey]
        private let userInfo: [CodingUserInfoKey: Any]
        private var storage: [Storage] = []
        var count: Int { storage.count }

        init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey: Any]) {
            self.codingPath = codingPath
            self.userInfo = userInfo
        }

        func toAny() throws -> Any {
            try storage.map { try $0.toAny() }
        }

        func encodeNil() throws {
            storage.append(.value(Any?.none as Any))
        }

        func encode(_ value: Bool) throws {
            storage.append(.value(value))
        }

        func encode(_ value: Int) throws {
            storage.append(.value(value))
        }

        func encode(_ value: Int8) throws {
            storage.append(.value(value))
        }

        func encode(_ value: Int16) throws {
            storage.append(.value(value))
        }

        func encode(_ value: Int32) throws {
            storage.append(.value(value))
        }

        func encode(_ value: Int64) throws {
            storage.append(.value(value))
        }

        func encode(_ value: UInt) throws {
            storage.append(.value(value))
        }

        func encode(_ value: UInt8) throws {
            storage.append(.value(value))
        }

        func encode(_ value: UInt16) throws {
            storage.append(.value(value))
        }

        func encode(_ value: UInt32) throws {
            storage.append(.value(value))
        }

        func encode(_ value: UInt64) throws {
            storage.append(.value(value))
        }

        func encode(_ value: String) throws {
            storage.append(.value(value))
        }

        func encode(_ value: Float) throws {
            storage.append(.value(value))
        }

        func encode(_ value: Double) throws {
            storage.append(.value(value))
        }

        func encode<T: Encodable>(_ value: T) throws {
            if DictionaryEncoder.isSupportedType(T.self) {
                storage.append(.value(value))
            } else {
                let result = try Encoder(codingPath: codingPath.appending(index: count), userInfo: userInfo).encode(value)
                storage.append(.value(result))
            }
        }

        func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> Swift.KeyedEncodingContainer<NestedKey> {
            let path = codingPath.appending(index: count)
            let keyed = KeyedEncodingContainer<NestedKey>(codingPath: path, userInfo: userInfo)
            storage.append(.container(keyed))
            return Swift.KeyedEncodingContainer(keyed)
        }

        func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
            let unkeyed = UnkeyedContainer(codingPath: codingPath.appending(index: count), userInfo: userInfo)
            storage.append(.container(unkeyed))
            return unkeyed
        }

        func superEncoder() -> Swift.Encoder {
            let encoder = Encoder(codingPath: codingPath.appending(index: count), userInfo: userInfo)
            storage.append(.container(encoder))
            return encoder
        }
    }

    final class SingleContainer: SingleValueEncodingContainer, EncoderContainer {
        let codingPath: [CodingKey]
        private let userInfo: [CodingUserInfoKey: Any]
        private var storage: Any?

        init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey: Any]) {
            self.codingPath = codingPath
            self.userInfo = userInfo
        }

        func toAny() throws -> Any {
            guard let value = storage else { throw Error.incomplete(at: codingPath) }
            return value
        }

        func encodeNil() throws {
            storage = .some(Any?.none as Any)
        }

        func encode(_ value: Bool) throws {
            storage = value
        }

        func encode(_ value: String) throws {
            storage = value
        }

        func encode(_ value: Double) throws {
            storage = value
        }

        func encode(_ value: Float) throws {
            storage = value
        }

        func encode(_ value: Int) throws {
            storage = value
        }

        func encode(_ value: Int8) throws {
            storage = value
        }

        func encode(_ value: Int16) throws {
            storage = value
        }

        func encode(_ value: Int32) throws {
            storage = value
        }

        func encode(_ value: Int64) throws {
            storage = value
        }

        func encode(_ value: UInt) throws {
            storage = value
        }

        func encode(_ value: UInt8) throws {
            storage = value
        }

        func encode(_ value: UInt16) throws {
            storage = value
        }

        func encode(_ value: UInt32) throws {
            storage = value
        }

        func encode(_ value: UInt64) throws {
            storage = value
        }

        func encode<T>(_ value: T) throws where T: Encodable {
            if DictionaryEncoder.isSupportedType(T.self) {
                storage = value
            } else {
                let encoder = Encoder(codingPath: codingPath, userInfo: userInfo)
                storage = try encoder.encode(value)
            }
        }
    }
}
