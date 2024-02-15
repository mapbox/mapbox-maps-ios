// This file is generated.
import Foundation

/// A heatmap.
///
/// - SeeAlso: [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-style-spec/#layers-heatmap)
public struct HeatmapLayer: Layer {

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

    /// Defines the color of each pixel based on its density value in a heatmap. Should be an expression that uses `["heatmap-density"]` as input.
    public var heatmapColor: Value<StyleColor>?

    /// Similar to `heatmap-weight` but controls the intensity of the heatmap globally. Primarily used for adjusting the heatmap based on zoom level.
    public var heatmapIntensity: Value<Double>?

    /// Transition options for `heatmapIntensity`.
    public var heatmapIntensityTransition: StyleTransition?

    /// The global opacity at which the heatmap layer will be drawn.
    public var heatmapOpacity: Value<Double>?

    /// Transition options for `heatmapOpacity`.
    public var heatmapOpacityTransition: StyleTransition?

    /// Radius of influence of one heatmap point in pixels. Increasing the value makes the heatmap smoother, but less detailed. `queryRenderedFeatures` on heatmap layers will return points within this radius.
    public var heatmapRadius: Value<Double>?

    /// Transition options for `heatmapRadius`.
    public var heatmapRadiusTransition: StyleTransition?

    /// A measure of how much an individual point contributes to the heatmap. A value of 10 would be equivalent to having 10 points of weight 1 in the same spot. Especially useful when combined with clustering.
    public var heatmapWeight: Value<Double>?

    public init(id: String, source: String) {
        self.source = source
        self.id = id
        self.type = LayerType.heatmap
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
        try paintContainer.encodeIfPresent(heatmapColor, forKey: .heatmapColor)
        try paintContainer.encodeIfPresent(heatmapIntensity, forKey: .heatmapIntensity)
        try paintContainer.encodeIfPresent(heatmapIntensityTransition, forKey: .heatmapIntensityTransition)
        try paintContainer.encodeIfPresent(heatmapOpacity, forKey: .heatmapOpacity)
        try paintContainer.encodeIfPresent(heatmapOpacityTransition, forKey: .heatmapOpacityTransition)
        try paintContainer.encodeIfPresent(heatmapRadius, forKey: .heatmapRadius)
        try paintContainer.encodeIfPresent(heatmapRadiusTransition, forKey: .heatmapRadiusTransition)
        try paintContainer.encodeIfPresent(heatmapWeight, forKey: .heatmapWeight)

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
            heatmapColor = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .heatmapColor)
            heatmapIntensity = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .heatmapIntensity)
            heatmapIntensityTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .heatmapIntensityTransition)
            heatmapOpacity = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .heatmapOpacity)
            heatmapOpacityTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .heatmapOpacityTransition)
            heatmapRadius = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .heatmapRadius)
            heatmapRadiusTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .heatmapRadiusTransition)
            heatmapWeight = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .heatmapWeight)
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
        case heatmapColor = "heatmap-color"
        case heatmapIntensity = "heatmap-intensity"
        case heatmapIntensityTransition = "heatmap-intensity-transition"
        case heatmapOpacity = "heatmap-opacity"
        case heatmapOpacityTransition = "heatmap-opacity-transition"
        case heatmapRadius = "heatmap-radius"
        case heatmapRadiusTransition = "heatmap-radius-transition"
        case heatmapWeight = "heatmap-weight"
    }
}

// End of generated file.
