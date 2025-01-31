// This file is generated.
import UIKit

/// A heatmap.
///
/// - SeeAlso: [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-style-spec/#layers-heatmap)
public struct HeatmapLayer: Layer, Equatable {

    // MARK: - Conformance to `Layer` protocol
    /// Unique layer name
    public var id: String

    /// Rendering type of this layer.
    public let type: LayerType

    /// An expression specifying conditions on source features.
    /// Only features that match the filter are displayed.
    public var filter: Exp?

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
    /// Default value: ["interpolate",["linear"],["heatmap-density"],0,"rgba(0, 0, 255, 0)",0.1,"royalblue",0.3,"cyan",0.5,"lime",0.7,"yellow",1,"red"].
    public var heatmapColor: Value<StyleColor>?
    /// This property defines whether to use colorTheme defined color or not.
    /// By default it will use color defined by the root theme in the style.
    /// NOTE: - Expressions set to this property currently don't work.
    @_spi(Experimental) public var heatmapColorUseTheme: Value<ColorUseTheme>?

    /// Similar to `heatmap-weight` but controls the intensity of the heatmap globally. Primarily used for adjusting the heatmap based on zoom level.
    /// Default value: 1. Minimum value: 0.
    public var heatmapIntensity: Value<Double>?

    /// Transition options for `heatmapIntensity`.
    public var heatmapIntensityTransition: StyleTransition?

    /// The global opacity at which the heatmap layer will be drawn.
    /// Default value: 1. Value range: [0, 1]
    public var heatmapOpacity: Value<Double>?

    /// Transition options for `heatmapOpacity`.
    public var heatmapOpacityTransition: StyleTransition?

    /// Radius of influence of one heatmap point in pixels. Increasing the value makes the heatmap smoother, but less detailed. `queryRenderedFeatures` on heatmap layers will return points within this radius.
    /// Default value: 30. Minimum value: 1. The unit of heatmapRadius is in pixels.
    public var heatmapRadius: Value<Double>?

    /// Transition options for `heatmapRadius`.
    public var heatmapRadiusTransition: StyleTransition?

    /// A measure of how much an individual point contributes to the heatmap. A value of 10 would be equivalent to having 10 points of weight 1 in the same spot. Especially useful when combined with clustering.
    /// Default value: 1. Minimum value: 0.
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
        try paintContainer.encodeIfPresent(heatmapColorUseTheme, forKey: .heatmapColorUseTheme)
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
        filter = try container.decodeIfPresent(Exp.self, forKey: .filter)
        source = try container.decodeIfPresent(String.self, forKey: .source)
        sourceLayer = try container.decodeIfPresent(String.self, forKey: .sourceLayer)
        slot = try container.decodeIfPresent(Slot.self, forKey: .slot)
        minZoom = try container.decodeIfPresent(Double.self, forKey: .minZoom)
        maxZoom = try container.decodeIfPresent(Double.self, forKey: .maxZoom)

        if let paintContainer = try? container.nestedContainer(keyedBy: PaintCodingKeys.self, forKey: .paint) {
            heatmapColor = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .heatmapColor)
            heatmapColorUseTheme = try paintContainer.decodeIfPresent(Value<ColorUseTheme>.self, forKey: .heatmapColorUseTheme)
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
        case heatmapColorUseTheme = "heatmap-color-use-theme"
        case heatmapIntensity = "heatmap-intensity"
        case heatmapIntensityTransition = "heatmap-intensity-transition"
        case heatmapOpacity = "heatmap-opacity"
        case heatmapOpacityTransition = "heatmap-opacity-transition"
        case heatmapRadius = "heatmap-radius"
        case heatmapRadiusTransition = "heatmap-radius-transition"
        case heatmapWeight = "heatmap-weight"
    }
}

extension HeatmapLayer {
    /// An expression specifying conditions on source features.
    /// Only features that match the filter are displayed.
    public func filter(_ newValue: Exp) -> Self {
        with(self, setter(\.filter, newValue))
    }

    /// Name of a source description to be used for this layer.
    /// Required for all layer types except ``BackgroundLayer``, ``SkyLayer``, and ``LocationIndicatorLayer``.
    public func source(_ newValue: String) -> Self {
        with(self, setter(\.source, newValue))
    }

    /// Layer to use from a vector tile source.
    ///
    /// Required for vector tile sources.
    /// Prohibited for all other source types, including GeoJSON sources.
    public func sourceLayer(_ newValue: String) -> Self {
        with(self, setter(\.sourceLayer, newValue))
    }

    /// The slot this layer is assigned to.
    /// If specified, and a slot with that name exists, it will be placed at that position in the layer order.
    public func slot(_ newValue: Slot?) -> Self {
        with(self, setter(\.slot, newValue))
    }

    /// The minimum zoom level for the layer. At zoom levels less than the minzoom, the layer will be hidden.
    public func minZoom(_ newValue: Double) -> Self {
        with(self, setter(\.minZoom, newValue))
    }

    /// The maximum zoom level for the layer. At zoom levels equal to or greater than the maxzoom, the layer will be hidden.
    public func maxZoom(_ newValue: Double) -> Self {
        with(self, setter(\.maxZoom, newValue))
    }

