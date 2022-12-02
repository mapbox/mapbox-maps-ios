import Foundation
import Turf

/// Captures potential values of the `data` property of a GeoJSONSource
public enum GeoJSONSourceData: Codable {

    /// The `data` property can be a url
    case url(URL)

    /// The `data` property can be a feature
    case feature(Feature)

    /// The `data` property can be a feature collection
    case featureCollection(FeatureCollection)

    /// The `data` property can be a geometry with no associated properties.
    case geometry(Geometry)

    /// Empty data to be used for initialization
    case empty

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let decodedURL = try? container.decode(URL.self) {
            self = .url(decodedURL)
            return
        }

        if let decodedFeature = try? container.decode(Feature.self) {
            self = .feature(decodedFeature)
            return
        }

        if let decodedFeatureCollection = try? container.decode(FeatureCollection.self) {
            self = .featureCollection(decodedFeatureCollection)
            return
        }

        if let decodedString = try? container.decode(String.self), decodedString.isEmpty {
            self = .empty
            return
        }

        let context = DecodingError.Context(codingPath: decoder.codingPath,
                                            debugDescription: "Failed to decode GeoJSONSource `data` property")
        throw DecodingError.dataCorrupted(context)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .url(let url):
            try container.encode(url)
        case .feature(let feature):
            try container.encode(feature)
        case .featureCollection(let featureCollection):
            try container.encode(featureCollection)
        case .geometry(let geometry):
            try container.encode(geometry)
        case .empty:
            try container.encode("")
        }
    }

    internal func stringValue() throws -> String {
        switch self {
        case .url(let uRL):
            return uRL.absoluteString
        default:
            return try self.toString()
        }
    }
}

extension GeoJSONSourceData {
    internal var coreData: MapboxCoreMaps.GeoJSONSourceData {
        switch self {
        case .geometry(let geometry):
            let geometry = MapboxCommon.Geometry(geometry)
            return .fromGeometry(geometry)
        case .feature(let feature):
            let feature = MapboxCommon.Feature(feature)
            return .fromFeature(feature)
        case .featureCollection(let collection):
            let features = collection.features.map(MapboxCommon.Feature.init)
            return .fromNSArray(features)
        case .url(let url):
            return .fromNSString(url.absoluteString)
        case .empty:
            return .fromNSString("")
        }
    }
}

extension GeoJSONObject {
    internal var sourceData: GeoJSONSourceData {
        switch self {
        case .geometry(let geometry):
            return .geometry(geometry)
        case .feature(let feature):
            return .feature(feature)
        case .featureCollection(let collection):
            return .featureCollection(collection)
        }
    }
}
