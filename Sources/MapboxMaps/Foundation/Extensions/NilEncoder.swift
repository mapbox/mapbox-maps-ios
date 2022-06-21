import Foundation

internal struct NilEncoder {
    var userInfo: [CodingUserInfoKey : Any]

    func encode<E: Encodable, K: KeyedEncodingContainerProtocol>(
        _ encodable: E?,
        forKey key: K.Key,
        to container: inout K
    ) throws {

        let shouldEncoderNil = userInfo[.shouldEncodeNilValues] as? Bool ?? false

        if shouldEncoderNil {
            try container.encode(encodable, forKey: key)
        } else {
            try container.encodeIfPresent(encodable, forKey: key)
        }
    }
}
