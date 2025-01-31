// This file is generated.
import UIKit

/// Raster map textures such as satellite imagery.
///
/// - SeeAlso: [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-style-spec/#layers-raster)
public struct RasterLayer: Layer, Equatable {

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

    /// Displayed band of raster array source layer. Defaults to the first band if not set.
    @_documentation(visibility: public)
    @_spi(Experimental) public var rasterArrayBand: Value<String>?

    /// Increase or reduce the brightness of the image. The value is the maximum brightness.
    /// Default value: 1. Value range: [0, 1]
    public var rasterBrightnessMax: Value<Double>?

    /// Transition options for `rasterBrightnessMax`.
    public var rasterBrightnessMaxTransition: StyleTransition?

    /// Increase or reduce the brightness of the image. The value is the minimum brightness.
    /// Default value: 0. Value range: [0, 1]
    public var rasterBrightnessMin: Value<Double>?

    /// Transition options for `rasterBrightnessMin`.
    public var rasterBrightnessMinTransition: StyleTransition?

    /// Defines a color map by which to colorize a raster layer, parameterized by the `["raster-value"]` expression and evaluated at 256 uniformly spaced steps over the range specified by `raster-color-range`.
    public var rasterColor: Value<StyleColor>?
    /// This property defines whether to use colorTheme defined color or not.
    /// By default it will use color defined by the root theme in the style.
    /// NOTE: - Expressions set to this property currently don't work.
    @_spi(Experimental) public var rasterColorUseTheme: Value<ColorUseTheme>?

    /// When `raster-color` is active, specifies the combination of source RGB channels used to compute the raster value. Computed using the equation `mix.r - src.r + mix.g - src.g + mix.b - src.b + mix.a`. The first three components specify the mix of source red, green, and blue channels, respectively. The fourth component serves as a constant offset and is -not- multipled by source alpha. Source alpha is instead carried through and applied as opacity to the colorized result. Default value corresponds to RGB luminosity.
    /// Default value: [0.2126,0.7152,0.0722,0].
    public var rasterColorMix: Value<[Double]>?

    /// Transition options for `rasterColorMix`.
    public var rasterColorMixTransition: StyleTransition?

    /// When `raster-color` is active, specifies the range over which `raster-color` is tabulated. Units correspond to the computed raster value via `raster-color-mix`. For `rasterarray` sources, if `raster-color-range` is unspecified, the source's stated data range is used.
    public var rasterColorRange: Value<[Double]>?

    /// Transition options for `rasterColorRange`.
    public var rasterColorRangeTransition: StyleTransition?

    /// Increase or reduce the contrast of the image.
    /// Default value: 0. Value range: [-1, 1]
    public var rasterContrast: Value<Double>?

    /// Transition options for `rasterContrast`.
    public var rasterContrastTransition: StyleTransition?

    /// Specifies an uniform elevation from the ground, in meters.
    /// Default value: 0. Minimum value: 0.
    @_documentation(visibility: public)
    @_spi(Experimental) public var rasterElevation: Value<Double>?

    /// Transition options for `rasterElevation`.
    @_documentation(visibility: public)
    @_spi(Experimental) public var rasterElevationTransition: StyleTransition?

    /// Controls the intensity of light emitted on the source features.
    /// Default value: 0. Minimum value: 0. The unit of rasterEmissiveStrength is in intensity.
    public var rasterEmissiveStrength: Value<Double>?

    /// Transition options for `rasterEmissiveStrength`.
    public var rasterEmissiveStrengthTransition: StyleTransition?

    /// Fade duration when a new tile is added.
    /// Default value: 300. Minimum value: 0. The unit of rasterFadeDuration is in milliseconds.
    public var rasterFadeDuration: Value<Double>?

    /// Rotates hues around the color wheel.
    /// Default value: 0. The unit of rasterHueRotate is in degrees.
    public var rasterHueRotate: Value<Double>?

    /// Transition options for `rasterHueRotate`.
    public var rasterHueRotateTransition: StyleTransition?

    /// The opacity at which the image will be drawn.
    /// Default value: 1. Value range: [0, 1]
    public var rasterOpacity: Value<Double>?

    /// Transition options for `rasterOpacity`.
    public var rasterOpacityTransition: StyleTransition?

