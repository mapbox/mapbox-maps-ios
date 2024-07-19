// This file is generated.
import Foundation

/// A vector tile source.
///
/// - SeeAlso: [Mapbox Style Specification](https://docs.mapbox.com/mapbox-gl-js/style-spec/sources/#vector)
public struct VectorSource: Source {

    public let type: SourceType
    public let id: String

    /// A URL to a TileJSON resource. Supported protocols are `http:`, `https:`, and `mapbox://<Tileset ID>`. Required if `tiles` is not provided.
    public var url: String?

    /// An array of one or more tile source URLs, as in the TileJSON spec. Required if `url` is not provided.
    public var tiles: [String]?

    /// An array containing the longitude and latitude of the southwest and northeast corners of the source's bounding box in the following order: `[sw.lng, sw.lat, ne.lng, ne.lat]`. When this property is included in a source, no tiles outside of the given bounds are requested by Mapbox GL.
    /// Default value: [-180,-85.051129,180,85.051129].
    public var bounds: [Double]?

    /// Influences the y direction of the tile coordinates. The global-mercator (aka Spherical Mercator) profile is assumed.
    /// Default value: "xyz".
    public var scheme: Scheme?

    /// Minimum zoom level for which tiles are available, as in the TileJSON spec.
    /// Default value: 0.
    public var minzoom: Double?

    /// Maximum zoom level for which tiles are available, as in the TileJSON spec. Data from tiles at the maxzoom are used when displaying the map at higher zoom levels.
    /// Default value: 22.
    public var maxzoom: Double?

    /// Contains an attribution to be displayed when the map is shown to a user.
    public var attribution: String?

    /// A property to use as a feature id (for feature state). Either a property name, or an object of the form `{<sourceLayer>: <propertyName>}`. If specified as a string for a vector tile source, the same property is used across all its source layers. If specified as an object only specified source layers will have id overriden, others will fallback to original feature id
    public var promoteId: PromoteId?

    /// A setting to determine whether a source's tiles are cached locally.
    /// Default value: false.
    public var volatile: Bool?

    /// When loading a map, if PrefetchZoomDelta is set to any number greater than 0, the map will first request a tile at zoom level lower than zoom - delta, but so that the zoom level is multiple of delta, in an attempt to display a full map at lower resolution as quick as possible. It will get clamped at the tile source minimum zoom.
    /// Default value: 4.
    public var prefetchZoomDelta: Double?

    /// This property defines a source-specific resource budget, either in tile units or in megabytes. Whenever the tile cache goes over the defined limit, the least recently used tile will be evicted from the in-memory cache. Note that the current implementation does not take into account resources allocated by the visible tiles.
    public var tileCacheBudget: TileCacheBudgetSize?

    /// Minimum tile update interval in seconds, which is used to throttle the tile update network requests. If the given source supports loading tiles from a server, sets the minimum tile update interval. Update network requests that are more frequent than the minimum tile update interval are suppressed.
    /// Default value: 0.
    public var minimumTileUpdateInterval: Double?

    /// When a set of tiles for a current zoom level is being rendered and some of the ideal tiles that cover the screen are not yet loaded, parent tile could be used instead. This might introduce unwanted rendering side-effects, especially for raster tiles that are overscaled multiple times. This property sets the maximum limit for how much a parent tile can be overscaled.
    public var maxOverscaleFactorForParentTiles: Double?

    /// For the tiled sources, this property sets the tile requests delay. The given delay comes in action only during an ongoing animation or gestures. It helps to avoid loading, parsing and rendering of the transient tiles and thus to improve the rendering performance, especially on low-end devices.
    /// Default value: 0.
    public var tileRequestsDelay: Double?

    /// For the tiled sources, this property sets the tile network requests delay. The given delay comes in action only during an ongoing animation or gestures. It helps to avoid loading the transient tiles from the network and thus to avoid redundant network requests. Note that tile-network-requests-delay value is superseded with tile-requests-delay property value, if both are provided.
    /// Default value: 0.
    public var tileNetworkRequestsDelay: Double?

    public init(id: String) {
        self.id = id
        self.type = .vector
    }
}

