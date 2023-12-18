// This file is generated.
import Foundation

/// A raster array source
///
/// - SeeAlso: [Mapbox Style Specification](https://docs.mapbox.com/mapbox-gl-js/style-spec/sources/#raster_array)
#if swift(>=5.8)
@_documentation(visibility: public)
#endif
@_spi(Experimental) public struct RasterArraySource: Source {

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
// End of generated file.