    /// The resampling/interpolation method to use for overscaling, also known as texture magnification filter
    /// Default value: "linear".
    public var rasterResampling: Value<RasterResampling>?

    /// Increase or reduce the saturation of the image.
    /// Default value: 0. Value range: [-1, 1]
    public var rasterSaturation: Value<Double>?

    /// Transition options for `rasterSaturation`.
    public var rasterSaturationTransition: StyleTransition?

    public init(id: String, source: String) {
        self.source = source
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
        try container.encodeIfPresent(slot, forKey: .slot)
        try container.encodeIfPresent(minZoom, forKey: .minZoom)
        try container.encodeIfPresent(maxZoom, forKey: .maxZoom)

        var paintContainer = container.nestedContainer(keyedBy: PaintCodingKeys.self, forKey: .paint)
        try paintContainer.encodeIfPresent(rasterArrayBand, forKey: .rasterArrayBand)
        try paintContainer.encodeIfPresent(rasterBrightnessMax, forKey: .rasterBrightnessMax)
        try paintContainer.encodeIfPresent(rasterBrightnessMaxTransition, forKey: .rasterBrightnessMaxTransition)
        try paintContainer.encodeIfPresent(rasterBrightnessMin, forKey: .rasterBrightnessMin)
        try paintContainer.encodeIfPresent(rasterBrightnessMinTransition, forKey: .rasterBrightnessMinTransition)
        try paintContainer.encodeIfPresent(rasterColor, forKey: .rasterColor)
        try paintContainer.encodeIfPresent(rasterColorUseTheme, forKey: .rasterColorUseTheme)
        try paintContainer.encodeIfPresent(rasterColorMix, forKey: .rasterColorMix)
        try paintContainer.encodeIfPresent(rasterColorMixTransition, forKey: .rasterColorMixTransition)
        try paintContainer.encodeIfPresent(rasterColorRange, forKey: .rasterColorRange)
        try paintContainer.encodeIfPresent(rasterColorRangeTransition, forKey: .rasterColorRangeTransition)
        try paintContainer.encodeIfPresent(rasterContrast, forKey: .rasterContrast)
        try paintContainer.encodeIfPresent(rasterContrastTransition, forKey: .rasterContrastTransition)
        try paintContainer.encodeIfPresent(rasterElevation, forKey: .rasterElevation)
        try paintContainer.encodeIfPresent(rasterElevationTransition, forKey: .rasterElevationTransition)
        try paintContainer.encodeIfPresent(rasterEmissiveStrength, forKey: .rasterEmissiveStrength)
        try paintContainer.encodeIfPresent(rasterEmissiveStrengthTransition, forKey: .rasterEmissiveStrengthTransition)
        try paintContainer.encodeIfPresent(rasterFadeDuration, forKey: .rasterFadeDuration)
        try paintContainer.encodeIfPresent(rasterHueRotate, forKey: .rasterHueRotate)
        try paintContainer.encodeIfPresent(rasterHueRotateTransition, forKey: .rasterHueRotateTransition)
        try paintContainer.encodeIfPresent(rasterOpacity, forKey: .rasterOpacity)
        try paintContainer.encodeIfPresent(rasterOpacityTransition, forKey: .rasterOpacityTransition)
        try paintContainer.encodeIfPresent(rasterResampling, forKey: .rasterResampling)
        try paintContainer.encodeIfPresent(rasterSaturation, forKey: .rasterSaturation)
        try paintContainer.encodeIfPresent(rasterSaturationTransition, forKey: .rasterSaturationTransition)

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
            rasterArrayBand = try paintContainer.decodeIfPresent(Value<String>.self, forKey: .rasterArrayBand)
            rasterBrightnessMax = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .rasterBrightnessMax)
            rasterBrightnessMaxTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .rasterBrightnessMaxTransition)
            rasterBrightnessMin = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .rasterBrightnessMin)
            rasterBrightnessMinTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .rasterBrightnessMinTransition)
            rasterColor = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .rasterColor)
            rasterColorUseTheme = try paintContainer.decodeIfPresent(Value<ColorUseTheme>.self, forKey: .rasterColorUseTheme)
            rasterColorMix = try paintContainer.decodeIfPresent(Value<[Double]>.self, forKey: .rasterColorMix)
            rasterColorMixTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .rasterColorMixTransition)
            rasterColorRange = try paintContainer.decodeIfPresent(Value<[Double]>.self, forKey: .rasterColorRange)
            rasterColorRangeTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .rasterColorRangeTransition)
            rasterContrast = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .rasterContrast)
            rasterContrastTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .rasterContrastTransition)
            rasterElevation = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .rasterElevation)
            rasterElevationTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .rasterElevationTransition)
            rasterEmissiveStrength = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .rasterEmissiveStrength)
            rasterEmissiveStrengthTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .rasterEmissiveStrengthTransition)
            rasterFadeDuration = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .rasterFadeDuration)
            rasterHueRotate = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .rasterHueRotate)
            rasterHueRotateTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .rasterHueRotateTransition)
            rasterOpacity = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .rasterOpacity)
            rasterOpacityTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .rasterOpacityTransition)
            rasterResampling = try paintContainer.decodeIfPresent(Value<RasterResampling>.self, forKey: .rasterResampling)
            rasterSaturation = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .rasterSaturation)
            rasterSaturationTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .rasterSaturationTransition)
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
        case rasterArrayBand = "raster-array-band"
        case rasterBrightnessMax = "raster-brightness-max"
        case rasterBrightnessMaxTransition = "raster-brightness-max-transition"
        case rasterBrightnessMin = "raster-brightness-min"
        case rasterBrightnessMinTransition = "raster-brightness-min-transition"
        case rasterColor = "raster-color"
        case rasterColorUseTheme = "raster-color-use-theme"
        case rasterColorMix = "raster-color-mix"
        case rasterColorMixTransition = "raster-color-mix-transition"
        case rasterColorRange = "raster-color-range"
        case rasterColorRangeTransition = "raster-color-range-transition"
        case rasterContrast = "raster-contrast"
        case rasterContrastTransition = "raster-contrast-transition"
        case rasterElevation = "raster-elevation"
        case rasterElevationTransition = "raster-elevation-transition"
        case rasterEmissiveStrength = "raster-emissive-strength"
        case rasterEmissiveStrengthTransition = "raster-emissive-strength-transition"
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

