import Foundation
import Turf

public struct GeoJSONManager {
    private init() {}

    /**
     Encodes an instance of the concrete `GeoJSONObject` type.

     - Parameter geoJSONObject: The object that conforms to `GeoJSONObject` protocol to encode.
     - Returns: `Data` that represents encoded GeoJSON object.
     */
    static public func encode<T: GeoJSONObject>(_ geoJSONObject: T) throws -> Data {
        return try JSONEncoder().encode(geoJSONObject)
    }

    /**
     Decodes an instance of the known expected GeoJSON type.

     - Parameter data: `Data` object that represents encoded GeoJSON object with known expected type.
     - Returns: Concrete GeoJSON object that conforms to `GeoJSONObject` protocol,
     or `nil` if the type is not a GeoJSON object.
     */
    static public func decodeKnown<T>(_ data: Data) throws -> T? where T: GeoJSONObject {
        return try GeoJSON.parse(T.self, from: data)
    }

    /**
     Decodes an instance of the unknown concrete type that is expected to conform to `GeoJSONObject` protocol.

     - Parameter data: `Data` object that represents encoded GeoJSON object with unknown concrete type.
     - Returns: GeoJSON object that conforms to `GeoJSONObject` protocol,
     or `nil` if the type is not a GeoJSON object.
     */
    static public func decodeUnknown(_ data: Data) throws -> GeoJSONObject? {
        let geojson = try GeoJSON.parse(data)
        return geojson.decodedFeature ?? geojson.decodedFeatureCollection
    }

    /**
     Converts a generic object confirming to the `GeoJSONObject` protocol
     to a dictionary representation of that data. Use this method when creating
     a new GeoJSON source with `Style.addSource(_:properties)`.

     - Parameter geoJSONObject: A generic object that conforms to the `GeoJSONObject` protocol.
     - Returns: A nested dictionary that represents the `data` object of a GeoJSON feature.
     */
    static public func dictionaryFrom<T: GeoJSONObject>(_ geoJSONObject: T) throws -> [String: Any]? {
        let data = try JSONEncoder().encode(geoJSONObject)
        let jsonData = try JSONSerialization.jsonObject(with: data)
        return jsonData as? [String: Any]
    }
}
