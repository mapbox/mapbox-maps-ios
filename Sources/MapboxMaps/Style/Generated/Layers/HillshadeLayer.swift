// This file is generated.
import UIKit

/// Client-side hillshading visualization based on DEM data. Currently, the implementation only supports Mapbox Terrain RGB and Mapzen Terrarium tiles.
///
/// - SeeAlso: [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-style-spec/#layers-hillshade)
public struct HillshadeLayer: Layer, Equatable {

    // MARK: - Conformance to `Layer` protocol
    /// Unique layer name
    public var id: String

    /// Rendering type of this layer.
    public let type: LayerType

    /// An expression specifying conditions on source features.
    /// Only features that match the filter are displayed.
    public var filter: Expression?

    /// Name of a source description to be used for this layer.
    /// Required for all layer types except ``BackgroundLayer``, ``SkyLayer``, and ``LocationIndicatorLayer``.
    public var source: String?

    /// Layer to use from a vector tile source.
    ///
    /// Required for vector tile sources.
    /// Prohibited for all other source types, including GeoJSON sources.
    public var sourceLayer: String?

    /// The slot this layer is assigned to. If specified, and a slot with that name exists, it will be placed at that position in the layer order.
    public var slot: Slot?

    /// The minimum zoom level for the layer. At zoom levels less than the minzoom, the layer will be hidden.
    public var minZoom: Double?

    /// The maximum zoom level for the layer. At zoom levels equal to or greater than the maxzoom, the layer will be hidden.
    public var maxZoom: Double?

    /// Whether this layer is displayed.
    public var visibility: Value<Visibility>

    /// The shading color used to accentuate rugged terrain like sharp cliffs and gorges.
    /// Default value: "#000000".
    public var hillshadeAccentColor: Value<StyleColor>?

    /// Transition options for `hillshadeAccentColor`.
    public var hillshadeAccentColorTransition: StyleTransition?

    /// Controls the intensity of light emitted on the source features.
    /// Default value: 0. Minimum value: 0.
    public var hillshadeEmissiveStrength: Value<Double>?

    /// Transition options for `hillshadeEmissiveStrength`.
    public var hillshadeEmissiveStrengthTransition: StyleTransition?

    /// Intensity of the hillshade
    /// Default value: 0.5. Value range: [0, 1]
    public var hillshadeExaggeration: Value<Double>?

    /// Transition options for `hillshadeExaggeration`.
    public var hillshadeExaggerationTransition: StyleTransition?

    /// The shading color of areas that faces towards the light source.
    /// Default value: "#FFFFFF".
    public var hillshadeHighlightColor: Value<StyleColor>?

    /// Transition options for `hillshadeHighlightColor`.
    public var hillshadeHighlightColorTransition: StyleTransition?

    /// Direction of light source when map is rotated.
    /// Default value: "viewport".
    public var hillshadeIlluminationAnchor: Value<HillshadeIlluminationAnchor>?

    /// The direction of the light source used to generate the hillshading with 0 as the top of the viewport if `hillshade-illumination-anchor` is set to `viewport` and due north if `hillshade-illumination-anchor` is set to `map` and no 3d lights enabled. If `hillshade-illumination-anchor` is set to `map` and 3d lights enabled, the direction from 3d lights is used instead.
    /// Default value: 335. Value range: [0, 359]
    public var hillshadeIlluminationDirection: Value<Double>?

    /// The shading color of areas that face away from the light source.
    /// Default value: "#000000".
    public var hillshadeShadowColor: Value<StyleColor>?

    /// Transition options for `hillshadeShadowColor`.
    public var hillshadeShadowColorTransition: StyleTransition?

