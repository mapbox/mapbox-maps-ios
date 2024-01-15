// This file is generated.
import Foundation

/// A raster array source
///
/// - SeeAlso: [Mapbox Style Specification](https://docs.mapbox.com/mapbox-gl-js/style-spec/sources/#raster_array)
#if swift(>=5.8)
@_documentation(visibility: public)
#endif
@_spi(Experimental) public struct RasterArraySource: Source, Equatable {

#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public let type: SourceType
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public let id: String

    /// A URL to a TileJSON resource. Supported protocols are `http:`, `https:`, and `mapbox://<Tileset ID>`.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public var url: String?

    /// An array of one or more tile source URLs, as in the TileJSON spec.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public var tiles: [String]?

    /// An array containing the longitude and latitude of the southwest and northeast corners of the source's bounding box in the following order: `[sw.lng, sw.lat, ne.lng, ne.lat]`. When this property is included in a source, no tiles outside of the given bounds are requested by Mapbox GL.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public private(set) var bounds: [Double]?

    /// Minimum zoom level for which tiles are available, as in the TileJSON spec.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public var minzoom: Double?

    /// Maximum zoom level for which tiles are available, as in the TileJSON spec. Data from tiles at the maxzoom are used when displaying the map at higher zoom levels.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public var maxzoom: Double?

    /// The minimum visual size to display tiles for this layer. Only configurable for raster layers.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public private(set) var tileSize: Double?

    /// Contains an attribution to be displayed when the map is shown to a user.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public private(set) var attribution: String?

    /// Contains the description of the raster data layers and the bands contained within the tiles.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public private(set) var rasterLayers: [RasterArraySource.RasterDataLayer]?

    /// This property defines a source-specific resource budget, either in tile units or in megabytes. Whenever the tile cache goes over the defined limit, the least recently used tile will be evicted from the in-memory cache. Note that the current implementation does not take into account resources allocated by the visible tiles.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public var tileCacheBudget: TileCacheBudgetSize?

#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
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

        if encoder.userInfo[.volatilePropertiesOnly] as? Bool == true  {
            try encodeVolatile(to: encoder, into: &container)
        } else if encoder.userInfo[.nonVolatilePropertiesOnly] as? Bool == true  {
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

#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
@_spi(Experimental) extension RasterArraySource {

#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    /// A URL to a TileJSON resource. Supported protocols are `http:`, `https:`, and `mapbox://<Tileset ID>`.
    public func url(_ newValue: String) -> Self {
        with(self, setter(\.url, newValue))
    }    

#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    /// An array of one or more tile source URLs, as in the TileJSON spec.
    public func tiles(_ newValue: [String]) -> Self {
        with(self, setter(\.tiles, newValue))
    }    

#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    /// An array containing the longitude and latitude of the southwest and northeast corners of the source's bounding box in the following order: `[sw.lng, sw.lat, ne.lng, ne.lat]`. When this property is included in a source, no tiles outside of the given bounds are requested by Mapbox GL.
    public func bounds(_ newValue: [Double]) -> Self {
        with(self, setter(\.bounds, newValue))
    }    

#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    /// Minimum zoom level for which tiles are available, as in the TileJSON spec.
    public func minzoom(_ newValue: Double) -> Self {
        with(self, setter(\.minzoom, newValue))
    }    

#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    /// Maximum zoom level for which tiles are available, as in the TileJSON spec. Data from tiles at the maxzoom are used when displaying the map at higher zoom levels.
    public func maxzoom(_ newValue: Double) -> Self {
        with(self, setter(\.maxzoom, newValue))
    }    

#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    /// The minimum visual size to display tiles for this layer. Only configurable for raster layers.
    public func tileSize(_ newValue: Double) -> Self {
        with(self, setter(\.tileSize, newValue))
    }    

#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    /// Contains an attribution to be displayed when the map is shown to a user.
    public func attribution(_ newValue: String) -> Self {
        with(self, setter(\.attribution, newValue))
    }    

#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    /// Contains the description of the raster data layers and the bands contained within the tiles.
    public func rasterLayers(_ newValue: [RasterArraySource.RasterDataLayer]) -> Self {
        with(self, setter(\.rasterLayers, newValue))
    }    
}
// End of generated file.