extension RasterLayer {
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

    /// Displayed band of raster array source layer. Defaults to the first band if not set.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func rasterArrayBand(_ constant: String) -> Self {
        with(self, setter(\.rasterArrayBand, .constant(constant)))
    }

    /// Displayed band of raster array source layer. Defaults to the first band if not set.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func rasterArrayBand(_ expression: Exp) -> Self {
        with(self, setter(\.rasterArrayBand, .expression(expression)))
    }

    /// Increase or reduce the brightness of the image. The value is the maximum brightness.
    /// Default value: 1. Value range: [0, 1]
    public func rasterBrightnessMax(_ constant: Double) -> Self {
        with(self, setter(\.rasterBrightnessMax, .constant(constant)))
    }

    /// Transition property for `rasterBrightnessMax`
    public func rasterBrightnessMaxTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.rasterBrightnessMaxTransition, transition))
    }

    /// Increase or reduce the brightness of the image. The value is the maximum brightness.
    /// Default value: 1. Value range: [0, 1]
    public func rasterBrightnessMax(_ expression: Exp) -> Self {
        with(self, setter(\.rasterBrightnessMax, .expression(expression)))
    }

    /// Increase or reduce the brightness of the image. The value is the minimum brightness.
    /// Default value: 0. Value range: [0, 1]
    public func rasterBrightnessMin(_ constant: Double) -> Self {
        with(self, setter(\.rasterBrightnessMin, .constant(constant)))
    }

    /// Transition property for `rasterBrightnessMin`
    public func rasterBrightnessMinTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.rasterBrightnessMinTransition, transition))
    }

    /// Increase or reduce the brightness of the image. The value is the minimum brightness.
    /// Default value: 0. Value range: [0, 1]
    public func rasterBrightnessMin(_ expression: Exp) -> Self {
        with(self, setter(\.rasterBrightnessMin, .expression(expression)))
    }

    /// Defines a color map by which to colorize a raster layer, parameterized by the `["raster-value"]` expression and evaluated at 256 uniformly spaced steps over the range specified by `raster-color-range`.
    public func rasterColor(_ constant: StyleColor) -> Self {
        with(self, setter(\.rasterColor, .constant(constant)))
    }

    /// Defines a color map by which to colorize a raster layer, parameterized by the `["raster-value"]` expression and evaluated at 256 uniformly spaced steps over the range specified by `raster-color-range`.
    public func rasterColor(_ color: UIColor) -> Self {
        with(self, setter(\.rasterColor, .constant(StyleColor(color))))
    }

    /// Defines a color map by which to colorize a raster layer, parameterized by the `["raster-value"]` expression and evaluated at 256 uniformly spaced steps over the range specified by `raster-color-range`.
    public func rasterColor(_ expression: Exp) -> Self {
        with(self, setter(\.rasterColor, .expression(expression)))
    }

    /// This property defines whether the `rasterColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func rasterColorUseTheme(_ useTheme: ColorUseTheme) -> Self {
        with(self, setter(\.rasterColorUseTheme, .constant(useTheme)))
    }

    /// This property defines whether the `rasterColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func rasterColorUseTheme(_ expression: Exp) -> Self {
        with(self, setter(\.rasterColorUseTheme, .expression(expression)))
    }

    /// When `raster-color` is active, specifies the combination of source RGB channels used to compute the raster value. Computed using the equation `mix.r - src.r + mix.g - src.g + mix.b - src.b + mix.a`. The first three components specify the mix of source red, green, and blue channels, respectively. The fourth component serves as a constant offset and is -not- multipled by source alpha. Source alpha is instead carried through and applied as opacity to the colorized result. Default value corresponds to RGB luminosity.
    /// Default value: [0.2126,0.7152,0.0722,0].
    public func rasterColorMix(red: Double, green: Double, blue: Double, offset: Double) -> Self {
        with(self, setter(\.rasterColorMix, .constant([red, green, blue, offset])))
    }

    /// Transition property for `rasterColorMix`
    public func rasterColorMixTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.rasterColorMixTransition, transition))
    }

    /// When `raster-color` is active, specifies the combination of source RGB channels used to compute the raster value. Computed using the equation `mix.r - src.r + mix.g - src.g + mix.b - src.b + mix.a`. The first three components specify the mix of source red, green, and blue channels, respectively. The fourth component serves as a constant offset and is -not- multipled by source alpha. Source alpha is instead carried through and applied as opacity to the colorized result. Default value corresponds to RGB luminosity.
    /// Default value: [0.2126,0.7152,0.0722,0].
    public func rasterColorMix(_ expression: Exp) -> Self {
        with(self, setter(\.rasterColorMix, .expression(expression)))
    }

    /// When `raster-color` is active, specifies the range over which `raster-color` is tabulated. Units correspond to the computed raster value via `raster-color-mix`. For `rasterarray` sources, if `raster-color-range` is unspecified, the source's stated data range is used.
    public func rasterColorRange(min: Double, max: Double) -> Self {
        with(self, setter(\.rasterColorRange, .constant([min, max])))
    }

    /// Transition property for `rasterColorRange`
    public func rasterColorRangeTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.rasterColorRangeTransition, transition))
    }

    /// When `raster-color` is active, specifies the range over which `raster-color` is tabulated. Units correspond to the computed raster value via `raster-color-mix`. For `rasterarray` sources, if `raster-color-range` is unspecified, the source's stated data range is used.
    public func rasterColorRange(_ expression: Exp) -> Self {
        with(self, setter(\.rasterColorRange, .expression(expression)))
    }

    /// Increase or reduce the contrast of the image.
    /// Default value: 0. Value range: [-1, 1]
    public func rasterContrast(_ constant: Double) -> Self {
        with(self, setter(\.rasterContrast, .constant(constant)))
    }

    /// Transition property for `rasterContrast`
    public func rasterContrastTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.rasterContrastTransition, transition))
    }

    /// Increase or reduce the contrast of the image.
    /// Default value: 0. Value range: [-1, 1]
    public func rasterContrast(_ expression: Exp) -> Self {
        with(self, setter(\.rasterContrast, .expression(expression)))
    }

    /// Specifies an uniform elevation from the ground, in meters.
    /// Default value: 0. Minimum value: 0.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func rasterElevation(_ constant: Double) -> Self {
        with(self, setter(\.rasterElevation, .constant(constant)))
    }

    /// Transition property for `rasterElevation`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func rasterElevationTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.rasterElevationTransition, transition))
    }

    /// Specifies an uniform elevation from the ground, in meters.
    /// Default value: 0. Minimum value: 0.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func rasterElevation(_ expression: Exp) -> Self {
        with(self, setter(\.rasterElevation, .expression(expression)))
    }

    /// Controls the intensity of light emitted on the source features.
    /// Default value: 0. Minimum value: 0. The unit of rasterEmissiveStrength is in intensity.
    public func rasterEmissiveStrength(_ constant: Double) -> Self {
        with(self, setter(\.rasterEmissiveStrength, .constant(constant)))
    }

    /// Transition property for `rasterEmissiveStrength`
    public func rasterEmissiveStrengthTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.rasterEmissiveStrengthTransition, transition))
    }

    /// Controls the intensity of light emitted on the source features.
    /// Default value: 0. Minimum value: 0. The unit of rasterEmissiveStrength is in intensity.
    public func rasterEmissiveStrength(_ expression: Exp) -> Self {
        with(self, setter(\.rasterEmissiveStrength, .expression(expression)))
    }

    /// Fade duration when a new tile is added.
    /// Default value: 300. Minimum value: 0. The unit of rasterFadeDuration is in milliseconds.
    public func rasterFadeDuration(_ constant: Double) -> Self {
        with(self, setter(\.rasterFadeDuration, .constant(constant)))
    }

    /// Fade duration when a new tile is added.
    /// Default value: 300. Minimum value: 0. The unit of rasterFadeDuration is in milliseconds.
    public func rasterFadeDuration(_ expression: Exp) -> Self {
        with(self, setter(\.rasterFadeDuration, .expression(expression)))
    }

    /// Rotates hues around the color wheel.
    /// Default value: 0. The unit of rasterHueRotate is in degrees.
    public func rasterHueRotate(_ constant: Double) -> Self {
        with(self, setter(\.rasterHueRotate, .constant(constant)))
    }

    /// Transition property for `rasterHueRotate`
    public func rasterHueRotateTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.rasterHueRotateTransition, transition))
    }

    /// Rotates hues around the color wheel.
    /// Default value: 0. The unit of rasterHueRotate is in degrees.
    public func rasterHueRotate(_ expression: Exp) -> Self {
        with(self, setter(\.rasterHueRotate, .expression(expression)))
    }

    /// The opacity at which the image will be drawn.
    /// Default value: 1. Value range: [0, 1]
    public func rasterOpacity(_ constant: Double) -> Self {
        with(self, setter(\.rasterOpacity, .constant(constant)))
    }

    /// Transition property for `rasterOpacity`
    public func rasterOpacityTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.rasterOpacityTransition, transition))
    }

    /// The opacity at which the image will be drawn.
    /// Default value: 1. Value range: [0, 1]
    public func rasterOpacity(_ expression: Exp) -> Self {
        with(self, setter(\.rasterOpacity, .expression(expression)))
    }

    /// The resampling/interpolation method to use for overscaling, also known as texture magnification filter
    /// Default value: "linear".
    public func rasterResampling(_ constant: RasterResampling) -> Self {
        with(self, setter(\.rasterResampling, .constant(constant)))
    }

    /// The resampling/interpolation method to use for overscaling, also known as texture magnification filter
    /// Default value: "linear".
    public func rasterResampling(_ expression: Exp) -> Self {
        with(self, setter(\.rasterResampling, .expression(expression)))
    }

    /// Increase or reduce the saturation of the image.
    /// Default value: 0. Value range: [-1, 1]
    public func rasterSaturation(_ constant: Double) -> Self {
        with(self, setter(\.rasterSaturation, .constant(constant)))
    }

    /// Transition property for `rasterSaturation`
    public func rasterSaturationTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.rasterSaturationTransition, transition))
    }

    /// Increase or reduce the saturation of the image.
    /// Default value: 0. Value range: [-1, 1]
    public func rasterSaturation(_ expression: Exp) -> Self {
        with(self, setter(\.rasterSaturation, .expression(expression)))
    }
}

extension RasterLayer: MapStyleContent, PrimitiveMapContent {
    func visit(_ node: MapContentNode) {
        node.mount(MountedLayer(layer: self))
    }
}

// End of generated file.