    public init(id: String, source: String) {
        self.source = source
        self.id = id
        self.type = LayerType.hillshade
        self.visibility = .constant(.visible)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: RootCodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(filter, forKey: .filter)
        try container.encodeIfPresent(source, forKey: .source)
        try container.encodeIfPresent(sourceLayer, forKey: .sourceLayer)
        try container.encodeIfPresent(slot, forKey: .slot)
        try container.encodeIfPresent(minZoom, forKey: .minZoom)
        try container.encodeIfPresent(maxZoom, forKey: .maxZoom)

        var paintContainer = container.nestedContainer(keyedBy: PaintCodingKeys.self, forKey: .paint)
        try paintContainer.encodeIfPresent(hillshadeAccentColor, forKey: .hillshadeAccentColor)
        try paintContainer.encodeIfPresent(hillshadeAccentColorTransition, forKey: .hillshadeAccentColorTransition)
        try paintContainer.encodeIfPresent(hillshadeEmissiveStrength, forKey: .hillshadeEmissiveStrength)
        try paintContainer.encodeIfPresent(hillshadeEmissiveStrengthTransition, forKey: .hillshadeEmissiveStrengthTransition)
        try paintContainer.encodeIfPresent(hillshadeExaggeration, forKey: .hillshadeExaggeration)
        try paintContainer.encodeIfPresent(hillshadeExaggerationTransition, forKey: .hillshadeExaggerationTransition)
        try paintContainer.encodeIfPresent(hillshadeHighlightColor, forKey: .hillshadeHighlightColor)
        try paintContainer.encodeIfPresent(hillshadeHighlightColorTransition, forKey: .hillshadeHighlightColorTransition)
        try paintContainer.encodeIfPresent(hillshadeIlluminationAnchor, forKey: .hillshadeIlluminationAnchor)
        try paintContainer.encodeIfPresent(hillshadeIlluminationDirection, forKey: .hillshadeIlluminationDirection)
        try paintContainer.encodeIfPresent(hillshadeShadowColor, forKey: .hillshadeShadowColor)
        try paintContainer.encodeIfPresent(hillshadeShadowColorTransition, forKey: .hillshadeShadowColorTransition)

        var layoutContainer = container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout)
        try layoutContainer.encode(visibility, forKey: .visibility)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootCodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(LayerType.self, forKey: .type)
        filter = try container.decodeIfPresent(Expression.self, forKey: .filter)
        source = try container.decodeIfPresent(String.self, forKey: .source)
        sourceLayer = try container.decodeIfPresent(String.self, forKey: .sourceLayer)
        slot = try container.decodeIfPresent(Slot.self, forKey: .slot)
        minZoom = try container.decodeIfPresent(Double.self, forKey: .minZoom)
        maxZoom = try container.decodeIfPresent(Double.self, forKey: .maxZoom)

        if let paintContainer = try? container.nestedContainer(keyedBy: PaintCodingKeys.self, forKey: .paint) {
            hillshadeAccentColor = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .hillshadeAccentColor)
            hillshadeAccentColorTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .hillshadeAccentColorTransition)
            hillshadeEmissiveStrength = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .hillshadeEmissiveStrength)
            hillshadeEmissiveStrengthTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .hillshadeEmissiveStrengthTransition)
            hillshadeExaggeration = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .hillshadeExaggeration)
            hillshadeExaggerationTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .hillshadeExaggerationTransition)
            hillshadeHighlightColor = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .hillshadeHighlightColor)
            hillshadeHighlightColorTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .hillshadeHighlightColorTransition)
            hillshadeIlluminationAnchor = try paintContainer.decodeIfPresent(Value<HillshadeIlluminationAnchor>.self, forKey: .hillshadeIlluminationAnchor)
            hillshadeIlluminationDirection = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .hillshadeIlluminationDirection)
            hillshadeShadowColor = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .hillshadeShadowColor)
            hillshadeShadowColorTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .hillshadeShadowColorTransition)
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
        case filter = "filter"
        case source = "source"
        case sourceLayer = "source-layer"
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
        case hillshadeAccentColor = "hillshade-accent-color"
        case hillshadeAccentColorTransition = "hillshade-accent-color-transition"
        case hillshadeEmissiveStrength = "hillshade-emissive-strength"
        case hillshadeEmissiveStrengthTransition = "hillshade-emissive-strength-transition"
        case hillshadeExaggeration = "hillshade-exaggeration"
        case hillshadeExaggerationTransition = "hillshade-exaggeration-transition"
        case hillshadeHighlightColor = "hillshade-highlight-color"
        case hillshadeHighlightColorTransition = "hillshade-highlight-color-transition"
        case hillshadeIlluminationAnchor = "hillshade-illumination-anchor"
        case hillshadeIlluminationDirection = "hillshade-illumination-direction"
        case hillshadeShadowColor = "hillshade-shadow-color"
        case hillshadeShadowColorTransition = "hillshade-shadow-color-transition"
    }
}

