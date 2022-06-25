// This file is generated.
import Foundation

/// Raster map textures such as satellite imagery.
///
/// - SeeAlso: [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-style-spec/#layers-raster)
public struct RasterLayer: Layer {

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

    /// Increase or reduce the brightness of the image. The value is the maximum brightness.
    public var rasterBrightnessMax: Value<Double>?

    /// Transition options for `rasterBrightnessMax`.
    public var rasterBrightnessMaxTransition: StyleTransition?

    /// Increase or reduce the brightness of the image. The value is the minimum brightness.
    public var rasterBrightnessMin: Value<Double>?

    /// Transition options for `rasterBrightnessMin`.
    public var rasterBrightnessMinTransition: StyleTransition?

    /// Increase or reduce the contrast of the image.
    public var rasterContrast: Value<Double>?

    /// Transition options for `rasterContrast`.
    public var rasterContrastTransition: StyleTransition?

    /// Fade duration when a new tile is added.
    public var rasterFadeDuration: Value<Double>?

    /// Rotates hues around the color wheel.
    public var rasterHueRotate: Value<Double>?

    /// Transition options for `rasterHueRotate`.
    public var rasterHueRotateTransition: StyleTransition?

    /// The opacity at which the image will be drawn.
    public var rasterOpacity: Value<Double>?

    /// Transition options for `rasterOpacity`.
    public var rasterOpacityTransition: StyleTransition?

    /// The resampling/interpolation method to use for overscaling, also known as texture magnification filter
    public var rasterResampling: Value<RasterResampling>?

    /// Increase or reduce the saturation of the image.
    public var rasterSaturation: Value<Double>?

    /// Transition options for `rasterSaturation`.
    public var rasterSaturationTransition: StyleTransition?

    public init(id: String) {
        self.id = id
        self.type = LayerType.raster
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
        try paintContainer.encodeIfPresent(rasterBrightnessMax, forKey: .rasterBrightnessMax)
        try paintContainer.encodeIfPresent(rasterBrightnessMaxTransition, forKey: .rasterBrightnessMaxTransition)
        try paintContainer.encodeIfPresent(rasterBrightnessMin, forKey: .rasterBrightnessMin)
        try paintContainer.encodeIfPresent(rasterBrightnessMinTransition, forKey: .rasterBrightnessMinTransition)
        try paintContainer.encodeIfPresent(rasterContrast, forKey: .rasterContrast)
        try paintContainer.encodeIfPresent(rasterContrastTransition, forKey: .rasterContrastTransition)
        try paintContainer.encodeIfPresent(rasterFadeDuration, forKey: .rasterFadeDuration)
        try paintContainer.encodeIfPresent(rasterHueRotate, forKey: .rasterHueRotate)
        try paintContainer.encodeIfPresent(rasterHueRotateTransition, forKey: .rasterHueRotateTransition)
        try paintContainer.encodeIfPresent(rasterOpacity, forKey: .rasterOpacity)
        try paintContainer.encodeIfPresent(rasterOpacityTransition, forKey: .rasterOpacityTransition)
        try paintContainer.encodeIfPresent(rasterResampling, forKey: .rasterResampling)
        try paintContainer.encodeIfPresent(rasterSaturation, forKey: .rasterSaturation)
        try paintContainer.encodeIfPresent(rasterSaturationTransition, forKey: .rasterSaturationTransition)

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
            rasterBrightnessMax = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .rasterBrightnessMax)
            rasterBrightnessMaxTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .rasterBrightnessMaxTransition)
            rasterBrightnessMin = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .rasterBrightnessMin)
            rasterBrightnessMinTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .rasterBrightnessMinTransition)
            rasterContrast = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .rasterContrast)
            rasterContrastTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .rasterContrastTransition)
            rasterFadeDuration = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .rasterFadeDuration)
            rasterHueRotate = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .rasterHueRotate)
            rasterHueRotateTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .rasterHueRotateTransition)
            rasterOpacity = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .rasterOpacity)
            rasterOpacityTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .rasterOpacityTransition)
            rasterResampling = try paintContainer.decodeIfPresent(Value<RasterResampling>.self, forKey: .rasterResampling)
            rasterSaturation = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .rasterSaturation)
            rasterSaturationTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .rasterSaturationTransition)
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
        case rasterBrightnessMax = "raster-brightness-max"
        case rasterBrightnessMaxTransition = "raster-brightness-max-transition"
        case rasterBrightnessMin = "raster-brightness-min"
        case rasterBrightnessMinTransition = "raster-brightness-min-transition"
        case rasterContrast = "raster-contrast"
        case rasterContrastTransition = "raster-contrast-transition"
        case rasterFadeDuration = "raster-fade-duration"
        case rasterHueRotate = "raster-hue-rotate"
        case rasterHueRotateTransition = "raster-hue-rotate-transition"
        case rasterOpacity = "raster-opacity"
        case rasterOpacityTransition = "raster-opacity-transition"
        case rasterResampling = "raster-resampling"
        case rasterSaturation = "raster-saturation"
        case rasterSaturationTransition = "raster-saturation-transition"
    }
}

// End of generated file.
