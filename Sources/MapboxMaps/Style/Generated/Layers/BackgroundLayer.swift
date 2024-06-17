// This file is generated.
import UIKit

/// The background color or pattern of the map.
///
/// - SeeAlso: [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-style-spec/#layers-background)
public struct BackgroundLayer: Layer, Equatable {

    // MARK: - Conformance to `Layer` protocol
    /// Unique layer name
    public var id: String

    /// Rendering type of this layer.
    public let type: LayerType

    /// The slot this layer is assigned to. If specified, and a slot with that name exists, it will be placed at that position in the layer order.
    public var slot: Slot?

    /// The minimum zoom level for the layer. At zoom levels less than the minzoom, the layer will be hidden.
    public var minZoom: Double?

    /// The maximum zoom level for the layer. At zoom levels equal to or greater than the maxzoom, the layer will be hidden.
    public var maxZoom: Double?

    /// Whether this layer is displayed.
    public var visibility: Value<Visibility>

    /// The color with which the background will be drawn.
    /// Default value: "#000000".
    public var backgroundColor: Value<StyleColor>?

    /// Transition options for `backgroundColor`.
    public var backgroundColorTransition: StyleTransition?

    /// Controls the intensity of light emitted on the source features.
    /// Default value: 0. Minimum value: 0.
    public var backgroundEmissiveStrength: Value<Double>?

    /// Transition options for `backgroundEmissiveStrength`.
    public var backgroundEmissiveStrengthTransition: StyleTransition?

    /// The opacity at which the background will be drawn.
    /// Default value: 1. Value range: [0, 1]
    public var backgroundOpacity: Value<Double>?

    /// Transition options for `backgroundOpacity`.
    public var backgroundOpacityTransition: StyleTransition?

    /// Name of image in sprite to use for drawing an image background. For seamless patterns, image width and height must be a factor of two (2, 4, 8, ..., 512). Note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    public var backgroundPattern: Value<ResolvedImage>?

    public init(id: String) {
        self.id = id
        self.type = LayerType.background
        self.visibility = .constant(.visible)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: RootCodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(slot, forKey: .slot)
        try container.encodeIfPresent(minZoom, forKey: .minZoom)
        try container.encodeIfPresent(maxZoom, forKey: .maxZoom)

        var paintContainer = container.nestedContainer(keyedBy: PaintCodingKeys.self, forKey: .paint)
        try paintContainer.encodeIfPresent(backgroundColor, forKey: .backgroundColor)
        try paintContainer.encodeIfPresent(backgroundColorTransition, forKey: .backgroundColorTransition)
        try paintContainer.encodeIfPresent(backgroundEmissiveStrength, forKey: .backgroundEmissiveStrength)
        try paintContainer.encodeIfPresent(backgroundEmissiveStrengthTransition, forKey: .backgroundEmissiveStrengthTransition)
        try paintContainer.encodeIfPresent(backgroundOpacity, forKey: .backgroundOpacity)
        try paintContainer.encodeIfPresent(backgroundOpacityTransition, forKey: .backgroundOpacityTransition)
        try paintContainer.encodeIfPresent(backgroundPattern, forKey: .backgroundPattern)

        var layoutContainer = container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout)
        try layoutContainer.encode(visibility, forKey: .visibility)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootCodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(LayerType.self, forKey: .type)
        slot = try container.decodeIfPresent(Slot.self, forKey: .slot)
        minZoom = try container.decodeIfPresent(Double.self, forKey: .minZoom)
        maxZoom = try container.decodeIfPresent(Double.self, forKey: .maxZoom)

        if let paintContainer = try? container.nestedContainer(keyedBy: PaintCodingKeys.self, forKey: .paint) {
            backgroundColor = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .backgroundColor)
            backgroundColorTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .backgroundColorTransition)
            backgroundEmissiveStrength = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .backgroundEmissiveStrength)
            backgroundEmissiveStrengthTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .backgroundEmissiveStrengthTransition)
            backgroundOpacity = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .backgroundOpacity)
            backgroundOpacityTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .backgroundOpacityTransition)
            backgroundPattern = try paintContainer.decodeIfPresent(Value<ResolvedImage>.self, forKey: .backgroundPattern)
        }

        var visibilityEncoded: Value<Visibility>?
        if let layoutContainer = try? container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout) {
            visibilityEncoded = try layoutContainer.decodeIfPresent(Value<Visibility>.self, forKey: .visibility)
        }
        visibility = visibilityEncoded ?? .constant(.visible)
    }

    enum RootCodingKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case slot = "slot"
        case minZoom = "minzoom"
        case maxZoom = "maxzoom"
        case layout = "layout"
        case paint = "paint"
    }

    enum LayoutCodingKeys: String, CodingKey {
        case visibility = "visibility"
    }

    enum PaintCodingKeys: String, CodingKey {
        case backgroundColor = "background-color"
        case backgroundColorTransition = "background-color-transition"
        case backgroundEmissiveStrength = "background-emissive-strength"
        case backgroundEmissiveStrengthTransition = "background-emissive-strength-transition"
        case backgroundOpacity = "background-opacity"
        case backgroundOpacityTransition = "background-opacity-transition"
        case backgroundPattern = "background-pattern"
    }
}

