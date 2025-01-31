// This file is generated. Do not edit.

import Foundation
import UIKit

/// Rain particles over the map
///
/// - SeeAlso: [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-style-spec/#rain)
@_documentation(visibility: public)
@_spi(Experimental)
public struct Rain: Codable, Equatable, StyleEncodable {

    /// Builds a new instance of Rain with the default values.
    public init() { }

    /// Thinning factor of rain particles from center. 0 - no thinning. 1 - maximal central area thinning.
    /// Default value: 0.57. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var centerThinning: Value<Double>?

    /// Transition options for center-thinning
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var centerThinningTransition: StyleTransition?
    /// Use theme flag for center-thinning
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var centerThinningUseTheme: Value<ColorUseTheme>?

    /// Individual rain particle dorplets color.
    /// Default value: "["interpolate",["linear"],["measure-light","brightness"],0,"#03113d",0.3,"#a8adbc"]".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var color: Value<StyleColor>?

    /// Transition options for color
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var colorTransition: StyleTransition?
    /// Use theme flag for color
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var colorUseTheme: Value<ColorUseTheme>?

    /// Rain particles density. Controls the overall screen density of the rain.
    /// Default value: "["interpolate",["linear"],["zoom"],11,0,13,0.5]". Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var density: Value<Double>?

    /// Transition options for density
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var densityTransition: StyleTransition?
    /// Use theme flag for density
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var densityUseTheme: Value<ColorUseTheme>?

    /// Main rain particles direction. Azimuth and polar angles.
    /// Default value: [0,80]. Value range: [0, 360]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var direction: Value<[Double]>?

    /// Transition options for direction
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var directionTransition: StyleTransition?
    /// Use theme flag for direction
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var directionUseTheme: Value<ColorUseTheme>?

    /// Rain particles screen-space distortion strength.
    /// Default value: 0.7. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var distortionStrength: Value<Double>?

    /// Transition options for distortion-strength
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var distortionStrengthTransition: StyleTransition?
    /// Use theme flag for distortion-strength
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var distortionStrengthUseTheme: Value<ColorUseTheme>?

    /// Rain droplet size. x - normal to direction, y - along direction
    /// Default value: [2.6,18.2]. Value range: [0, 50]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var dropletSize: Value<[Double]>?

    /// Transition options for droplet-size
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var dropletSizeTransition: StyleTransition?
    /// Use theme flag for droplet-size
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var dropletSizeUseTheme: Value<ColorUseTheme>?

    /// Rain particles movement factor. Controls the overall rain particles speed
    /// Default value: 1. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var intensity: Value<Double>?

    /// Transition options for intensity
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var intensityTransition: StyleTransition?
    /// Use theme flag for intensity
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var intensityUseTheme: Value<ColorUseTheme>?

    /// Rain particles opacity.
    /// Default value: "["interpolate",["linear"],["measure-light","brightness"],0,0.88,1,0.7]". Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var opacity: Value<Double>?

    /// Transition options for opacity
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var opacityTransition: StyleTransition?
    /// Use theme flag for opacity
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var opacityUseTheme: Value<ColorUseTheme>?

    /// Screen-space vignette rain tinting effect intensity.
    /// Default value: "["interpolate",["linear"],["zoom"],11,0,13,1]". Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var vignette: Value<Double>?

    /// Transition options for vignette
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var vignetteTransition: StyleTransition?
    /// Use theme flag for vignette
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var vignetteUseTheme: Value<ColorUseTheme>?

    /// Rain vignette screen-space corners tint color.
    /// Default value: "["interpolate",["linear"],["measure-light","brightness"],0,"#001736",0.3,"#464646"]".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var vignetteColor: Value<StyleColor>?

    /// Transition options for vignette-color
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var vignetteColorTransition: StyleTransition?
    /// Use theme flag for vignette-color
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var vignetteColorUseTheme: Value<ColorUseTheme>?