@_documentation(visibility: public)
@_spi(Experimental) extension HillshadeLayer {
    /// An expression specifying conditions on source features.
    /// Only features that match the filter are displayed.
    @_documentation(visibility: public)
    public func filter(_ newValue: Expression) -> Self {
        with(self, setter(\.filter, newValue))
    }

    /// Name of a source description to be used for this layer.
    /// Required for all layer types except ``BackgroundLayer``, ``SkyLayer``, and ``LocationIndicatorLayer``.
    @_documentation(visibility: public)
    public func source(_ newValue: String) -> Self {
        with(self, setter(\.source, newValue))
    }

    /// Layer to use from a vector tile source.
    ///
    /// Required for vector tile sources.
    /// Prohibited for all other source types, including GeoJSON sources.
    @_documentation(visibility: public)
    public func sourceLayer(_ newValue: String) -> Self {
        with(self, setter(\.sourceLayer, newValue))
    }

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

    /// The shading color used to accentuate rugged terrain like sharp cliffs and gorges.
    /// Default value: "#000000".
    @_documentation(visibility: public)
    public func hillshadeAccentColor(_ constant: StyleColor) -> Self {
        with(self, setter(\.hillshadeAccentColor, .constant(constant)))
    }

    /// The shading color used to accentuate rugged terrain like sharp cliffs and gorges.
    /// Default value: "#000000".
    @_documentation(visibility: public)
    public func hillshadeAccentColor(_ color: UIColor) -> Self {
        with(self, setter(\.hillshadeAccentColor, .constant(StyleColor(color))))
    }

