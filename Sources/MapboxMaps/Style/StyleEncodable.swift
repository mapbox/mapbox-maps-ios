import Foundation

/// A protocol describing a style-related entity that can be encoded.
public protocol StyleEncodable {
    /// Converts this object to a dictionary representation
    /// - Returns: The dictionary represtantion of `self`.
    func jsonObject() throws -> [String: Any]
}

/// A protocol describing a style-related entity that can be decoded.
public protocol StyleDecodable {
    /// Initializes this object from a dictionary representation.
    /// - Parameter jsonObject: The dictionary representation.
    init(jsonObject: [String: Any]) throws
}

public extension StyleEncodable where Self: Encodable {
    /// Given an Encodable object return the JSON dictionary representation
    /// - Throws: Errors occurring during encoding, or `TypeConversionError.invalidJSONObject`
    /// - Returns: A JSON dictionary representing the object.
    func jsonObject() throws -> [String: Any] {
        try jsonObject(userInfo: [:])
    }
}

internal extension StyleEncodable where Self: Encodable {
    /// Given an Encodable object return the JSON dictionary representation
    /// - Parameter userInfo: A dictionary to customize the encoding process by providing contextual information.
    /// - Throws: Errors occurring during encoding, or `TypeConversionError.invalidJSONObject`
    /// - Returns: A JSON dictionary representing the object.
    func jsonObject(userInfo: [CodingUserInfoKey: Any]) throws -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.userInfo = userInfo
        let data = try encoder.encode(self)

        guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw TypeConversionError.invalidObject
        }
        return jsonObject
    }
}
