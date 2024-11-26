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
    /// Default value: 1. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var centerThinning: Value<Double>?

    /// Transition options for centerThinning
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var centerThinningTransition: StyleTransition?

    /// Snow particles color.
    /// Default value: "#ffffff".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var color: Value<StyleColor>?

    /// Transition options for color
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var colorTransition: StyleTransition?

    /// Snow particles density.
    /// Default value: 1. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var density: Value<Double>?

    /// Transition options for density
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var densityTransition: StyleTransition?

    /// Main snow particles direction. Heading & pitch
    /// Default value: [0,90]. Value range: [0, 360]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var direction: Value<[Double]>?

    /// Transition options for direction
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var directionTransition: StyleTransition?

    /// Snow particles movement factor.
    /// Default value: 1. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var intensity: Value<Double>?

    /// Transition options for intensity
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var intensityTransition: StyleTransition?

    /// Snow particles opacity.
    /// Default value: 1. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var opacity: Value<Double>?

    /// Transition options for opacity
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var opacityTransition: StyleTransition?

    /// Snow vignette screen-space effect.
    /// Default value: 0. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var vignette: Value<Double>?

    /// Transition options for vignette
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var vignetteTransition: StyleTransition?

    public enum CodingKeys: String, CodingKey {
        case centerThinning = "centerThinning"
        case centerThinningTransition = "centerThinning-transition"
        case color = "color"
        case colorTransition = "color-transition"
        case density = "density"
        case densityTransition = "density-transition"
        case direction = "direction"
        case directionTransition = "direction-transition"
        case intensity = "intensity"
        case intensityTransition = "intensity-transition"
        case opacity = "opacity"
        case opacityTransition = "opacity-transition"
        case vignette = "vignette"
        case vignetteTransition = "vignette-transition"
    }
}

extension Snow {
    /// Thinning factor of snow particles from center. 0 - no thinning. 1 - maximal central area thinning.
    /// Default value: 1. Value range: [0, 1]
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
    /// Default value: 1. Value range: [0, 1]
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

    /// Snow particles density.
    /// Default value: 1. Value range: [0, 1]
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

    /// Snow particles density.
    /// Default value: 1. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func density(_ expression: Exp) -> Self {
        with(self, setter(\.density, .expression(expression)))
    }

    /// Main snow particles direction. Heading & pitch
    /// Default value: [0,90]. Value range: [0, 360]
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

    /// Main snow particles direction. Heading & pitch
    /// Default value: [0,90]. Value range: [0, 360]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func direction(_ expression: Exp) -> Self {
        with(self, setter(\.direction, .expression(expression)))
    }

    /// Snow particles movement factor.
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

    /// Snow particles movement factor.
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

    /// Snow vignette screen-space effect.
    /// Default value: 0. Value range: [0, 1]
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

    /// Snow vignette screen-space effect.
    /// Default value: 0. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func vignette(_ expression: Exp) -> Self {
        with(self, setter(\.vignette, .expression(expression)))
    }

}

@available(iOS 13.0, *)
extension Snow: MapStyleContent, PrimitiveMapContent {
    func visit(_ node: MapContentNode) {
        node.mount(MountedUniqueProperty(keyPath: \.snow, value: self))
    }
}

// End of generated file.
