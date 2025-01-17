import Foundation

/// Layer with custom rendering implementation
///
/// With a power of ``CustomLayerHost`` you can implement your own Metal rendering behaviour
/// and manipulate layer as a usual one.
    @_documentation(visibility: public)
@_spi(Experimental)
public struct CustomLayer: Layer, Equatable {

    /// Unique layer name
    public var id: String

    /// Rendering type of this layer.
    public let type: LayerType = .custom

    /// The slot this layer is assigned to. If specified, and a slot with that name exists, it will be placed at that position in the layer order.
    public var slot: Slot?

    /// The minimum zoom level for the layer. At zoom levels less than the minzoom, the layer will be hidden.
    public var minZoom: Double?

    /// The maximum zoom level for the layer. At zoom levels equal to or greater than the maxzoom, the layer will be hidden.
    public var maxZoom: Double?

    /// Whether this layer is displayed.
    public var visibility: Value<Visibility> = .constant(.visible)

    /// Custom Metal rendering providing API for arbitrary metal operations on top of the ``MapboxMap``
    public var renderer: CustomLayerHost

    /// Equality function for Equatable conformance. Renderer is compared by pointer.
    public static func == (lhs: CustomLayer, rhs: CustomLayer) -> Bool {
        return lhs.id == rhs.id
        && lhs.type == rhs.type
        && lhs.slot == rhs.slot
        && lhs.minZoom == rhs.minZoom
        && lhs.maxZoom == rhs.maxZoom
        && lhs.visibility == rhs.visibility
        && lhs.renderer === rhs.renderer
    }

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

extension CustomLayer {
    /// The slot this layer is assigned to. If specified, and a slot with that name exists,
    /// it will be placed at that position in the layer order.
    public func slot(_ newValue: Slot?) -> Self {
        with(self, setter(\.slot, newValue))
    }

    /// The minimum zoom level for the layer.
    /// At zoom levels less than the minzoom, the layer will be hidden.
    public func minZoom(_ newValue: Double) -> Self {
        with(self, setter(\.minZoom, newValue))
    }

    /// The maximum zoom level for the layer.
    /// At zoom levels equal to or greater than the maxzoom, the layer will be hidden.
    public func maxZoom(_ newValue: Double) -> Self {
        with(self, setter(\.maxZoom, newValue))
    }

    /// Whether this layer is displayed.
    public func visibility(_ newValue: Value<Visibility>) -> Self {
        with(self, setter(\.visibility, newValue))
    }

    /// Custom Metal rendering providing API for arbitrary metal operations on top of the ``MapboxMap``
    public func renderer(_ newValue: CustomLayerHost) -> Self {
        with(self, setter(\.renderer, newValue))
    }
}

@_spi(Experimental)
extension CustomLayer: MapStyleContent, PrimitiveMapContent {
    /// Positions this layer at a specified position.
    ///
    /// - Note: This method should be called last in a chain of layer updates.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public func position(_ position: LayerPosition) -> LayerAtPosition<Self> {
        LayerAtPosition(layer: self, position: position)
    }

    func visit(_ node: MapContentNode) {
        node.mount(MountedLayer(layer: self))
    }
}