    /// Transition property for `hillshadeAccentColor`
    @_documentation(visibility: public)
    public func hillshadeAccentColorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.hillshadeAccentColorTransition, transition))
    }

    /// The shading color used to accentuate rugged terrain like sharp cliffs and gorges.
    /// Default value: "#000000".
    @_documentation(visibility: public)
    public func hillshadeAccentColor(_ expression: Expression) -> Self {
        with(self, setter(\.hillshadeAccentColor, .expression(expression)))
    }

    /// Controls the intensity of light emitted on the source features.
    /// Default value: 0. Minimum value: 0.
    @_documentation(visibility: public)
    public func hillshadeEmissiveStrength(_ constant: Double) -> Self {
        with(self, setter(\.hillshadeEmissiveStrength, .constant(constant)))
    }

    /// Transition property for `hillshadeEmissiveStrength`
    @_documentation(visibility: public)
    public func hillshadeEmissiveStrengthTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.hillshadeEmissiveStrengthTransition, transition))
    }

    /// Controls the intensity of light emitted on the source features.
    /// Default value: 0. Minimum value: 0.
    @_documentation(visibility: public)
    public func hillshadeEmissiveStrength(_ expression: Expression) -> Self {
        with(self, setter(\.hillshadeEmissiveStrength, .expression(expression)))
    }

    /// Intensity of the hillshade
    /// Default value: 0.5. Value range: [0, 1]
    @_documentation(visibility: public)
    public func hillshadeExaggeration(_ constant: Double) -> Self {
        with(self, setter(\.hillshadeExaggeration, .constant(constant)))
    }

    /// Transition property for `hillshadeExaggeration`
    @_documentation(visibility: public)
    public func hillshadeExaggerationTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.hillshadeExaggerationTransition, transition))
    }

    /// Intensity of the hillshade
    /// Default value: 0.5. Value range: [0, 1]
    @_documentation(visibility: public)
    public func hillshadeExaggeration(_ expression: Expression) -> Self {
        with(self, setter(\.hillshadeExaggeration, .expression(expression)))
    }

    /// The shading color of areas that faces towards the light source.
    /// Default value: "#FFFFFF".
    @_documentation(visibility: public)
    public func hillshadeHighlightColor(_ constant: StyleColor) -> Self {
        with(self, setter(\.hillshadeHighlightColor, .constant(constant)))
    }

    /// The shading color of areas that faces towards the light source.
    /// Default value: "#FFFFFF".
    @_documentation(visibility: public)
    public func hillshadeHighlightColor(_ color: UIColor) -> Self {
        with(self, setter(\.hillshadeHighlightColor, .constant(StyleColor(color))))
    }

    /// Transition property for `hillshadeHighlightColor`
    @_documentation(visibility: public)
    public func hillshadeHighlightColorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.hillshadeHighlightColorTransition, transition))
    }

    /// The shading color of areas that faces towards the light source.
    /// Default value: "#FFFFFF".
    @_documentation(visibility: public)
    public func hillshadeHighlightColor(_ expression: Expression) -> Self {
        with(self, setter(\.hillshadeHighlightColor, .expression(expression)))
    }

    /// Direction of light source when map is rotated.
    /// Default value: "viewport".
    @_documentation(visibility: public)
    public func hillshadeIlluminationAnchor(_ constant: HillshadeIlluminationAnchor) -> Self {
        with(self, setter(\.hillshadeIlluminationAnchor, .constant(constant)))
    }

    /// Direction of light source when map is rotated.
    /// Default value: "viewport".
    @_documentation(visibility: public)
    public func hillshadeIlluminationAnchor(_ expression: Expression) -> Self {
        with(self, setter(\.hillshadeIlluminationAnchor, .expression(expression)))
    }

    /// The direction of the light source used to generate the hillshading with 0 as the top of the viewport if `hillshade-illumination-anchor` is set to `viewport` and due north if `hillshade-illumination-anchor` is set to `map` and no 3d lights enabled. If `hillshade-illumination-anchor` is set to `map` and 3d lights enabled, the direction from 3d lights is used instead.
    /// Default value: 335. Value range: [0, 359]
    @_documentation(visibility: public)
    public func hillshadeIlluminationDirection(_ constant: Double) -> Self {
        with(self, setter(\.hillshadeIlluminationDirection, .constant(constant)))
    }

    /// The direction of the light source used to generate the hillshading with 0 as the top of the viewport if `hillshade-illumination-anchor` is set to `viewport` and due north if `hillshade-illumination-anchor` is set to `map` and no 3d lights enabled. If `hillshade-illumination-anchor` is set to `map` and 3d lights enabled, the direction from 3d lights is used instead.
    /// Default value: 335. Value range: [0, 359]
    @_documentation(visibility: public)
    public func hillshadeIlluminationDirection(_ expression: Expression) -> Self {
        with(self, setter(\.hillshadeIlluminationDirection, .expression(expression)))
    }

    /// The shading color of areas that face away from the light source.
    /// Default value: "#000000".
    @_documentation(visibility: public)
    public func hillshadeShadowColor(_ constant: StyleColor) -> Self {
        with(self, setter(\.hillshadeShadowColor, .constant(constant)))
    }

    /// The shading color of areas that face away from the light source.
    /// Default value: "#000000".
    @_documentation(visibility: public)
    public func hillshadeShadowColor(_ color: UIColor) -> Self {
        with(self, setter(\.hillshadeShadowColor, .constant(StyleColor(color))))
    }

    /// Transition property for `hillshadeShadowColor`
    @_documentation(visibility: public)
    public func hillshadeShadowColorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.hillshadeShadowColorTransition, transition))
    }

    /// The shading color of areas that face away from the light source.
    /// Default value: "#000000".
    @_documentation(visibility: public)
    public func hillshadeShadowColor(_ expression: Expression) -> Self {
        with(self, setter(\.hillshadeShadowColor, .expression(expression)))
    }
}

@available(iOS 13.0, *)
@_spi(Experimental)
extension HillshadeLayer: MapStyleContent, PrimitiveMapContent {
    func visit(_ node: MapContentNode) {
        node.mount(MountedLayer(layer: self))
    }
}

// End of generated file.
