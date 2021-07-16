public protocol StyleEncodable {
    func jsonObject() throws -> [String: Any]
}

public protocol StyleDecodable {
    init(jsonObject: [String: Any]) throws
}

public extension StyleEncodable where Self: Encodable {
    /// Given an Encodable object return the JSON dictionary representation
    /// - Throws: Errors occurring during encoding, or `TypeConversionError.invalidJSONObject`
    /// - Returns: A JSON dictionary representing the object.
    func jsonObject() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)

        guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw TypeConversionError.invalidObject
        }
        return jsonObject
    }
}
