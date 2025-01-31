// This file is generated. Do not edit.

import Foundation
import UIKit

/// Snow particles over the map
///
/// - SeeAlso: [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-style-spec/#snow)
@_documentation(visibility: public)
@_spi(Experimental)
public struct Snow: Codable, Equatable, StyleEncodable {

    /// Builds a new instance of Snow with the default values.
    public init() { }

    /// Thinning factor of snow particles from center. 0 - no thinning. 1 - maximal central area thinning.
    /// Default value: 0.4. Value range: [0, 1]
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

    /// Snow particles color.
    /// Default value: "#ffffff".
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

    /// Snow particles density. Controls the overall particles number.
    /// Default value: "["interpolate",["linear"],["zoom"],11,0,13,0.85]". Value range: [0, 1]
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

    /// Main snow particles direction. Azimuth and polar angles
    /// Default value: [0,50]. Value range: [0, 360]
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

    /// Snow flake particle size. Correlates with individual particle screen size
    /// Default value: 0.71. Value range: [0, 5]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var flakeSize: Value<Double>?

    /// Transition options for flake-size
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var flakeSizeTransition: StyleTransition?
    /// Use theme flag for flake-size
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var flakeSizeUseTheme: Value<ColorUseTheme>?

    /// Snow particles movement factor. Controls the overall particles movement speed.
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

    /// Snow particles opacity.
    /// Default value: 1. Value range: [0, 1]
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

    /// Snow vignette screen-space effect. Adds snow tint to screen corners
    /// Default value: "["interpolate",["linear"],["zoom"],11,0,13,0.3]". Value range: [0, 1]
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

    /// Snow vignette screen-space corners tint color.
    /// Default value: "#ffffff".
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
        case flakeSize = "flake-size"
        case flakeSizeTransition = "flake-size-transition"
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

extension Snow {
    /// Thinning factor of snow particles from center. 0 - no thinning. 1 - maximal central area thinning.
    /// Default value: 0.4. Value range: [0, 1]
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

    /// Thinning factor of snow particles from center. 0 - no thinning. 1 - maximal central area thinning.
    /// Default value: 0.4. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func centerThinning(_ expression: Exp) -> Self {
        with(self, setter(\.centerThinning, .expression(expression)))
    }

    /// Snow particles color.
    /// Default value: "#ffffff".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func color(_ constant: StyleColor) -> Self {
        with(self, setter(\.color, .constant(constant)))
    }

    /// Snow particles color.
    /// Default value: "#ffffff".
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

    /// Snow particles color.
    /// Default value: "#ffffff".
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

    /// Snow particles density. Controls the overall particles number.
    /// Default value: "["interpolate",["linear"],["zoom"],11,0,13,0.85]". Value range: [0, 1]
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

    /// Snow particles density. Controls the overall particles number.
    /// Default value: "["interpolate",["linear"],["zoom"],11,0,13,0.85]". Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func density(_ expression: Exp) -> Self {
        with(self, setter(\.density, .expression(expression)))
    }

    /// Main snow particles direction. Azimuth and polar angles
    /// Default value: [0,50]. Value range: [0, 360]
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

    /// Main snow particles direction. Azimuth and polar angles
    /// Default value: [0,50]. Value range: [0, 360]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func direction(_ expression: Exp) -> Self {
        with(self, setter(\.direction, .expression(expression)))
    }

    /// Snow flake particle size. Correlates with individual particle screen size
    /// Default value: 0.71. Value range: [0, 5]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func flakeSize(_ constant: Double) -> Self {
        with(self, setter(\.flakeSize, .constant(constant)))
    }

    /// Transition property for `flakeSize`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func flakeSizeTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.flakeSizeTransition, transition))
    }

    /// Snow flake particle size. Correlates with individual particle screen size
    /// Default value: 0.71. Value range: [0, 5]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func flakeSize(_ expression: Exp) -> Self {
        with(self, setter(\.flakeSize, .expression(expression)))
    }

    /// Snow particles movement factor. Controls the overall particles movement speed.
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

    /// Snow particles movement factor. Controls the overall particles movement speed.
    /// Default value: 1. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func intensity(_ expression: Exp) -> Self {
        with(self, setter(\.intensity, .expression(expression)))
    }

    /// Snow particles opacity.
    /// Default value: 1. Value range: [0, 1]
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

    /// Snow particles opacity.
    /// Default value: 1. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func opacity(_ expression: Exp) -> Self {
        with(self, setter(\.opacity, .expression(expression)))
    }

    /// Snow vignette screen-space effect. Adds snow tint to screen corners
    /// Default value: "["interpolate",["linear"],["zoom"],11,0,13,0.3]". Value range: [0, 1]
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

    /// Snow vignette screen-space effect. Adds snow tint to screen corners
    /// Default value: "["interpolate",["linear"],["zoom"],11,0,13,0.3]". Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func vignette(_ expression: Exp) -> Self {
        with(self, setter(\.vignette, .expression(expression)))
    }

    /// Snow vignette screen-space corners tint color.
    /// Default value: "#ffffff".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func vignetteColor(_ constant: StyleColor) -> Self {
        with(self, setter(\.vignetteColor, .constant(constant)))
    }

    /// Snow vignette screen-space corners tint color.
    /// Default value: "#ffffff".
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

    /// Snow vignette screen-space corners tint color.
    /// Default value: "#ffffff".
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

extension Snow: MapStyleContent, PrimitiveMapContent {
    func visit(_ node: MapContentNode) {
        node.mount(MountedUniqueProperty(keyPath: \.snow, value: self))
    }
}

// End of generated file.
