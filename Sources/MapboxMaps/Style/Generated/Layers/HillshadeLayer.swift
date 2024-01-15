// This file is generated.
import Foundation

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
    public var hillshadeAccentColor: Value<StyleColor>?

    /// Transition options for `hillshadeAccentColor`.
    public var hillshadeAccentColorTransition: StyleTransition?

    /// Controls the intensity of light emitted on the source features.
    public var hillshadeEmissiveStrength: Value<Double>?

    /// Transition options for `hillshadeEmissiveStrength`.
    public var hillshadeEmissiveStrengthTransition: StyleTransition?

    /// Intensity of the hillshade
    public var hillshadeExaggeration: Value<Double>?

    /// Transition options for `hillshadeExaggeration`.
    public var hillshadeExaggerationTransition: StyleTransition?

    /// The shading color of areas that faces towards the light source.
    public var hillshadeHighlightColor: Value<StyleColor>?

    /// Transition options for `hillshadeHighlightColor`.
    public var hillshadeHighlightColorTransition: StyleTransition?

    /// Direction of light source when map is rotated.
    public var hillshadeIlluminationAnchor: Value<HillshadeIlluminationAnchor>?

    /// The direction of the light source used to generate the hillshading with 0 as the top of the viewport if `hillshade-illumination-anchor` is set to `viewport` and due north if `hillshade-illumination-anchor` is set to `map` and no 3d lights enabled. If `hillshade-illumination-anchor` is set to `map` and 3d lights enabled, the direction from 3d lights is used instead.
    public var hillshadeIlluminationDirection: Value<Double>?

    /// The shading color of areas that face away from the light source.
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

#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
@_spi(Experimental) extension HillshadeLayer {

    /// An expression specifying conditions on source features.
    /// Only features that match the filter are displayed.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func filter(_ newValue: Expression) -> Self {
        with(self, setter(\.filter, newValue))
    }

    /// Name of a source description to be used for this layer.
    /// Required for all layer types except ``BackgroundLayer``, ``SkyLayer``, and ``LocationIndicatorLayer``.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func source(_ newValue: String) -> Self {
        with(self, setter(\.source, newValue))
    }

    /// Layer to use from a vector tile source.
    ///
    /// Required for vector tile sources.
    /// Prohibited for all other source types, including GeoJSON sources.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func sourceLayer(_ newValue: String) -> Self {
        with(self, setter(\.sourceLayer, newValue))
    }   
    
    /// The slot this layer is assigned to. 
    /// If specified, and a slot with that name exists, it will be placed at that position in the layer order.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func slot(_ newValue: Slot) -> Self {
        with(self, setter(\.slot, newValue))
    }

    /// The minimum zoom level for the layer. At zoom levels less than the minzoom, the layer will be hidden.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func minZoom(_ newValue: Double) -> Self {
        with(self, setter(\.minZoom, newValue))
    }

    /// The maximum zoom level for the layer. At zoom levels equal to or greater than the maxzoom, the layer will be hidden.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func maxZoom(_ newValue: Double) -> Self {
        with(self, setter(\.maxZoom, newValue))
    }

    /// The shading color used to accentuate rugged terrain like sharp cliffs and gorges.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func hillshadeAccentColor(_ newValue: Value<StyleColor>) -> Self {
        with(self, setter(\.hillshadeAccentColor, newValue))
    }    

    /// Controls the intensity of light emitted on the source features.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func hillshadeEmissiveStrength(_ newValue: Value<Double>) -> Self {
        with(self, setter(\.hillshadeEmissiveStrength, newValue))
    }    

    /// Intensity of the hillshade
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func hillshadeExaggeration(_ newValue: Value<Double>) -> Self {
        with(self, setter(\.hillshadeExaggeration, newValue))
    }    

    /// The shading color of areas that faces towards the light source.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func hillshadeHighlightColor(_ newValue: Value<StyleColor>) -> Self {
        with(self, setter(\.hillshadeHighlightColor, newValue))
    }    

    /// Direction of light source when map is rotated.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func hillshadeIlluminationAnchor(_ newValue: Value<HillshadeIlluminationAnchor>) -> Self {
        with(self, setter(\.hillshadeIlluminationAnchor, newValue))
    }    

    /// The direction of the light source used to generate the hillshading with 0 as the top of the viewport if `hillshade-illumination-anchor` is set to `viewport` and due north if `hillshade-illumination-anchor` is set to `map` and no 3d lights enabled. If `hillshade-illumination-anchor` is set to `map` and 3d lights enabled, the direction from 3d lights is used instead.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func hillshadeIlluminationDirection(_ newValue: Value<Double>) -> Self {
        with(self, setter(\.hillshadeIlluminationDirection, newValue))
    }    

    /// The shading color of areas that face away from the light source.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public func hillshadeShadowColor(_ newValue: Value<StyleColor>) -> Self {
        with(self, setter(\.hillshadeShadowColor, newValue))
    }    
}

// End of generated file.
