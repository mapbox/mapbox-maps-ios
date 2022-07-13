// This file is generated.
import Foundation

/// Client-side hillshading visualization based on DEM data. Currently, the implementation only supports Mapbox Terrain RGB and Mapzen Terrarium tiles.
///
/// - SeeAlso: [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-style-spec/#layers-hillshade)
public struct HillshadeLayer: Layer {

    // MARK: - Conformance to `Layer` protocol
    public var id: String
    public let type: LayerType
    public var filter: Expression? {
        didSet { modifiedProperties.insert(RootCodingKeys.filter.rawValue) }
    }
    public var source: String? {
        didSet { modifiedProperties.insert(RootCodingKeys.source.rawValue) }
    }

    public var sourceLayer: String? {
        didSet { modifiedProperties.insert(RootCodingKeys.sourceLayer.rawValue) }
    }
    public var minZoom: Double? {
        didSet { modifiedProperties.insert(RootCodingKeys.minZoom.rawValue) }
    }
    public var maxZoom: Double? {
        didSet { modifiedProperties.insert(RootCodingKeys.maxZoom.rawValue) }
    }

    /// Whether this layer is displayed.
    public var visibility: Value<Visibility>?

    /// The shading color used to accentuate rugged terrain like sharp cliffs and gorges.
    public var hillshadeAccentColor: Value<StyleColor>?

    /// Transition options for `hillshadeAccentColor`.
    public var hillshadeAccentColorTransition: StyleTransition?

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

    /// The direction of the light source used to generate the hillshading with 0 as the top of the viewport if `hillshade-illumination-anchor` is set to `viewport` and due north if `hillshade-illumination-anchor` is set to `map`.
    public var hillshadeIlluminationDirection: Value<Double>?

    /// The shading color of areas that face away from the light source.
    public var hillshadeShadowColor: Value<StyleColor>?

    /// Transition options for `hillshadeShadowColor`.
    public var hillshadeShadowColorTransition: StyleTransition?

    private var modifiedProperties = Set<String>()

    public init(id: String) {
        self.id = id
        self.type = LayerType.hillshade
        self.visibility = .constant(.visible)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: RootCodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try encodeIfModified(filter, forKey: .filter, to: &container)
        try encodeIfModified(source, forKey: .source, to: &container)
        try encodeIfModified(sourceLayer, forKey: .sourceLayer, to: &container)
        try encodeIfModified(minZoom, forKey: .minZoom, to: &container)
        try encodeIfModified(maxZoom, forKey: .maxZoom, to: &container)

        var paintContainer = container.nestedContainer(keyedBy: PaintCodingKeys.self, forKey: .paint)
        try paintContainer.encode(hillshadeAccentColor, forKey: .hillshadeAccentColor)
        try paintContainer.encode(hillshadeAccentColorTransition, forKey: .hillshadeAccentColorTransition)
        try paintContainer.encode(hillshadeExaggeration, forKey: .hillshadeExaggeration)
        try paintContainer.encode(hillshadeExaggerationTransition, forKey: .hillshadeExaggerationTransition)
        try paintContainer.encode(hillshadeHighlightColor, forKey: .hillshadeHighlightColor)
        try paintContainer.encode(hillshadeHighlightColorTransition, forKey: .hillshadeHighlightColorTransition)
        try paintContainer.encode(hillshadeIlluminationAnchor, forKey: .hillshadeIlluminationAnchor)
        try paintContainer.encode(hillshadeIlluminationDirection, forKey: .hillshadeIlluminationDirection)
        try paintContainer.encode(hillshadeShadowColor, forKey: .hillshadeShadowColor)
        try paintContainer.encode(hillshadeShadowColorTransition, forKey: .hillshadeShadowColorTransition)

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
        minZoom = try container.decodeIfPresent(Double.self, forKey: .minZoom)
        maxZoom = try container.decodeIfPresent(Double.self, forKey: .maxZoom)

        if let paintContainer = try? container.nestedContainer(keyedBy: PaintCodingKeys.self, forKey: .paint) {
            hillshadeAccentColor = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .hillshadeAccentColor)
            hillshadeAccentColorTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .hillshadeAccentColorTransition)
            hillshadeExaggeration = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .hillshadeExaggeration)
            hillshadeExaggerationTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .hillshadeExaggerationTransition)
            hillshadeHighlightColor = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .hillshadeHighlightColor)
            hillshadeHighlightColorTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .hillshadeHighlightColorTransition)
            hillshadeIlluminationAnchor = try paintContainer.decodeIfPresent(Value<HillshadeIlluminationAnchor>.self, forKey: .hillshadeIlluminationAnchor)
            hillshadeIlluminationDirection = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .hillshadeIlluminationDirection)
            hillshadeShadowColor = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .hillshadeShadowColor)
            hillshadeShadowColorTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .hillshadeShadowColorTransition)
        }

        if let layoutContainer = try? container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout) {
            visibility = try layoutContainer.decodeIfPresent(Value<Visibility>.self, forKey: .visibility)
        }
    }

    enum RootCodingKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case filter = "filter"
        case source = "source"
        case sourceLayer = "source-layer"
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
        case hillshadeExaggeration = "hillshade-exaggeration"
        case hillshadeExaggerationTransition = "hillshade-exaggeration-transition"
        case hillshadeHighlightColor = "hillshade-highlight-color"
        case hillshadeHighlightColorTransition = "hillshade-highlight-color-transition"
        case hillshadeIlluminationAnchor = "hillshade-illumination-anchor"
        case hillshadeIlluminationDirection = "hillshade-illumination-direction"
        case hillshadeShadowColor = "hillshade-shadow-color"
        case hillshadeShadowColorTransition = "hillshade-shadow-color-transition"
    }

    private func encodeIfModified<E: Encodable, Key: CodingKey>(
        _ encodable: E?,
        forKey key: Key,
        to container: inout KeyedEncodingContainer<Key>
    ) throws {
        guard modifiedProperties.contains(key.stringValue) else {
            return
        }
        try container.encode(encodable ?? defaultValue(for: key), forKey: key)
    }
}

// End of generated file.