    /// Defines the color of each pixel based on its density value in a heatmap. Should be an expression that uses `["heatmap-density"]` as input.
    /// Default value: ["interpolate",["linear"],["heatmap-density"],0,"rgba(0, 0, 255, 0)",0.1,"royalblue",0.3,"cyan",0.5,"lime",0.7,"yellow",1,"red"].
    public func heatmapColor(_ constant: StyleColor) -> Self {
        with(self, setter(\.heatmapColor, .constant(constant)))
    }

    /// Defines the color of each pixel based on its density value in a heatmap. Should be an expression that uses `["heatmap-density"]` as input.
    /// Default value: ["interpolate",["linear"],["heatmap-density"],0,"rgba(0, 0, 255, 0)",0.1,"royalblue",0.3,"cyan",0.5,"lime",0.7,"yellow",1,"red"].
    public func heatmapColor(_ color: UIColor) -> Self {
        with(self, setter(\.heatmapColor, .constant(StyleColor(color))))
    }

    /// Defines the color of each pixel based on its density value in a heatmap. Should be an expression that uses `["heatmap-density"]` as input.
    /// Default value: ["interpolate",["linear"],["heatmap-density"],0,"rgba(0, 0, 255, 0)",0.1,"royalblue",0.3,"cyan",0.5,"lime",0.7,"yellow",1,"red"].
    public func heatmapColor(_ expression: Exp) -> Self {
        with(self, setter(\.heatmapColor, .expression(expression)))
    }

    /// This property defines whether the `heatmapColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func heatmapColorUseTheme(_ useTheme: ColorUseTheme) -> Self {
        with(self, setter(\.heatmapColorUseTheme, .constant(useTheme)))
    }

    /// This property defines whether the `heatmapColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func heatmapColorUseTheme(_ expression: Exp) -> Self {
        with(self, setter(\.heatmapColorUseTheme, .expression(expression)))
    }

    /// Similar to `heatmap-weight` but controls the intensity of the heatmap globally. Primarily used for adjusting the heatmap based on zoom level.
    /// Default value: 1. Minimum value: 0.
    public func heatmapIntensity(_ constant: Double) -> Self {
        with(self, setter(\.heatmapIntensity, .constant(constant)))
    }

    /// Transition property for `heatmapIntensity`
    public func heatmapIntensityTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.heatmapIntensityTransition, transition))
    }

    /// Similar to `heatmap-weight` but controls the intensity of the heatmap globally. Primarily used for adjusting the heatmap based on zoom level.
    /// Default value: 1. Minimum value: 0.
    public func heatmapIntensity(_ expression: Exp) -> Self {
        with(self, setter(\.heatmapIntensity, .expression(expression)))
    }

    /// The global opacity at which the heatmap layer will be drawn.
    /// Default value: 1. Value range: [0, 1]
    public func heatmapOpacity(_ constant: Double) -> Self {
        with(self, setter(\.heatmapOpacity, .constant(constant)))
    }

    /// Transition property for `heatmapOpacity`
    public func heatmapOpacityTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.heatmapOpacityTransition, transition))
    }

    /// The global opacity at which the heatmap layer will be drawn.
    /// Default value: 1. Value range: [0, 1]
    public func heatmapOpacity(_ expression: Exp) -> Self {
        with(self, setter(\.heatmapOpacity, .expression(expression)))
    }

    /// Radius of influence of one heatmap point in pixels. Increasing the value makes the heatmap smoother, but less detailed. `queryRenderedFeatures` on heatmap layers will return points within this radius.
    /// Default value: 30. Minimum value: 1. The unit of heatmapRadius is in pixels.
    public func heatmapRadius(_ constant: Double) -> Self {
        with(self, setter(\.heatmapRadius, .constant(constant)))
    }

    /// Transition property for `heatmapRadius`
    public func heatmapRadiusTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.heatmapRadiusTransition, transition))
    }

    /// Radius of influence of one heatmap point in pixels. Increasing the value makes the heatmap smoother, but less detailed. `queryRenderedFeatures` on heatmap layers will return points within this radius.
    /// Default value: 30. Minimum value: 1. The unit of heatmapRadius is in pixels.
    public func heatmapRadius(_ expression: Exp) -> Self {
        with(self, setter(\.heatmapRadius, .expression(expression)))
    }

    /// A measure of how much an individual point contributes to the heatmap. A value of 10 would be equivalent to having 10 points of weight 1 in the same spot. Especially useful when combined with clustering.
    /// Default value: 1. Minimum value: 0.
    public func heatmapWeight(_ constant: Double) -> Self {
        with(self, setter(\.heatmapWeight, .constant(constant)))
    }

    /// A measure of how much an individual point contributes to the heatmap. A value of 10 would be equivalent to having 10 points of weight 1 in the same spot. Especially useful when combined with clustering.
    /// Default value: 1. Minimum value: 0.
    public func heatmapWeight(_ expression: Exp) -> Self {
        with(self, setter(\.heatmapWeight, .expression(expression)))
    }
}

extension HeatmapLayer: MapStyleContent, PrimitiveMapContent {
    func visit(_ node: MapContentNode) {
        node.mount(MountedLayer(layer: self))
    }
}

// End of generated file.
