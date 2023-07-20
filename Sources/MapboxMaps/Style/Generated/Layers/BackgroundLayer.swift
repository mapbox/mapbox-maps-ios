// This file is generated.
import Foundation

/// The background color or pattern of the map.
///
/// - SeeAlso: [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-style-spec/#layers-background)
public struct BackgroundLayer: Layer {

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

    /// The minimum zoom level for the layer. At zoom levels less than the minzoom, the layer will be hidden.
    public var minZoom: Double?

    /// The maximum zoom level for the layer. At zoom levels equal to or greater than the maxzoom, the layer will be hidden.
    public var maxZoom: Double?

    /// Whether this layer is displayed.
    public var visibility: Visibility

    /// The color with which the background will be drawn.
    public var backgroundColor: Value<StyleColor>?

    /// Transition options for `backgroundColor`.
    public var backgroundColorTransition: StyleTransition?

    /// Emission strength.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    @_spi(Experimental) public var backgroundEmissiveStrength: Value<Double>?

    /// Transition options for `backgroundEmissiveStrength`.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    @_spi(Experimental) public var backgroundEmissiveStrengthTransition: StyleTransition?

    /// The opacity at which the background will be drawn.
    public var backgroundOpacity: Value<Double>?

    /// Transition options for `backgroundOpacity`.
    public var backgroundOpacityTransition: StyleTransition?

    /// Name of image in sprite to use for drawing an image background. For seamless patterns, image width and height must be a factor of two (2, 4, 8, ..., 512). Note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    public var backgroundPattern: Value<ResolvedImage>?

    public init(id: String) {
        self.id = id
        self.type = LayerType.background
        self.visibility = .visible
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: RootCodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(filter, forKey: .filter)
        try container.encodeIfPresent(source, forKey: .source)
        try container.encodeIfPresent(sourceLayer, forKey: .sourceLayer)
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
        try layoutContainer.encodeIfPresent(visibility, forKey: .visibility)
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
            backgroundColor = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .backgroundColor)
            backgroundColorTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .backgroundColorTransition)
            backgroundEmissiveStrength = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .backgroundEmissiveStrength)
            backgroundEmissiveStrengthTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .backgroundEmissiveStrengthTransition)
            backgroundOpacity = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .backgroundOpacity)
            backgroundOpacityTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .backgroundOpacityTransition)
            backgroundPattern = try paintContainer.decodeIfPresent(Value<ResolvedImage>.self, forKey: .backgroundPattern)
        }

        var visibilityEncoded: Visibility?
        if let layoutContainer = try? container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout) {
            visibilityEncoded = try layoutContainer.decodeIfPresent(Visibility.self, forKey: .visibility)
        }
        visibility = visibilityEncoded  ?? .visible
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
        case backgroundColor = "background-color"
        case backgroundColorTransition = "background-color-transition"
        case backgroundEmissiveStrength = "background-emissive-strength"
        case backgroundEmissiveStrengthTransition = "background-emissive-strength-transition"
        case backgroundOpacity = "background-opacity"
        case backgroundOpacityTransition = "background-opacity-transition"
        case backgroundPattern = "background-pattern"
    }
}

// End of generated file.
