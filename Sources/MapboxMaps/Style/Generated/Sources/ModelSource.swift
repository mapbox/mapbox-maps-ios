// This file is generated.
import Foundation

/// A collection of 3D models
///
/// - SeeAlso: [Mapbox Style Specification](https://docs.mapbox.com/mapbox-gl-js/style-spec/sources/#model)
public struct ModelSource: Source {

    public private(set) var type: SourceType
    public let id: String

    /// A URL to a TileJSON resource. Supported protocols are `http:`, `https:`, and `mapbox://<Tileset ID>`. Required if `tiles` is not provided.
    public var url: String?

    /// Maximum zoom level at which to create batched model tiles. Data from tiles at the maxzoom are used when displaying the map at higher zoom levels.
    /// Default value: 18.
    public var maxzoom: Double?

    /// Minimum zoom level for which batched-model tiles are available
    /// Default value: 0.
    public var minzoom: Double?

    /// An array of one or more tile source URLs, as in the TileJSON spec. Requires `batched-model` source type.
    public var tiles: [String]?

    /// Defines properties of 3D models in collection. Requires `model` source type.
    public var models: [Model]?

    /// Indicates whether the source is a batched model source.
    public var batched: Bool {
        get { type == .modelBatched }
        set { type = newValue ? .modelBatched : .model }
    }

    public init(id: String) {
        self.id = id
        self.type = .model
    }
}

extension ModelSource {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case url = "url"
        case maxzoom = "maxzoom"
        case minzoom = "minzoom"
        case tiles = "tiles"
        case models = "models"
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(String.self, forKey: .id)
        self.type = try container.decode(SourceType.self, forKey: .type)
        self.url = try container.decodeIfPresent(String.self, forKey: .url)
        self.maxzoom = try container.decodeIfPresent(Double.self, forKey: .maxzoom)
        self.minzoom = try container.decodeIfPresent(Double.self, forKey: .minzoom)
        self.tiles = try container.decodeIfPresent([String].self, forKey: .tiles)
        let modelsMap = try container.decodeIfPresent([String: Model].self, forKey: .models)
        self.models = modelsMap?.map { (id, value) in
            var c = value
            c.id = id
            return c
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        if encoder.userInfo[.volatilePropertiesOnly] as? Bool == true {
            try encodeVolatile(to: encoder, into: &container)
        } else if encoder.userInfo[.nonVolatilePropertiesOnly] as? Bool == true {
            try encodeNonVolatile(to: encoder, into: &container)
        } else {
            try encodeVolatile(to: encoder, into: &container)
            try encodeNonVolatile(to: encoder, into: &container)
        }
    }

    private func encodeVolatile(to encoder: Encoder, into container: inout KeyedEncodingContainer<CodingKeys>) throws {
    }

    private func encodeNonVolatile(to encoder: Encoder, into container: inout KeyedEncodingContainer<CodingKeys>) throws {
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(url, forKey: .url)
        try container.encodeIfPresent(maxzoom, forKey: .maxzoom)
        try container.encodeIfPresent(minzoom, forKey: .minzoom)
        try container.encodeIfPresent(tiles, forKey: .tiles)
        try container.encodeIfPresent(
            models.map { Dictionary(grouping: $0, by: \.id!).compactMapValues(\.first) },
            forKey: .models
        )
    }
}

extension ModelSource {

    /// A URL to a TileJSON resource. Supported protocols are `http:`, `https:`, and `mapbox://<Tileset ID>`. Required if `tiles` is not provided.
    public func url(_ newValue: String) -> Self {
        with(self, setter(\.url, newValue))
    }

    /// Maximum zoom level at which to create batched model tiles. Data from tiles at the maxzoom are used when displaying the map at higher zoom levels.
    /// Default value: 18.
    public func maxzoom(_ newValue: Double) -> Self {
        with(self, setter(\.maxzoom, newValue))
    }

    /// Minimum zoom level for which batched-model tiles are available
    /// Default value: 0.
    public func minzoom(_ newValue: Double) -> Self {
        with(self, setter(\.minzoom, newValue))
    }

    /// An array of one or more tile source URLs, as in the TileJSON spec. Requires `batched-model` source type.
    public func tiles(_ newValue: [String]) -> Self {
        with(self, setter(\.tiles, newValue))
    }

    /// Defines properties of 3D models in collection. Requires `model` source type.
    public func models(_ newValue: [Model]) -> Self {
        with(self, setter(\.models, newValue))
    }
}
// End of generated file.
