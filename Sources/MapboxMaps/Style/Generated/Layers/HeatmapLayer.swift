// This file is generated.
import Foundation

/// A heatmap.
///
/// - SeeAlso: [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-style-spec/#layers-heatmap)
public struct HeatmapLayer: Layer {

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

    /// Defines the color of each pixel based on its density value in a heatmap.  Should be an expression that uses `["heatmap-density"]` as input.
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

    private var modifiedProperties = Set<String>()

    public init(id: String) {
        self.id = id
        self.type = LayerType.heatmap
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
        try paintContainer.encode(heatmapColor, forKey: .heatmapColor)
        try paintContainer.encode(heatmapIntensity, forKey: .heatmapIntensity)
        try paintContainer.encode(heatmapIntensityTransition, forKey: .heatmapIntensityTransition)
        try paintContainer.encode(heatmapOpacity, forKey: .heatmapOpacity)
        try paintContainer.encode(heatmapOpacityTransition, forKey: .heatmapOpacityTransition)
        try paintContainer.encode(heatmapRadius, forKey: .heatmapRadius)
        try paintContainer.encode(heatmapRadiusTransition, forKey: .heatmapRadiusTransition)
        try paintContainer.encode(heatmapWeight, forKey: .heatmapWeight)

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
            heatmapColor = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .heatmapColor)
            heatmapIntensity = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .heatmapIntensity)
            heatmapIntensityTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .heatmapIntensityTransition)
            heatmapOpacity = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .heatmapOpacity)
            heatmapOpacityTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .heatmapOpacityTransition)
            heatmapRadius = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .heatmapRadius)
            heatmapRadiusTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .heatmapRadiusTransition)
            heatmapWeight = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .heatmapWeight)
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
        case heatmapColor = "heatmap-color"
        case heatmapIntensity = "heatmap-intensity"
        case heatmapIntensityTransition = "heatmap-intensity-transition"
        case heatmapOpacity = "heatmap-opacity"
        case heatmapOpacityTransition = "heatmap-opacity-transition"
        case heatmapRadius = "heatmap-radius"
        case heatmapRadiusTransition = "heatmap-radius-transition"
        case heatmapWeight = "heatmap-weight"
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
