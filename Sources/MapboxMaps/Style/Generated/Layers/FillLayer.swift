// This file is generated.
import UIKit

/// A filled polygon with an optional stroked border.
///
/// - SeeAlso: [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-style-spec/#layers-fill)
public struct FillLayer: Layer, Equatable {

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

    /// Sorts features in ascending order based on this value. Features with a higher sort key will appear above features with a lower sort key.
    public var fillSortKey: Value<Double>?

    /// Whether or not the fill should be antialiased.
    /// Default value: true.
    public var fillAntialias: Value<Bool>?

    /// The color of the filled part of this layer. This color can be specified as `rgba` with an alpha component and the color's opacity will not affect the opacity of the 1px stroke, if it is used.
    /// Default value: "#000000".
    public var fillColor: Value<StyleColor>?

    /// Transition options for `fillColor`.
    public var fillColorTransition: StyleTransition?

    /// Controls the intensity of light emitted on the source features.
    /// Default value: 0. Minimum value: 0.
    public var fillEmissiveStrength: Value<Double>?

    /// Transition options for `fillEmissiveStrength`.
    public var fillEmissiveStrengthTransition: StyleTransition?

    /// The opacity of the entire fill layer. In contrast to the `fill-color`, this value will also affect the 1px stroke around the fill, if the stroke is used.
    /// Default value: 1. Value range: [0, 1]
    public var fillOpacity: Value<Double>?

    /// Transition options for `fillOpacity`.
    public var fillOpacityTransition: StyleTransition?

    /// The outline color of the fill. Matches the value of `fill-color` if unspecified.
    public var fillOutlineColor: Value<StyleColor>?

    /// Transition options for `fillOutlineColor`.
    public var fillOutlineColorTransition: StyleTransition?

    /// Name of image in sprite to use for drawing image fills. For seamless patterns, image width and height must be a factor of two (2, 4, 8, ..., 512). Note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    public var fillPattern: Value<ResolvedImage>?

    /// The geometry's offset. Values are [x, y] where negatives indicate left and up, respectively.
    /// Default value: [0,0].
    public var fillTranslate: Value<[Double]>?

    /// Transition options for `fillTranslate`.
    public var fillTranslateTransition: StyleTransition?

    /// Controls the frame of reference for `fill-translate`.
    /// Default value: "map".
    public var fillTranslateAnchor: Value<FillTranslateAnchor>?