extension VectorSource {
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case url = "url"
        case tiles = "tiles"
        case bounds = "bounds"
        case scheme = "scheme"
        case minzoom = "minzoom"
        case maxzoom = "maxzoom"
        case attribution = "attribution"
        case promoteId = "promoteId"
        case volatile = "volatile"
        case prefetchZoomDelta = "prefetch-zoom-delta"
        case tileCacheBudget = "tile-cache-budget"
        case minimumTileUpdateInterval = "minimum-tile-update-interval"
        case maxOverscaleFactorForParentTiles = "max-overscale-factor-for-parent-tiles"
        case tileRequestsDelay = "tile-requests-delay"
        case tileNetworkRequestsDelay = "tile-network-requests-delay"
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
        try container.encodeIfPresent(prefetchZoomDelta, forKey: .prefetchZoomDelta)
        try container.encodeIfPresent(tileCacheBudget, forKey: .tileCacheBudget)
        try container.encodeIfPresent(minimumTileUpdateInterval, forKey: .minimumTileUpdateInterval)
        try container.encodeIfPresent(maxOverscaleFactorForParentTiles, forKey: .maxOverscaleFactorForParentTiles)
        try container.encodeIfPresent(tileRequestsDelay, forKey: .tileRequestsDelay)
        try container.encodeIfPresent(tileNetworkRequestsDelay, forKey: .tileNetworkRequestsDelay)
    }

    private func encodeNonVolatile(to encoder: Encoder, into container: inout KeyedEncodingContainer<CodingKeys>) throws {
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(url, forKey: .url)
        try container.encodeIfPresent(tiles, forKey: .tiles)
        try container.encodeIfPresent(bounds, forKey: .bounds)
        try container.encodeIfPresent(scheme, forKey: .scheme)
        try container.encodeIfPresent(minzoom, forKey: .minzoom)
        try container.encodeIfPresent(maxzoom, forKey: .maxzoom)
        try container.encodeIfPresent(attribution, forKey: .attribution)
        try container.encodeIfPresent(promoteId, forKey: .promoteId)
        try container.encodeIfPresent(volatile, forKey: .volatile)
    }
}

extension VectorSource {

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

    /// A setting to determine whether a source's tiles are cached locally.
    /// Default value: false.
    public func volatile(_ newValue: Bool) -> Self {
        with(self, setter(\.volatile, newValue))
    }

    /// When loading a map, if PrefetchZoomDelta is set to any number greater than 0, the map will first request a tile at zoom level lower than zoom - delta, but so that the zoom level is multiple of delta, in an attempt to display a full map at lower resolution as quick as possible. It will get clamped at the tile source minimum zoom.
    /// Default value: 4.
    public func prefetchZoomDelta(_ newValue: Double) -> Self {
        with(self, setter(\.prefetchZoomDelta, newValue))
    }

    /// This property defines a source-specific resource budget, either in tile units or in megabytes. Whenever the tile cache goes over the defined limit, the least recently used tile will be evicted from the in-memory cache. Note that the current implementation does not take into account resources allocated by the visible tiles.
    public func tileCacheBudget(_ newValue: TileCacheBudgetSize) -> Self {
        with(self, setter(\.tileCacheBudget, newValue))
    }

    /// Minimum tile update interval in seconds, which is used to throttle the tile update network requests. If the given source supports loading tiles from a server, sets the minimum tile update interval. Update network requests that are more frequent than the minimum tile update interval are suppressed.
    /// Default value: 0.
    public func minimumTileUpdateInterval(_ newValue: Double) -> Self {
        with(self, setter(\.minimumTileUpdateInterval, newValue))
    }

    /// When a set of tiles for a current zoom level is being rendered and some of the ideal tiles that cover the screen are not yet loaded, parent tile could be used instead. This might introduce unwanted rendering side-effects, especially for raster tiles that are overscaled multiple times. This property sets the maximum limit for how much a parent tile can be overscaled.
    public func maxOverscaleFactorForParentTiles(_ newValue: Double) -> Self {
        with(self, setter(\.maxOverscaleFactorForParentTiles, newValue))
    }

    /// For the tiled sources, this property sets the tile requests delay. The given delay comes in action only during an ongoing animation or gestures. It helps to avoid loading, parsing and rendering of the transient tiles and thus to improve the rendering performance, especially on low-end devices.
    /// Default value: 0.
    public func tileRequestsDelay(_ newValue: Double) -> Self {
        with(self, setter(\.tileRequestsDelay, newValue))
    }

    /// For the tiled sources, this property sets the tile network requests delay. The given delay comes in action only during an ongoing animation or gestures. It helps to avoid loading the transient tiles from the network and thus to avoid redundant network requests. Note that tile-network-requests-delay value is superseded with tile-requests-delay property value, if both are provided.
    /// Default value: 0.
    public func tileNetworkRequestsDelay(_ newValue: Double) -> Self {
        with(self, setter(\.tileNetworkRequestsDelay, newValue))
    }
}
// End of generated file.
