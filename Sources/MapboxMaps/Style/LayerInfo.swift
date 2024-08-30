/// Information about a layer
public struct LayerInfo: Sendable {
    /// The identifier of the layer
    public var id: String

    /// The type of the layer
    public var type: LayerType

    /// Create a `LayerInfo` value
    /// - Parameters:
    ///   - id: A layer ID
    ///   - type: A layer type
    public init(id: String, type: LayerType) {
        self.id = id
        self.type = type
    }
}
