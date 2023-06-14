public protocol Source: Codable, StyleEncodable, StyleDecodable {
    /// Rendering type of this source.
    var type: SourceType { get }

    var id: String { get }
}

public extension Source {
    /// Initializes a Source given a JSON dictionary
    /// - Throws: Errors occurring during decoding
    init(jsonObject: [String: Any]) throws {
        let sourceData = try JSONSerialization.data(withJSONObject: jsonObject)
        self = try JSONDecoder().decode(Self.self, from: sourceData)
    }
}
