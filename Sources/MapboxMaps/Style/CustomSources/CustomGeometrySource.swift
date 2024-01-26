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

    public init(id: String, options: CustomGeometrySourceOptions) {
        self.type = .customGeometry
        self.id = id
        self.options = options
    }
}

extension CustomGeometrySource {
    enum CodingKeys: String, CodingKey {
        case id
        case type
    }

    /// Init from a decoder, note that the CustomGeometrySourceOptions are not decodable and need to be set separately
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(SourceType.self, forKey: .type)
        options = nil
    }

    /// Encode, note that options will not be included
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
    }
}
