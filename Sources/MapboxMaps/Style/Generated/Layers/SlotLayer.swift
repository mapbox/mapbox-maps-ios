// This file is generated.
import UIKit

/// Marks the position of a slot.
///
/// - SeeAlso: [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-style-spec/#layers-slot)
public struct SlotLayer: Layer, Equatable {

    // MARK: - Conformance to `Layer` protocol
    /// Unique layer name
    public var id: String

    /// Rendering type of this layer.
    public let type: LayerType

    /// The slot this layer is assigned to. If specified, and a slot with that name exists, it will be placed at that position in the layer order.
    public var slot: Slot?

    /// No-op for slot layer.
    public var minZoom: Double?

    /// No-op for slot layer.
    public var maxZoom: Double?

    /// No-op for slot layer.
    public var visibility: Value<Visibility>

    public init(id: String) {
        self.id = id
        self.type = LayerType.slot
        self.visibility = .constant(.visible)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: RootCodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(slot, forKey: .slot)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootCodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(LayerType.self, forKey: .type)
        slot = try container.decodeIfPresent(Slot.self, forKey: .slot)
        visibility = .constant(.visible)
    }

    enum RootCodingKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case slot = "slot"
    }
}

extension SlotLayer {

    /// The slot this layer is assigned to.
    /// If specified, and a slot with that name exists, it will be placed at that position in the layer order.
    public func slot(_ newValue: Slot?) -> Self {
        with(self, setter(\.slot, newValue))
    }

}

extension SlotLayer: MapStyleContent, PrimitiveMapContent {
    func visit(_ node: MapContentNode) {
        node.mount(MountedLayer(layer: self))
    }
}

// End of generated file.