    public init(id: String, source: String) {
        self.source = source
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
        try container.encodeIfPresent(slot, forKey: .slot)
        try container.encodeIfPresent(minZoom, forKey: .minZoom)
        try container.encodeIfPresent(maxZoom, forKey: .maxZoom)

        var paintContainer = container.nestedContainer(keyedBy: PaintCodingKeys.self, forKey: .paint)
        try paintContainer.encodeIfPresent(fillAntialias, forKey: .fillAntialias)
        try paintContainer.encodeIfPresent(fillColor, forKey: .fillColor)
        try paintContainer.encodeIfPresent(fillColorTransition, forKey: .fillColorTransition)
        try paintContainer.encodeIfPresent(fillEmissiveStrength, forKey: .fillEmissiveStrength)
        try paintContainer.encodeIfPresent(fillEmissiveStrengthTransition, forKey: .fillEmissiveStrengthTransition)
        try paintContainer.encodeIfPresent(fillOpacity, forKey: .fillOpacity)
        try paintContainer.encodeIfPresent(fillOpacityTransition, forKey: .fillOpacityTransition)
        try paintContainer.encodeIfPresent(fillOutlineColor, forKey: .fillOutlineColor)
        try paintContainer.encodeIfPresent(fillOutlineColorTransition, forKey: .fillOutlineColorTransition)
        try paintContainer.encodeIfPresent(fillPattern, forKey: .fillPattern)
        try paintContainer.encodeIfPresent(fillTranslate, forKey: .fillTranslate)
        try paintContainer.encodeIfPresent(fillTranslateTransition, forKey: .fillTranslateTransition)
        try paintContainer.encodeIfPresent(fillTranslateAnchor, forKey: .fillTranslateAnchor)

        var layoutContainer = container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout)
        try layoutContainer.encode(visibility, forKey: .visibility)
        try layoutContainer.encodeIfPresent(fillSortKey, forKey: .fillSortKey)
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
            fillAntialias = try paintContainer.decodeIfPresent(Value<Bool>.self, forKey: .fillAntialias)
            fillColor = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .fillColor)
            fillColorTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .fillColorTransition)
            fillEmissiveStrength = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .fillEmissiveStrength)
            fillEmissiveStrengthTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .fillEmissiveStrengthTransition)
            fillOpacity = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .fillOpacity)
            fillOpacityTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .fillOpacityTransition)
            fillOutlineColor = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .fillOutlineColor)
            fillOutlineColorTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .fillOutlineColorTransition)
            fillPattern = try paintContainer.decodeIfPresent(Value<ResolvedImage>.self, forKey: .fillPattern)
            fillTranslate = try paintContainer.decodeIfPresent(Value<[Double]>.self, forKey: .fillTranslate)
            fillTranslateTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .fillTranslateTransition)
            fillTranslateAnchor = try paintContainer.decodeIfPresent(Value<FillTranslateAnchor>.self, forKey: .fillTranslateAnchor)
        }

        var visibilityEncoded: Value<Visibility>?
        if let layoutContainer = try? container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout) {
            visibilityEncoded = try layoutContainer.decodeIfPresent(Value<Visibility>.self, forKey: .visibility)
            fillSortKey = try layoutContainer.decodeIfPresent(Value<Double>.self, forKey: .fillSortKey)
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
        case fillSortKey = "fill-sort-key"
        case visibility = "visibility"
    }

    enum PaintCodingKeys: String, CodingKey {
        case fillAntialias = "fill-antialias"
        case fillColor = "fill-color"
        case fillColorTransition = "fill-color-transition"
        case fillEmissiveStrength = "fill-emissive-strength"
        case fillEmissiveStrengthTransition = "fill-emissive-strength-transition"
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

@_documentation(visibility: public)
@_spi(Experimental) extension FillLayer {
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

    /// Sorts features in ascending order based on this value. Features with a higher sort key will appear above features with a lower sort key.
    @_documentation(visibility: public)
    public func fillSortKey(_ constant: Double) -> Self {
        with(self, setter(\.fillSortKey, .constant(constant)))
    }

    /// Sorts features in ascending order based on this value. Features with a higher sort key will appear above features with a lower sort key.
    @_documentation(visibility: public)
    public func fillSortKey(_ expression: Expression) -> Self {
        with(self, setter(\.fillSortKey, .expression(expression)))
    }

    /// Whether or not the fill should be antialiased.
    /// Default value: true.
    @_documentation(visibility: public)
    public func fillAntialias(_ constant: Bool) -> Self {
        with(self, setter(\.fillAntialias, .constant(constant)))
    }

    /// Whether or not the fill should be antialiased.
    /// Default value: true.
    @_documentation(visibility: public)
    public func fillAntialias(_ expression: Expression) -> Self {
        with(self, setter(\.fillAntialias, .expression(expression)))
    }

    /// The color of the filled part of this layer. This color can be specified as `rgba` with an alpha component and the color's opacity will not affect the opacity of the 1px stroke, if it is used.
    /// Default value: "#000000".
    @_documentation(visibility: public)
    public func fillColor(_ constant: StyleColor) -> Self {
        with(self, setter(\.fillColor, .constant(constant)))
    }

    /// The color of the filled part of this layer. This color can be specified as `rgba` with an alpha component and the color's opacity will not affect the opacity of the 1px stroke, if it is used.
    /// Default value: "#000000".
    @_documentation(visibility: public)
    public func fillColor(_ color: UIColor) -> Self {
        with(self, setter(\.fillColor, .constant(StyleColor(color))))
    }

    /// Transition property for `fillColor`
    @_documentation(visibility: public)
    public func fillColorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.fillColorTransition, transition))
    }

    /// The color of the filled part of this layer. This color can be specified as `rgba` with an alpha component and the color's opacity will not affect the opacity of the 1px stroke, if it is used.
    /// Default value: "#000000".
    @_documentation(visibility: public)
    public func fillColor(_ expression: Expression) -> Self {
        with(self, setter(\.fillColor, .expression(expression)))
    }

    /// Controls the intensity of light emitted on the source features.
    /// Default value: 0. Minimum value: 0.
    @_documentation(visibility: public)
    public func fillEmissiveStrength(_ constant: Double) -> Self {
        with(self, setter(\.fillEmissiveStrength, .constant(constant)))
    }

    /// Transition property for `fillEmissiveStrength`
    @_documentation(visibility: public)
    public func fillEmissiveStrengthTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.fillEmissiveStrengthTransition, transition))
    }

    /// Controls the intensity of light emitted on the source features.
    /// Default value: 0. Minimum value: 0.
    @_documentation(visibility: public)
    public func fillEmissiveStrength(_ expression: Expression) -> Self {
        with(self, setter(\.fillEmissiveStrength, .expression(expression)))
    }

    /// The opacity of the entire fill layer. In contrast to the `fill-color`, this value will also affect the 1px stroke around the fill, if the stroke is used.
    /// Default value: 1. Value range: [0, 1]
    @_documentation(visibility: public)
    public func fillOpacity(_ constant: Double) -> Self {
        with(self, setter(\.fillOpacity, .constant(constant)))
    }

    /// Transition property for `fillOpacity`
    @_documentation(visibility: public)
    public func fillOpacityTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.fillOpacityTransition, transition))
    }

    /// The opacity of the entire fill layer. In contrast to the `fill-color`, this value will also affect the 1px stroke around the fill, if the stroke is used.
    /// Default value: 1. Value range: [0, 1]
    @_documentation(visibility: public)
    public func fillOpacity(_ expression: Expression) -> Self {
        with(self, setter(\.fillOpacity, .expression(expression)))
    }

    /// The outline color of the fill. Matches the value of `fill-color` if unspecified.
    @_documentation(visibility: public)
    public func fillOutlineColor(_ constant: StyleColor) -> Self {
        with(self, setter(\.fillOutlineColor, .constant(constant)))
    }

    /// The outline color of the fill. Matches the value of `fill-color` if unspecified.
    @_documentation(visibility: public)
    public func fillOutlineColor(_ color: UIColor) -> Self {
        with(self, setter(\.fillOutlineColor, .constant(StyleColor(color))))
    }

    /// Transition property for `fillOutlineColor`
    @_documentation(visibility: public)
    public func fillOutlineColorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.fillOutlineColorTransition, transition))
    }

    /// The outline color of the fill. Matches the value of `fill-color` if unspecified.
    @_documentation(visibility: public)
    public func fillOutlineColor(_ expression: Expression) -> Self {
        with(self, setter(\.fillOutlineColor, .expression(expression)))
    }

    /// Name of image in sprite to use for drawing image fills. For seamless patterns, image width and height must be a factor of two (2, 4, 8, ..., 512). Note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    @_documentation(visibility: public)
    public func fillPattern(_ constant: String) -> Self {
        with(self, setter(\.fillPattern, .constant(.name(constant))))
    }

    /// Name of image in sprite to use for drawing image fills. For seamless patterns, image width and height must be a factor of two (2, 4, 8, ..., 512). Note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    @_documentation(visibility: public)
    public func fillPattern(_ expression: Expression) -> Self {
        with(self, setter(\.fillPattern, .expression(expression)))
    }

    /// The geometry's offset. Values are [x, y] where negatives indicate left and up, respectively.
    /// Default value: [0,0].
    @_documentation(visibility: public)
    public func fillTranslate(x: Double, y: Double) -> Self {
        with(self, setter(\.fillTranslate, .constant([x, y])))
    }

    /// Transition property for `fillTranslate`
    @_documentation(visibility: public)
    public func fillTranslateTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.fillTranslateTransition, transition))
    }

    /// The geometry's offset. Values are [x, y] where negatives indicate left and up, respectively.
    /// Default value: [0,0].
    @_documentation(visibility: public)
    public func fillTranslate(_ expression: Expression) -> Self {
        with(self, setter(\.fillTranslate, .expression(expression)))
    }

    /// Controls the frame of reference for `fill-translate`.
    /// Default value: "map".
    @_documentation(visibility: public)
    public func fillTranslateAnchor(_ constant: FillTranslateAnchor) -> Self {
        with(self, setter(\.fillTranslateAnchor, .constant(constant)))
    }

    /// Controls the frame of reference for `fill-translate`.
    /// Default value: "map".
    @_documentation(visibility: public)
    public func fillTranslateAnchor(_ expression: Expression) -> Self {
        with(self, setter(\.fillTranslateAnchor, .expression(expression)))
    }
}

@available(iOS 13.0, *)
@_spi(Experimental)
extension FillLayer: MapStyleContent, PrimitiveMapContent {
    func visit(_ node: MapContentNode) {
        node.mount(MountedLayer(layer: self))
    }
}

// End of generated file.
