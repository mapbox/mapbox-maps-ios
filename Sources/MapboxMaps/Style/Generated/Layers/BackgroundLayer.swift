// This file is generated.
import Foundation

/// The background color or pattern of the map.
///
/// - SeeAlso: [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-style-spec/#layers-background)
public struct BackgroundLayer: Layer {

    // MARK: - Conformance to `Layer` protocol
    public var id: String
    public let type: LayerType
    public var filter: Expression?
    public var source: String?
    public var sourceLayer: String?
    public var minZoom: Double?
    public var maxZoom: Double?

    /// Whether this layer is displayed.
    public var visibility: Value<Visibility>?

    /// The color with which the background will be drawn.
    public var backgroundColor: Value<StyleColor>?

    /// Transition options for `backgroundColor`.
    public var backgroundColorTransition: StyleTransition?

    /// The opacity at which the background will be drawn.
    public var backgroundOpacity: Value<Double>?

    /// Transition options for `backgroundOpacity`.
    public var backgroundOpacityTransition: StyleTransition?

    /// Name of image in sprite to use for drawing an image background. For seamless patterns, image width and height must be a factor of two (2, 4, 8, ..., 512). Note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    public var backgroundPattern: Value<ResolvedImage>?

    /// Transition options for `backgroundPattern`.
    public var backgroundPatternTransition: StyleTransition?

    public init(id: String) {
        self.id = id
        self.type = LayerType.background
        self.visibility = .constant(.visible)
    }

    public func encode(to encoder: Encoder) throws {
        let nilEncoder = NilEncoder(userInfo: encoder.userInfo)

        var container = encoder.container(keyedBy: RootCodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try nilEncoder.encode(filter, forKey: .filter, to: &container)
        try nilEncoder.encode(source, forKey: .source, to: &container)
        try nilEncoder.encode(sourceLayer, forKey: .sourceLayer, to: &container)
        try nilEncoder.encode(minZoom, forKey: .minZoom, to: &container)
        try nilEncoder.encode(maxZoom, forKey: .maxZoom, to: &container)

        var paintContainer = container.nestedContainer(keyedBy: PaintCodingKeys.self, forKey: .paint)
        try nilEncoder.encode(backgroundColor, forKey: .backgroundColor, to: &paintContainer)
        try nilEncoder.encode(backgroundColorTransition, forKey: .backgroundColorTransition, to: &paintContainer)
        try nilEncoder.encode(backgroundOpacity, forKey: .backgroundOpacity, to: &paintContainer)
        try nilEncoder.encode(backgroundOpacityTransition, forKey: .backgroundOpacityTransition, to: &paintContainer)
        try nilEncoder.encode(backgroundPattern, forKey: .backgroundPattern, to: &paintContainer)
        try nilEncoder.encode(backgroundPatternTransition, forKey: .backgroundPatternTransition, to: &paintContainer)

        var layoutContainer = container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout)
        try nilEncoder.encode(visibility, forKey: .visibility, to: &layoutContainer)
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
            backgroundOpacity = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .backgroundOpacity)
            backgroundOpacityTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .backgroundOpacityTransition)
            backgroundPattern = try paintContainer.decodeIfPresent(Value<ResolvedImage>.self, forKey: .backgroundPattern)
            backgroundPatternTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .backgroundPatternTransition)
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
        case backgroundColor = "background-color"
        case backgroundColorTransition = "background-color-transition"
        case backgroundOpacity = "background-opacity"
        case backgroundOpacityTransition = "background-opacity-transition"
        case backgroundPattern = "background-pattern"
        case backgroundPatternTransition = "background-pattern-transition"
    }
}

// End of generated file.
