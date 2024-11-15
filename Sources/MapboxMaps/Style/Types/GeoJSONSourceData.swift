import Foundation
import Turf

/// Captures potential values of the `data` property of a GeoJSONSource.
public enum GeoJSONSourceData: Codable, Equatable {

    /// The `data` property can be an URL or inlined GeoJSON string.
    case string(String)

    /// The `data` property can be a feature.
    case feature(Feature)

    /// The `data` property can be a feature collection.
    case featureCollection(FeatureCollection)

    /// The `data` property can be a geometry with no associated properties.
    case geometry(Geometry)

    @available(*, unavailable, message: "use nil data.")
    case empty

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let decodedString = try? container.decode(String.self) {
            self = .string(decodedString)
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

        if let geometry = try? container.decode(Geometry.self) {
            self = .geometry(geometry)
            return
        }

        let context = DecodingError.Context(codingPath: decoder.codingPath,
                                            debugDescription: "Failed to decode GeoJSONSource `data` property")
        throw DecodingError.dataCorrupted(context)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch self {
        case .string(let string):
            try container.encode(string)
        case .feature(let feature):
            try container.encode(feature)
        case .featureCollection(let featureCollection):
            try container.encode(featureCollection)
        case .geometry(let geometry):
            try container.encode(geometry)
        }
    }

    /// Initializes `GeoJSONSourceData` from an `URL`.
    ///
    /// Effectively the returned data is initialized as `string` with the `URL` contents.
    ///
    /// - Parameters:
    ///     url: An URL to use for initialization.
    public static func url(_ url: URL) -> GeoJSONSourceData {
        return .string(url.absoluteString)
    }
}

extension GeoJSONSourceData {
    internal var coreData: CoreGeoJSONSourceData {
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
        case .string(let string):
            return .fromNSString(string)
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
        #if USING_TURF_WITH_LIBRARY_EVOLUTION
        @unknown default:
            Log.info("Unexpected \(GeoJSONObject.self) type: \(self)")
            return .featureCollection(FeatureCollection(features: []))
        #endif
        }
    }
}
