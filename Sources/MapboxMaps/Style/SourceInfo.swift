/// Information about a Source
public struct SourceInfo: Sendable {
    /// The identifier of the source
    public var id: String

    /// The type of the source
    public var type: SourceType

    /// Create a `SourceInfo` value
    /// - Parameters:
    ///   - id: A source ID
    ///   - type: A source type
    public init(id: String, type: SourceType) {
        self.id = id
        self.type = type
    }
}