@_documentation(visibility: public)
@_spi(Experimental) extension BackgroundLayer {

    /// The slot this layer is assigned to.
    /// If specified, and a slot with that name exists, it will be placed at that position in the layer order.
    @_documentation(visibility: public)
    public func slot(_ newValue: Slot?) -> Self {
        with(self, setter(\.slot, newValue))
    }

    /// The minimum zoom level for the layer. At zoom levels less than the minzoom, the layer will be hidden.
    @_documentation(visibility: public)
    public func minZoom(_ newValue: Double) -> Self {
        with(self, setter(\.minZoom, newValue))
    }

    /// The maximum zoom level for the layer. At zoom levels equal to or greater than the maxzoom, the layer will be hidden.
    @_documentation(visibility: public)
    public func maxZoom(_ newValue: Double) -> Self {
        with(self, setter(\.maxZoom, newValue))
    }

    /// The color with which the background will be drawn.
    /// Default value: "#000000".
    @_documentation(visibility: public)
    public func backgroundColor(_ constant: StyleColor) -> Self {
        with(self, setter(\.backgroundColor, .constant(constant)))
    }

    /// The color with which the background will be drawn.
    /// Default value: "#000000".
    @_documentation(visibility: public)
    public func backgroundColor(_ color: UIColor) -> Self {
        with(self, setter(\.backgroundColor, .constant(StyleColor(color))))
    }

    /// Transition property for `backgroundColor`
    @_documentation(visibility: public)
    public func backgroundColorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.backgroundColorTransition, transition))
    }

    /// The color with which the background will be drawn.
    /// Default value: "#000000".
    @_documentation(visibility: public)
    public func backgroundColor(_ expression: Expression) -> Self {
        with(self, setter(\.backgroundColor, .expression(expression)))
    }

    /// Controls the intensity of light emitted on the source features.
    /// Default value: 0. Minimum value: 0.
    @_documentation(visibility: public)
    public func backgroundEmissiveStrength(_ constant: Double) -> Self {
        with(self, setter(\.backgroundEmissiveStrength, .constant(constant)))
    }

    /// Transition property for `backgroundEmissiveStrength`
    @_documentation(visibility: public)
    public func backgroundEmissiveStrengthTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.backgroundEmissiveStrengthTransition, transition))
    }

    /// Controls the intensity of light emitted on the source features.
    /// Default value: 0. Minimum value: 0.
    @_documentation(visibility: public)
    public func backgroundEmissiveStrength(_ expression: Expression) -> Self {
        with(self, setter(\.backgroundEmissiveStrength, .expression(expression)))
    }

    /// The opacity at which the background will be drawn.
    /// Default value: 1. Value range: [0, 1]
    @_documentation(visibility: public)
    public func backgroundOpacity(_ constant: Double) -> Self {
        with(self, setter(\.backgroundOpacity, .constant(constant)))
    }

    /// Transition property for `backgroundOpacity`
    @_documentation(visibility: public)
    public func backgroundOpacityTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.backgroundOpacityTransition, transition))
    }

    /// The opacity at which the background will be drawn.
    /// Default value: 1. Value range: [0, 1]
    @_documentation(visibility: public)
    public func backgroundOpacity(_ expression: Expression) -> Self {
        with(self, setter(\.backgroundOpacity, .expression(expression)))
    }

    /// Name of image in sprite to use for drawing an image background. For seamless patterns, image width and height must be a factor of two (2, 4, 8, ..., 512). Note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    @_documentation(visibility: public)
    public func backgroundPattern(_ constant: String) -> Self {
        with(self, setter(\.backgroundPattern, .constant(.name(constant))))
    }

    /// Name of image in sprite to use for drawing an image background. For seamless patterns, image width and height must be a factor of two (2, 4, 8, ..., 512). Note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    @_documentation(visibility: public)
    public func backgroundPattern(_ expression: Expression) -> Self {
        with(self, setter(\.backgroundPattern, .expression(expression)))
    }
}

@available(iOS 13.0, *)
@_spi(Experimental)
extension BackgroundLayer: MapStyleContent, PrimitiveMapContent {
    func visit(_ node: MapContentNode) {
        node.mount(MountedLayer(layer: self))
    }
}

// End of generated file.
