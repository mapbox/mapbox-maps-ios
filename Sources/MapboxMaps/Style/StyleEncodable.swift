import Foundation
import MapboxCoreMaps

public protocol StyleEncodable {
    func jsonObject() throws -> [String: AnyObject]
}

public extension StyleEncodable where Self: Encodable {
    /// Given an Encodable object return the JSON dictionary representation
    /// - Throws: Errors occurring during encoding, or `StyleEncodingError.invalidJSONObject`
    /// - Returns: A JSON dictionary representing the object.
    func jsonObject() throws -> [String: AnyObject] {
        let data = try JSONEncoder().encode(self)
        guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: AnyObject] else {
            throw StyleEncodingError.invalidJSONObject
        }
        return jsonObject
    }
}