    public enum CodingKeys: String, CodingKey {
        case centerThinning = "center-thinning"
        case centerThinningTransition = "center-thinning-transition"
        case color = "color"
        case colorTransition = "color-transition"
        case density = "density"
        case densityTransition = "density-transition"
        case direction = "direction"
        case directionTransition = "direction-transition"
        case distortionStrength = "distortion-strength"
        case distortionStrengthTransition = "distortion-strength-transition"
        case dropletSize = "droplet-size"
        case dropletSizeTransition = "droplet-size-transition"
        case intensity = "intensity"
        case intensityTransition = "intensity-transition"
        case opacity = "opacity"
        case opacityTransition = "opacity-transition"
        case vignette = "vignette"
        case vignetteTransition = "vignette-transition"
        case vignetteColor = "vignette-color"
        case vignetteColorTransition = "vignette-color-transition"
    }
}

extension Rain {
    /// Thinning factor of rain particles from center. 0 - no thinning. 1 - maximal central area thinning.
    /// Default value: 0.57. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func centerThinning(_ constant: Double) -> Self {
        with(self, setter(\.centerThinning, .constant(constant)))
    }

    /// Transition property for `centerThinning`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func centerThinningTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.centerThinningTransition, transition))
    }

    /// Thinning factor of rain particles from center. 0 - no thinning. 1 - maximal central area thinning.
    /// Default value: 0.57. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func centerThinning(_ expression: Exp) -> Self {
        with(self, setter(\.centerThinning, .expression(expression)))
    }

    /// Individual rain particle dorplets color.
    /// Default value: "["interpolate",["linear"],["measure-light","brightness"],0,"#03113d",0.3,"#a8adbc"]".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func color(_ constant: StyleColor) -> Self {
        with(self, setter(\.color, .constant(constant)))
    }

    /// Individual rain particle dorplets color.
    /// Default value: "["interpolate",["linear"],["measure-light","brightness"],0,"#03113d",0.3,"#a8adbc"]".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func color(_ color: UIColor) -> Self {
        with(self, setter(\.color, .constant(StyleColor(color))))
    }

    /// Transition property for `color`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func colorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.colorTransition, transition))
    }

    /// Individual rain particle dorplets color.
    /// Default value: "["interpolate",["linear"],["measure-light","brightness"],0,"#03113d",0.3,"#a8adbc"]".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func color(_ expression: Exp) -> Self {
        with(self, setter(\.color, .expression(expression)))
    }

    /// This property defines whether the `color` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func colorUseTheme(_ useTheme: ColorUseTheme) -> Self {
        with(self, setter(\.colorUseTheme, .constant(useTheme)))
    }

    /// This property defines whether the `color` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func colorUseTheme(_ expression: Exp) -> Self {
        with(self, setter(\.colorUseTheme, .expression(expression)))
    }

    /// Rain particles density. Controls the overall screen density of the rain.
    /// Default value: "["interpolate",["linear"],["zoom"],11,0,13,0.5]". Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func density(_ constant: Double) -> Self {
        with(self, setter(\.density, .constant(constant)))
    }

    /// Transition property for `density`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func densityTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.densityTransition, transition))
    }

    /// Rain particles density. Controls the overall screen density of the rain.
    /// Default value: "["interpolate",["linear"],["zoom"],11,0,13,0.5]". Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func density(_ expression: Exp) -> Self {
        with(self, setter(\.density, .expression(expression)))
    }

    /// Main rain particles direction. Azimuth and polar angles.
    /// Default value: [0,80]. Value range: [0, 360]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func direction(azimuthal: Double, polar: Double) -> Self {
        with(self, setter(\.direction, .constant([azimuthal, polar])))
    }

    /// Transition property for `direction`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func directionTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.directionTransition, transition))
    }

    /// Main rain particles direction. Azimuth and polar angles.
    /// Default value: [0,80]. Value range: [0, 360]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func direction(_ expression: Exp) -> Self {
        with(self, setter(\.direction, .expression(expression)))
    }

    /// Rain particles screen-space distortion strength.
    /// Default value: 0.7. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func distortionStrength(_ constant: Double) -> Self {
        with(self, setter(\.distortionStrength, .constant(constant)))
    }

    /// Transition property for `distortionStrength`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func distortionStrengthTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.distortionStrengthTransition, transition))
    }

    /// Rain particles screen-space distortion strength.
    /// Default value: 0.7. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func distortionStrength(_ expression: Exp) -> Self {
        with(self, setter(\.distortionStrength, .expression(expression)))
    }

    /// Rain droplet size. x - normal to direction, y - along direction
    /// Default value: [2.6,18.2]. Value range: [0, 50]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func dropletSize(normalToDirection: Double, alongDirection: Double) -> Self {
        with(self, setter(\.dropletSize, .constant([normalToDirection, alongDirection])))
    }

    /// Transition property for `dropletSize`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func dropletSizeTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.dropletSizeTransition, transition))
    }

    /// Rain droplet size. x - normal to direction, y - along direction
    /// Default value: [2.6,18.2]. Value range: [0, 50]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func dropletSize(_ expression: Exp) -> Self {
        with(self, setter(\.dropletSize, .expression(expression)))
    }

    /// Rain particles movement factor. Controls the overall rain particles speed
    /// Default value: 1. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func intensity(_ constant: Double) -> Self {
        with(self, setter(\.intensity, .constant(constant)))
    }

    /// Transition property for `intensity`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func intensityTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.intensityTransition, transition))
    }

    /// Rain particles movement factor. Controls the overall rain particles speed
    /// Default value: 1. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func intensity(_ expression: Exp) -> Self {
        with(self, setter(\.intensity, .expression(expression)))
    }

    /// Rain particles opacity.
    /// Default value: "["interpolate",["linear"],["measure-light","brightness"],0,0.88,1,0.7]". Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func opacity(_ constant: Double) -> Self {
        with(self, setter(\.opacity, .constant(constant)))
    }

    /// Transition property for `opacity`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func opacityTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.opacityTransition, transition))
    }

    /// Rain particles opacity.
    /// Default value: "["interpolate",["linear"],["measure-light","brightness"],0,0.88,1,0.7]". Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func opacity(_ expression: Exp) -> Self {
        with(self, setter(\.opacity, .expression(expression)))
    }

    /// Screen-space vignette rain tinting effect intensity.
    /// Default value: "["interpolate",["linear"],["zoom"],11,0,13,1]". Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func vignette(_ constant: Double) -> Self {
        with(self, setter(\.vignette, .constant(constant)))
    }

    /// Transition property for `vignette`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func vignetteTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.vignetteTransition, transition))
    }

    /// Screen-space vignette rain tinting effect intensity.
    /// Default value: "["interpolate",["linear"],["zoom"],11,0,13,1]". Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func vignette(_ expression: Exp) -> Self {
        with(self, setter(\.vignette, .expression(expression)))
    }

    /// Rain vignette screen-space corners tint color.
    /// Default value: "["interpolate",["linear"],["measure-light","brightness"],0,"#001736",0.3,"#464646"]".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func vignetteColor(_ constant: StyleColor) -> Self {
        with(self, setter(\.vignetteColor, .constant(constant)))
    }

    /// Rain vignette screen-space corners tint color.
    /// Default value: "["interpolate",["linear"],["measure-light","brightness"],0,"#001736",0.3,"#464646"]".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func vignetteColor(_ color: UIColor) -> Self {
        with(self, setter(\.vignetteColor, .constant(StyleColor(color))))
    }

    /// Transition property for `vignetteColor`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func vignetteColorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.vignetteColorTransition, transition))
    }

    /// Rain vignette screen-space corners tint color.
    /// Default value: "["interpolate",["linear"],["measure-light","brightness"],0,"#001736",0.3,"#464646"]".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func vignetteColor(_ expression: Exp) -> Self {
        with(self, setter(\.vignetteColor, .expression(expression)))
    }

    /// This property defines whether the `vignetteColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func vignetteColorUseTheme(_ useTheme: ColorUseTheme) -> Self {
        with(self, setter(\.vignetteColorUseTheme, .constant(useTheme)))
    }

    /// This property defines whether the `vignetteColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func vignetteColorUseTheme(_ expression: Exp) -> Self {
        with(self, setter(\.vignetteColorUseTheme, .expression(expression)))
    }

}

extension Rain: MapStyleContent, PrimitiveMapContent {
    func visit(_ node: MapContentNode) {
        node.mount(MountedUniqueProperty(keyPath: \.rain, value: self))
    }
}

// End of generated file.
