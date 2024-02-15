import Foundation

/// Layer with custom rendering implementation
///
/// With a power of ``CustomLayerHost`` you can implement your own Metal rendering behaviour
/// and manipulate layer as a usual one.
    @_documentation(visibility: public)
@_spi(Experimental)
public struct CustomLayer: Layer {
    public var id: String

    public let type: LayerType = .custom

    public var slot: Slot?

    public var minZoom: Double?

    public var maxZoom: Double?

    public var visibility: Value<Visibility> = .constant(.visible)

    /// Custom Metal rendering providing API for arbitrary metal operations on top of the ``MapboxMap``
    public var renderer: CustomLayerHost

    public init(
        id: String,
        renderer: CustomLayerHost,
        slot: Slot? = nil,
        minZoom: Double? = nil,
        maxZoom: Double? = nil,
        visibility: Value<Visibility> = .constant(.visible)
    ) {
        self.id = id
        self.slot = slot
        self.minZoom = minZoom
        self.maxZoom = maxZoom
        self.visibility = visibility
        self.renderer = renderer
    }
}

extension CustomLayer {
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case slot
        case minZoom = "minzoom"
        case maxZoom = "maxzoom"
        case layout

        // swiftlint:disable:next nesting
        enum Layout: String, CodingKey {
            case visibility
        }
    }

    // swiftlint:disable missing_docs
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(String.self, forKey: .id)
        self.minZoom = try container.decodeIfPresent(Double.self, forKey: .minZoom)
        self.maxZoom = try container.decodeIfPresent(Double.self, forKey: .maxZoom)
        self.slot = try container.decodeIfPresent(Slot.self, forKey: .slot)

        if let layoutContainer = try? container.nestedContainer(keyedBy: CodingKeys.Layout.self, forKey: .layout),
           let visibilityEncoded = try layoutContainer.decodeIfPresent(Value<Visibility>.self, forKey: .visibility) {
            visibility = visibilityEncoded
        }

        // It is not possible to retrieve CustomLayerHost reference back from the MapboxMap
        // To make API nicer with a clear requirement for renderer, let's stub it with empty implementation
        // when layer is recreated via JSONDecoder as part of ``StyleManager/layer(withId:type:)`` call
        renderer = EmptyCustomRenderer()
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.type, forKey: .type)
        try container.encodeIfPresent(self.minZoom, forKey: .minZoom)
        try container.encodeIfPresent(self.maxZoom, forKey: .maxZoom)
        try container.encodeIfPresent(self.slot, forKey: .slot)

        var layoutContainer = container.nestedContainer(keyedBy: CodingKeys.Layout.self, forKey: .layout)
        try layoutContainer.encode(visibility, forKey: .visibility)
    }
    // swiftlint:enable missing_docs

}
