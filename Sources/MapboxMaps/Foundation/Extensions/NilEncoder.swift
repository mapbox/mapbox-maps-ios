import Foundation

internal struct NilEncoder {
    private let shouldEncodeNil: Bool

    internal init(shouldEncodeNil: Bool = false) {
        self.shouldEncodeNil = shouldEncodeNil
    }

    internal init(userInfo: [CodingUserInfoKey: Any]) {
        self.init(shouldEncodeNil: userInfo[.shouldEncodeNilValues] as? Bool ?? false)
    }

    func encode<E: Encodable, K: KeyedEncodingContainerProtocol>(
        _ encodable: E?,
        forKey key: K.Key,
        to container: inout K
    ) throws {

        if shouldEncodeNil {
            try container.encode(encodable, forKey: key)
        } else {
            try container.encodeIfPresent(encodable, forKey: key)
        }
    }
}
