import Foundation

/// Describes a Custom Raster Source to be used in the style.
///
/// To add the data, set options with a ``CustomRasterSourceOptions`` with a fetchTileFunction callback
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
@_spi(Experimental)
public struct CustomRasterSource: Source {

    /// The Source type
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public let type: SourceType = .customRaster

    /// Style source identifier.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public let id: String

    /// Settings for the custom raster source, including a fetchTileFunction callback
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public let options: CustomRasterSourceOptions?

#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
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
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
    }
}
