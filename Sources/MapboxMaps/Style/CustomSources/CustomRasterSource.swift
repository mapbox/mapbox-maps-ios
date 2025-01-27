import Foundation

/// Describes a Custom Raster Source to be used in the style.
///
/// To add the data, set options with a ``CustomRasterSourceOptions`` with a fetchTileFunction callback
@_documentation(visibility: public)
@_spi(Experimental)
public struct CustomRasterSource: Source, Equatable {

    /// The Source type
    @_documentation(visibility: public)
    public let type: SourceType = .customRaster

    /// Style source identifier.
    @_documentation(visibility: public)
    public let id: String

    /// Settings for the custom raster source, including a fetchTileFunction callback
    @_documentation(visibility: public)
    public let options: CustomRasterSourceOptions?

    /// When a set of tiles for a current zoom level is being rendered and some of the ideal tiles that cover the screen are not yet loaded, parent tiles could be used instead. Note that this might introduce unwanted rendering side-effects, especially for raster tiles that are overscaled multiple times. This property sets the maximum limit for how much a parent tile can be overscaled.
    @_documentation(visibility: public)
    public var maxOverscaleFactorForParentTiles: UInt8?

    @_documentation(visibility: public)
    public init(id: String, options: CustomRasterSourceOptions, maxOverscaleFactorForParentTiles: UInt8? = nil) {
        self.id = id
        self.options = options
        self.maxOverscaleFactorForParentTiles = maxOverscaleFactorForParentTiles
    }
}

extension CustomRasterSource {
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case maxOverscaleFactorForParentTiles = "max-overscale-factor-for-parent-tiles"
    }

    /// Init from a decoder, note that the CustomRasterSourceOptions are not decodable and need to be set separately
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
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
        try container.encodeIfPresent(maxOverscaleFactorForParentTiles, forKey: .maxOverscaleFactorForParentTiles)
    }

    private func encodeNonVolatile(to encoder: Encoder, into container: inout KeyedEncodingContainer<CodingKeys>) throws {
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(type, forKey: .type)
    }
}
