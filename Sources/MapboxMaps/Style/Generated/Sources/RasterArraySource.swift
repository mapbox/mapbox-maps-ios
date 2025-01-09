// This file is generated.
import Foundation

/// A raster array source
///
/// - SeeAlso: [Mapbox Style Specification](https://docs.mapbox.com/mapbox-gl-js/style-spec/sources/#raster_array)
@_documentation(visibility: public)
@_spi(Experimental) public struct RasterArraySource: Source {

    @_documentation(visibility: public)
    public let type: SourceType
    @_documentation(visibility: public)
    public let id: String

    /// A URL to a TileJSON resource. Supported protocols are `http:`, `https:`, and `mapbox://<Tileset ID>`. Required if `tiles` is not provided.
    @_documentation(visibility: public)
    public var url: String?

    /// An array of one or more tile source URLs, as in the TileJSON spec. Required if `url` is not provided.
    @_documentation(visibility: public)
    public var tiles: [String]?

    /// An array containing the longitude and latitude of the southwest and northeast corners of the source's bounding box in the following order: `[sw.lng, sw.lat, ne.lng, ne.lat]`. When this property is included in a source, no tiles outside of the given bounds are requested by Mapbox GL.
    /// Default value: [-180,-85.051129,180,85.051129].
    @_documentation(visibility: public)
    public private(set) var bounds: [Double]?

    /// Minimum zoom level for which tiles are available, as in the TileJSON spec.
    /// Default value: 0.
    @_documentation(visibility: public)
    public var minzoom: Double?

    /// Maximum zoom level for which tiles are available, as in the TileJSON spec. Data from tiles at the maxzoom are used when displaying the map at higher zoom levels.
    /// Default value: 22.
    @_documentation(visibility: public)
    public var maxzoom: Double?

    /// The minimum visual size to display tiles for this layer. Only configurable for raster layers.
    /// Default value: 512. The unit of tileSize is in pixels.
    @_documentation(visibility: public)
    public private(set) var tileSize: Double?

    /// Contains an attribution to be displayed when the map is shown to a user.
    @_documentation(visibility: public)
    public private(set) var attribution: String?

    /// Contains the description of the raster data layers and the bands contained within the tiles.
    @_documentation(visibility: public)
    public private(set) var rasterLayers: [RasterArraySource.RasterDataLayer]?

    /// This property defines a source-specific resource budget, either in tile units or in megabytes. Whenever the tile cache goes over the defined limit, the least recently used tile will be evicted from the in-memory cache. Note that the current implementation does not take into account resources allocated by the visible tiles.
    @_documentation(visibility: public)
    public var tileCacheBudget: TileCacheBudgetSize?

    @_documentation(visibility: public)
    public init(id: String) {
        self.id = id
        self.type = .rasterArray
    }
}

extension RasterArraySource {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case url = "url"
        case tiles = "tiles"
        case bounds = "bounds"
        case minzoom = "minzoom"
        case maxzoom = "maxzoom"
        case tileSize = "tileSize"
        case attribution = "attribution"
        case rasterLayers = "rasterLayers"
        case tileCacheBudget = "tile-cache-budget"
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
        try container.encodeIfPresent(tileCacheBudget, forKey: .tileCacheBudget)
    }

    private func encodeNonVolatile(to encoder: Encoder, into container: inout KeyedEncodingContainer<CodingKeys>) throws {
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(url, forKey: .url)
        try container.encodeIfPresent(tiles, forKey: .tiles)
        try container.encodeIfPresent(bounds, forKey: .bounds)
        try container.encodeIfPresent(minzoom, forKey: .minzoom)
        try container.encodeIfPresent(maxzoom, forKey: .maxzoom)
        try container.encodeIfPresent(tileSize, forKey: .tileSize)
        try container.encodeIfPresent(attribution, forKey: .attribution)
        try container.encodeIfPresent(rasterLayers, forKey: .rasterLayers)
    }
}

extension RasterArraySource {

    /// A URL to a TileJSON resource. Supported protocols are `http:`, `https:`, and `mapbox://<Tileset ID>`. Required if `tiles` is not provided.
    public func url(_ newValue: String) -> Self {
        with(self, setter(\.url, newValue))
    }

    /// An array of one or more tile source URLs, as in the TileJSON spec. Required if `url` is not provided.
    public func tiles(_ newValue: [String]) -> Self {
        with(self, setter(\.tiles, newValue))
    }

    /// Minimum zoom level for which tiles are available, as in the TileJSON spec.
    /// Default value: 0.
    public func minzoom(_ newValue: Double) -> Self {
        with(self, setter(\.minzoom, newValue))
    }

    /// Maximum zoom level for which tiles are available, as in the TileJSON spec. Data from tiles at the maxzoom are used when displaying the map at higher zoom levels.
    /// Default value: 22.
    public func maxzoom(_ newValue: Double) -> Self {
        with(self, setter(\.maxzoom, newValue))
    }

    /// This property defines a source-specific resource budget, either in tile units or in megabytes. Whenever the tile cache goes over the defined limit, the least recently used tile will be evicted from the in-memory cache. Note that the current implementation does not take into account resources allocated by the visible tiles.
    public func tileCacheBudget(_ newValue: TileCacheBudgetSize) -> Self {
        with(self, setter(\.tileCacheBudget, newValue))
    }
}
// End of generated file.
