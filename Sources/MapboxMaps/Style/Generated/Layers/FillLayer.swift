// This file is generated.
import Foundation

/// A filled polygon with an optional stroked border.
///
/// - SeeAlso: [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-style-spec/#layers-fill)
public struct FillLayer: Layer {

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

    /// Sorts features in ascending order based on this value. Features with a higher sort key will appear above features with a lower sort key.
    public var fillSortKey: Value<Double>?

    /// Whether or not the fill should be antialiased.
    public var fillAntialias: Value<Bool>?

    /// The color of the filled part of this layer. This color can be specified as `rgba` with an alpha component and the color's opacity will not affect the opacity of the 1px stroke, if it is used.
    public var fillColor: Value<StyleColor>?

    /// Transition options for `fillColor`.
    public var fillColorTransition: StyleTransition?

    /// The opacity of the entire fill layer. In contrast to the `fill-color`, this value will also affect the 1px stroke around the fill, if the stroke is used.
    public var fillOpacity: Value<Double>?

    /// Transition options for `fillOpacity`.
    public var fillOpacityTransition: StyleTransition?

    /// The outline color of the fill. Matches the value of `fill-color` if unspecified.
    public var fillOutlineColor: Value<StyleColor>?

    /// Transition options for `fillOutlineColor`.
    public var fillOutlineColorTransition: StyleTransition?

    /// Name of image in sprite to use for drawing image fills. For seamless patterns, image width and height must be a factor of two (2, 4, 8, ..., 512). Note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    public var fillPattern: Value<ResolvedImage>?

    /// Transition options for `fillPattern`.
    @available(*, deprecated, message: "This property is deprecated and will be removed in the future. Setting this will have no effect.")
    public var fillPatternTransition: StyleTransition?

    /// The geometry's offset. Values are [x, y] where negatives indicate left and up, respectively.
    public var fillTranslate: Value<[Double]>?

    /// Transition options for `fillTranslate`.
    public var fillTranslateTransition: StyleTransition?

    /// Controls the frame of reference for `fill-translate`.
    public var fillTranslateAnchor: Value<FillTranslateAnchor>?

    public init(id: String) {
        self.id = id
        self.type = LayerType.fill
        self.visibility = .constant(.visible)
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
        try paintContainer.encodeIfPresent(fillAntialias, forKey: .fillAntialias)
        try paintContainer.encodeIfPresent(fillColor, forKey: .fillColor)
        try paintContainer.encodeIfPresent(fillColorTransition, forKey: .fillColorTransition)
        try paintContainer.encodeIfPresent(fillOpacity, forKey: .fillOpacity)
        try paintContainer.encodeIfPresent(fillOpacityTransition, forKey: .fillOpacityTransition)
        try paintContainer.encodeIfPresent(fillOutlineColor, forKey: .fillOutlineColor)
        try paintContainer.encodeIfPresent(fillOutlineColorTransition, forKey: .fillOutlineColorTransition)
        try paintContainer.encodeIfPresent(fillPattern, forKey: .fillPattern)
        try paintContainer.encodeIfPresent(fillTranslate, forKey: .fillTranslate)
        try paintContainer.encodeIfPresent(fillTranslateTransition, forKey: .fillTranslateTransition)
        try paintContainer.encodeIfPresent(fillTranslateAnchor, forKey: .fillTranslateAnchor)

        var layoutContainer = container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout)
        try layoutContainer.encodeIfPresent(visibility, forKey: .visibility)
        try layoutContainer.encodeIfPresent(fillSortKey, forKey: .fillSortKey)
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
            fillAntialias = try paintContainer.decodeIfPresent(Value<Bool>.self, forKey: .fillAntialias)
            fillColor = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .fillColor)
            fillColorTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .fillColorTransition)
            fillOpacity = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .fillOpacity)
            fillOpacityTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .fillOpacityTransition)
            fillOutlineColor = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .fillOutlineColor)
            fillOutlineColorTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .fillOutlineColorTransition)
            fillPattern = try paintContainer.decodeIfPresent(Value<ResolvedImage>.self, forKey: .fillPattern)
            fillTranslate = try paintContainer.decodeIfPresent(Value<[Double]>.self, forKey: .fillTranslate)
            fillTranslateTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .fillTranslateTransition)
            fillTranslateAnchor = try paintContainer.decodeIfPresent(Value<FillTranslateAnchor>.self, forKey: .fillTranslateAnchor)
        }

        if let layoutContainer = try? container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout) {
            visibility = try layoutContainer.decodeIfPresent(Value<Visibility>.self, forKey: .visibility)
            fillSortKey = try layoutContainer.decodeIfPresent(Value<Double>.self, forKey: .fillSortKey)
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
        case fillSortKey = "fill-sort-key"
        case visibility = "visibility"
    }

    enum PaintCodingKeys: String, CodingKey {
        case fillAntialias = "fill-antialias"
        case fillColor = "fill-color"
        case fillColorTransition = "fill-color-transition"
        case fillOpacity = "fill-opacity"
        case fillOpacityTransition = "fill-opacity-transition"
        case fillOutlineColor = "fill-outline-color"
        case fillOutlineColorTransition = "fill-outline-color-transition"
        case fillPattern = "fill-pattern"
        case fillTranslate = "fill-translate"
        case fillTranslateTransition = "fill-translate-transition"
        case fillTranslateAnchor = "fill-translate-anchor"
    }
}

// End of generated file.
