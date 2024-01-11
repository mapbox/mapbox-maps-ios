/// Describes the projection used to render the map.
public struct StyleProjection: Hashable, Codable, StyleEncodable, Equatable {

    /// The name of the projection.
    public var name: StyleProjectionName

    /// Initializes a projection
    public init(name: StyleProjectionName) {
        self.name = name
    }

    internal enum CodingKeys: String, CodingKey {
        case name
    }
}

@_spi(Experimental)
extension StyleProjection: PrimitiveMapStyleContent {
    func _visit(_ visitor: MapStyleContentVisitor) {
        visitor.model.projection = self
    }
}
