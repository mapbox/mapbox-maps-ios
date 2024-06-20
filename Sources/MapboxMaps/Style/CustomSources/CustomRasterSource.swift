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
    }

    /// Init from a decoder, note that the CustomRasterSourceOptions are not decodable and need to be set separately
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        options = nil
    }

    /// Encode, note that options will not be included
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try encodeNonVolatile(to: encoder, into: &container)
    }

    private func encodeNonVolatile(to encoder: Encoder, into container: inout KeyedEncodingContainer<CodingKeys>) throws {
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(type, forKey: .type)
    }
}
