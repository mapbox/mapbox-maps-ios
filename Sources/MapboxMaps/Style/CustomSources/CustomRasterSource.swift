import Foundation

/// Describes a Custom Raster Source to be used in the style.
///
/// To add the data, set options with a ``CustomRasterSourceOptions`` with a fetchTileFunction callback
    @_documentation(visibility: public)
@_spi(Experimental)
public struct CustomRasterSource: Source {

    /// The Source type
    @_documentation(visibility: public)
    public let type: SourceType = .customRaster

    /// Style source identifier.
    @_documentation(visibility: public)
    public let id: String

    /// Settings for the custom raster source, including a fetchTileFunction callback
    @_documentation(visibility: public)
    public let options: CustomRasterSourceOptions?

    /// This property defines a source-specific resource budget, either in tile units or in megabytes. Whenever the tile cache goes over the defined limit, the least recently used tile will be evicted from the in-memory cache. Note that the current implementation does not take into account resources allocated by the visible tiles.
    @_documentation(visibility: public)
    public var tileCacheBudget: TileCacheBudgetSize?

    @_documentation(visibility: public)
    public init(id: String, options: CustomRasterSourceOptions) {
        self.id = id
        self.options = options
    }
}

extension CustomRasterSource {
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case tileCacheBudget = "tile-cache-budget"
    }

    /// Init from a decoder, note that the CustomRasterSourceOptions are not decodable and need to be set separately
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        tileCacheBudget = try container.decodeIfPresent(TileCacheBudgetSize.self, forKey: .tileCacheBudget)
        options = nil
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
    }

    private func encodeNonVolatile(to encoder: Encoder, into container: inout KeyedEncodingContainer<CodingKeys>) throws {
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(type, forKey: .type)
    }
}
