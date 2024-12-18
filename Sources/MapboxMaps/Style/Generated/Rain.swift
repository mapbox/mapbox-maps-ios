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
    /// Default value: 1. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var centerThinning: Value<Double>?

    /// Transition options for center-thinning
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var centerThinningTransition: StyleTransition?

    ///
    /// Default value: "#ffffff".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var color: Value<StyleColor>?

    /// Transition options for color
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var colorTransition: StyleTransition?

    /// Rain particles density.
    /// Default value: 1. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var density: Value<Double>?

    /// Transition options for density
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var densityTransition: StyleTransition?

    /// Main rain particles direction. Heading & pitch
    /// Default value: [0,80]. Value range: [0, 360]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var direction: Value<[Double]>?

    /// Transition options for direction
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var directionTransition: StyleTransition?

    /// Rain particles movement factor.
    /// Default value: 1. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var intensity: Value<Double>?

    /// Transition options for intensity
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var intensityTransition: StyleTransition?

    /// Rain particles opacity.
    /// Default value: 1. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var opacity: Value<Double>?

    /// Transition options for opacity
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var opacityTransition: StyleTransition?

    /// Rain vignette screen-space effect.
    /// Default value: 0. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var vignette: Value<Double>?

    /// Transition options for vignette
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var vignetteTransition: StyleTransition?

    public enum CodingKeys: String, CodingKey {
        case centerThinning = "center-thinning"
        case centerThinningTransition = "center-thinning-transition"
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

extension Rain {
    /// Thinning factor of rain particles from center. 0 - no thinning. 1 - maximal central area thinning.
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

    /// Thinning factor of rain particles from center. 0 - no thinning. 1 - maximal central area thinning.
    /// Default value: 1. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func centerThinning(_ expression: Exp) -> Self {
        with(self, setter(\.centerThinning, .expression(expression)))
    }

    ///
    /// Default value: "#ffffff".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func color(_ constant: StyleColor) -> Self {
        with(self, setter(\.color, .constant(constant)))
    }

    ///
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

    ///
    /// Default value: "#ffffff".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func color(_ expression: Exp) -> Self {
        with(self, setter(\.color, .expression(expression)))
    }

    /// Rain particles density.
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

    /// Rain particles density.
    /// Default value: 1. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func density(_ expression: Exp) -> Self {
        with(self, setter(\.density, .expression(expression)))
    }

    /// Main rain particles direction. Heading & pitch
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

    /// Main rain particles direction. Heading & pitch
    /// Default value: [0,80]. Value range: [0, 360]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func direction(_ expression: Exp) -> Self {
        with(self, setter(\.direction, .expression(expression)))
    }

    /// Rain particles movement factor.
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

    /// Rain particles movement factor.
    /// Default value: 1. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func intensity(_ expression: Exp) -> Self {
        with(self, setter(\.intensity, .expression(expression)))
    }

    /// Rain particles opacity.
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

    /// Rain particles opacity.
    /// Default value: 1. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func opacity(_ expression: Exp) -> Self {
        with(self, setter(\.opacity, .expression(expression)))
    }

    /// Rain vignette screen-space effect.
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

    /// Rain vignette screen-space effect.
    /// Default value: 0. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func vignette(_ expression: Exp) -> Self {
        with(self, setter(\.vignette, .expression(expression)))
    }

}

@available(iOS 13.0, *)
extension Rain: MapStyleContent, PrimitiveMapContent {
    func visit(_ node: MapContentNode) {
        node.mount(MountedUniqueProperty(keyPath: \.rain, value: self))
    }
}

// End of generated file.
