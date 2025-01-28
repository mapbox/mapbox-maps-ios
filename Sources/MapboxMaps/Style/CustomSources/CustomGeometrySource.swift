import Foundation

/// Describes a Custom Geometry Source to be used in the style
///
/// A CustomGeometrySource uses a coalescing model for frequent data updates targeting the same tile id.
/// This means that the in-progress request as well as the last scheduled request are guaranteed to finish.
public struct CustomGeometrySource: Source {

    /// The Source type
    public let type: SourceType

    /// Style source identifier.
    public let id: String

    /// Settings for the custom geometry, including a fetchTileFunction callback
    public let options: CustomGeometrySourceOptions?

    /// This property defines a source-specific resource budget, either in tile units or in megabytes. Whenever the tile cache goes over the defined limit, the least recently used tile will be evicted from the in-memory cache.
    /// - Note: Current implementation does not take into account resources allocated by the visible tiles.
    public var tileCacheBudget: TileCacheBudgetSize?

    /// When a set of tiles for a current zoom level is being rendered and some of the ideal tiles that cover the screen are not yet loaded, parent tiles could be used instead. Note that this might introduce unwanted rendering side-effects, especially for raster tiles that are overscaled multiple times. This property sets the maximum limit for how much a parent tile can be overscaled.
    @_documentation(visibility: public)
    public var maxOverscaleFactorForParentTiles: UInt8?

    public init(id: String, options: CustomGeometrySourceOptions, maxOverscaleFactorForParentTiles: UInt8? = nil) {
        self.type = .customGeometry
        self.id = id
        self.options = options
        self.maxOverscaleFactorForParentTiles = maxOverscaleFactorForParentTiles
    }
}

extension CustomGeometrySource {
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case tileCacheBudget = "tile-cache-budget"
        case maxOverscaleFactorForParentTiles = "max-overscale-factor-for-parent-tiles"
    }

    /// Init from a decoder, note that the CustomGeometrySourceOptions are not decodable and need to be set separately
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(SourceType.self, forKey: .type)
        tileCacheBudget = try container.decodeIfPresent(TileCacheBudgetSize.self, forKey: .tileCacheBudget)
        options = nil
        maxOverscaleFactorForParentTiles = try container.decodeIfPresent(UInt8.self, forKey: .maxOverscaleFactorForParentTiles)
    }

    /// Encode, note that options will not be included
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
        try container.encodeIfPresent(maxOverscaleFactorForParentTiles, forKey: .maxOverscaleFactorForParentTiles)
    }

    private func encodeNonVolatile(to encoder: Encoder, into container: inout KeyedEncodingContainer<CodingKeys>) throws {
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(type, forKey: .type)
    }
}
