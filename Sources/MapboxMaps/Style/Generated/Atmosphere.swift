// This file is generated. Do not edit.

import Foundation
import UIKit

/// A global effect that fades layers and markers based on their distance to the camera. The fog can be used to approximate the effect of atmosphere on distant objects and enhance the depth perception of the map when used with terrain or 3D features. Note: fog is renamed to atmosphere in the Android and iOS SDKs and planned to be changed in GL-JS v.3.0.0.
///
/// - SeeAlso: [Mapbox Style Specification](https://docs.mapbox.com/style-spec/reference/fog/)
public struct Atmosphere: Codable, Equatable, StyleEncodable {

    /// Builds a new instance of Atmosphere with the default values.
    public init() { }

    /// The color of the atmosphere region immediately below the horizon and within the `range` and above the horizon and within `horizon-blend`. Using opacity is recommended only for smoothly transitioning fog on/off as anything less than 100% opacity results in more tiles loaded and drawn.
    /// Default value: "#ffffff".
    public var color: Value<StyleColor>?

    /// Transition options for color
    public var colorTransition: StyleTransition?

    /// This property defines whether to use colorTheme defined color or not.
    /// By default it will use color defined by the root theme in the style.
    /// - Note: Expressions set to this property currently don't work.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var colorUseTheme: Value<ColorUseTheme>?

    /// The color of the atmosphere region above the horizon, `high-color` extends further above the horizon than the `color` property and its spread can be controlled with `horizon-blend`. The opacity can be set to `0` to remove the high atmosphere color contribution.
    /// Default value: "#245cdf".
    public var highColor: Value<StyleColor>?

    /// Transition options for high-color
    public var highColorTransition: StyleTransition?

    /// This property defines whether to use colorTheme defined color or not.
    /// By default it will use color defined by the root theme in the style.
    /// - Note: Expressions set to this property currently don't work.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var highColorUseTheme: Value<ColorUseTheme>?

    /// Horizon blend applies a smooth fade from the color of the atmosphere to the color of space. A value of zero leaves a sharp transition from atmosphere to space. Increasing the value blends the color of atmosphere into increasingly high angles of the sky.
    /// Default value: "["interpolate",["linear"],["zoom"],4,0.2,7,0.1]". Value range: [0, 1]
    public var horizonBlend: Value<Double>?

    /// Transition options for horizon-blend
    public var horizonBlendTransition: StyleTransition?

    /// The start and end distance range in which fog fades from fully transparent to fully opaque. The distance to the point at the center of the map is defined as zero, so that negative range values are closer to the camera, and positive values are farther away.
    /// Default value: [0.5,10]. Value range: [-20, 20]
    public var range: Value<[Double]>?

    /// Transition options for range
    public var rangeTransition: StyleTransition?

    /// The color of the region above the horizon and after the end of the `horizon-blend` contribution. The opacity can be set to `0` to have a transparent background.
    /// Default value: "["interpolate",["linear"],["zoom"],4,"#010b19",7,"#367ab9"]".
    public var spaceColor: Value<StyleColor>?

    /// Transition options for space-color
    public var spaceColorTransition: StyleTransition?

    /// This property defines whether to use colorTheme defined color or not.
    /// By default it will use color defined by the root theme in the style.
    /// - Note: Expressions set to this property currently don't work.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public var spaceColorUseTheme: Value<ColorUseTheme>?

    /// A value controlling the star intensity where `0` will show no stars and `1` will show stars at their maximum intensity.
    /// Default value: "["interpolate",["linear"],["zoom"],5,0.35,6,0]". Value range: [0, 1]
    public var starIntensity: Value<Double>?

    /// Transition options for star-intensity
    public var starIntensityTransition: StyleTransition?

    /// An array of two number values, specifying the vertical range, measured in meters, over which the fog should gradually fade out. When both parameters are set to zero, the fog will be rendered without any vertical constraints.
    /// Default value: [0,0]. Minimum value: 0.
    public var verticalRange: Value<[Double]>?

    /// Transition options for vertical-range
    public var verticalRangeTransition: StyleTransition?

    enum CodingKeys: String, CodingKey {
        case color = "color"
        case colorTransition = "color-transition"
        case colorUseTheme = "color-use-theme"
        case highColor = "high-color"
        case highColorTransition = "high-color-transition"
        case highColorUseTheme = "high-color-use-theme"
        case horizonBlend = "horizon-blend"
        case horizonBlendTransition = "horizon-blend-transition"
        case range = "range"
        case rangeTransition = "range-transition"
        case spaceColor = "space-color"
        case spaceColorTransition = "space-color-transition"
        case spaceColorUseTheme = "space-color-use-theme"
        case starIntensity = "star-intensity"
        case starIntensityTransition = "star-intensity-transition"
        case verticalRange = "vertical-range"
        case verticalRangeTransition = "vertical-range-transition"
    }
}

extension Atmosphere {
    /// The color of the atmosphere region immediately below the horizon and within the `range` and above the horizon and within `horizon-blend`. Using opacity is recommended only for smoothly transitioning fog on/off as anything less than 100% opacity results in more tiles loaded and drawn.
    /// Default value: "#ffffff".
    public func color(_ constant: StyleColor) -> Self {
        with(self, setter(\.color, .constant(constant)))
    }

    /// The color of the atmosphere region immediately below the horizon and within the `range` and above the horizon and within `horizon-blend`. Using opacity is recommended only for smoothly transitioning fog on/off as anything less than 100% opacity results in more tiles loaded and drawn.
    /// Default value: "#ffffff".
    public func color(_ color: UIColor) -> Self {
        with(self, setter(\.color, .constant(StyleColor(color))))
    }

    /// Transition property for `color`
    public func colorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.colorTransition, transition))
    }

    /// The color of the atmosphere region immediately below the horizon and within the `range` and above the horizon and within `horizon-blend`. Using opacity is recommended only for smoothly transitioning fog on/off as anything less than 100% opacity results in more tiles loaded and drawn.
    /// Default value: "#ffffff".
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

    /// The color of the atmosphere region above the horizon, `high-color` extends further above the horizon than the `color` property and its spread can be controlled with `horizon-blend`. The opacity can be set to `0` to remove the high atmosphere color contribution.
    /// Default value: "#245cdf".
    public func highColor(_ constant: StyleColor) -> Self {
        with(self, setter(\.highColor, .constant(constant)))
    }

    /// The color of the atmosphere region above the horizon, `high-color` extends further above the horizon than the `color` property and its spread can be controlled with `horizon-blend`. The opacity can be set to `0` to remove the high atmosphere color contribution.
    /// Default value: "#245cdf".
    public func highColor(_ color: UIColor) -> Self {
        with(self, setter(\.highColor, .constant(StyleColor(color))))
    }

    /// Transition property for `highColor`
    public func highColorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.highColorTransition, transition))
    }

    /// The color of the atmosphere region above the horizon, `high-color` extends further above the horizon than the `color` property and its spread can be controlled with `horizon-blend`. The opacity can be set to `0` to remove the high atmosphere color contribution.
    /// Default value: "#245cdf".
    public func highColor(_ expression: Exp) -> Self {
        with(self, setter(\.highColor, .expression(expression)))
    }

    /// This property defines whether the `highColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func highColorUseTheme(_ useTheme: ColorUseTheme) -> Self {
        with(self, setter(\.highColorUseTheme, .constant(useTheme)))
    }

    /// This property defines whether the `highColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func highColorUseTheme(_ expression: Exp) -> Self {
        with(self, setter(\.highColorUseTheme, .expression(expression)))
    }

    /// Horizon blend applies a smooth fade from the color of the atmosphere to the color of space. A value of zero leaves a sharp transition from atmosphere to space. Increasing the value blends the color of atmosphere into increasingly high angles of the sky.
    /// Default value: "["interpolate",["linear"],["zoom"],4,0.2,7,0.1]". Value range: [0, 1]
    public func horizonBlend(_ constant: Double) -> Self {
        with(self, setter(\.horizonBlend, .constant(constant)))
    }

    /// Transition property for `horizonBlend`
    public func horizonBlendTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.horizonBlendTransition, transition))
    }

    /// Horizon blend applies a smooth fade from the color of the atmosphere to the color of space. A value of zero leaves a sharp transition from atmosphere to space. Increasing the value blends the color of atmosphere into increasingly high angles of the sky.
    /// Default value: "["interpolate",["linear"],["zoom"],4,0.2,7,0.1]". Value range: [0, 1]
    public func horizonBlend(_ expression: Exp) -> Self {
        with(self, setter(\.horizonBlend, .expression(expression)))
    }

    /// The start and end distance range in which fog fades from fully transparent to fully opaque. The distance to the point at the center of the map is defined as zero, so that negative range values are closer to the camera, and positive values are farther away.
    /// Default value: [0.5,10]. Value range: [-20, 20]
    public func range(start: Double, end: Double) -> Self {
        with(self, setter(\.range, .constant([start, end])))
    }

    /// Transition property for `range`
    public func rangeTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.rangeTransition, transition))
    }

    /// The start and end distance range in which fog fades from fully transparent to fully opaque. The distance to the point at the center of the map is defined as zero, so that negative range values are closer to the camera, and positive values are farther away.
    /// Default value: [0.5,10]. Value range: [-20, 20]
    public func range(_ expression: Exp) -> Self {
        with(self, setter(\.range, .expression(expression)))
    }

    /// The color of the region above the horizon and after the end of the `horizon-blend` contribution. The opacity can be set to `0` to have a transparent background.
    /// Default value: "["interpolate",["linear"],["zoom"],4,"#010b19",7,"#367ab9"]".
    public func spaceColor(_ constant: StyleColor) -> Self {
        with(self, setter(\.spaceColor, .constant(constant)))
    }

    /// The color of the region above the horizon and after the end of the `horizon-blend` contribution. The opacity can be set to `0` to have a transparent background.
    /// Default value: "["interpolate",["linear"],["zoom"],4,"#010b19",7,"#367ab9"]".
    public func spaceColor(_ color: UIColor) -> Self {
        with(self, setter(\.spaceColor, .constant(StyleColor(color))))
    }

    /// Transition property for `spaceColor`
    public func spaceColorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.spaceColorTransition, transition))
    }

    /// The color of the region above the horizon and after the end of the `horizon-blend` contribution. The opacity can be set to `0` to have a transparent background.
    /// Default value: "["interpolate",["linear"],["zoom"],4,"#010b19",7,"#367ab9"]".
    public func spaceColor(_ expression: Exp) -> Self {
        with(self, setter(\.spaceColor, .expression(expression)))
    }

    /// This property defines whether the `spaceColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func spaceColorUseTheme(_ useTheme: ColorUseTheme) -> Self {
        with(self, setter(\.spaceColorUseTheme, .constant(useTheme)))
    }

    /// This property defines whether the `spaceColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func spaceColorUseTheme(_ expression: Exp) -> Self {
        with(self, setter(\.spaceColorUseTheme, .expression(expression)))
    }

    /// A value controlling the star intensity where `0` will show no stars and `1` will show stars at their maximum intensity.
    /// Default value: "["interpolate",["linear"],["zoom"],5,0.35,6,0]". Value range: [0, 1]
    public func starIntensity(_ constant: Double) -> Self {
        with(self, setter(\.starIntensity, .constant(constant)))
    }

    /// Transition property for `starIntensity`
    public func starIntensityTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.starIntensityTransition, transition))
    }

    /// A value controlling the star intensity where `0` will show no stars and `1` will show stars at their maximum intensity.
    /// Default value: "["interpolate",["linear"],["zoom"],5,0.35,6,0]". Value range: [0, 1]
    public func starIntensity(_ expression: Exp) -> Self {
        with(self, setter(\.starIntensity, .expression(expression)))
    }

    /// An array of two number values, specifying the vertical range, measured in meters, over which the fog should gradually fade out. When both parameters are set to zero, the fog will be rendered without any vertical constraints.
    /// Default value: [0,0]. Minimum value: 0.
    public func verticalRange(start: Double, end: Double) -> Self {
        with(self, setter(\.verticalRange, .constant([start, end])))
    }

    /// Transition property for `verticalRange`
    public func verticalRangeTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.verticalRangeTransition, transition))
    }

    /// An array of two number values, specifying the vertical range, measured in meters, over which the fog should gradually fade out. When both parameters are set to zero, the fog will be rendered without any vertical constraints.
    /// Default value: [0,0]. Minimum value: 0.
    public func verticalRange(_ expression: Exp) -> Self {
        with(self, setter(\.verticalRange, .expression(expression)))
    }

}

extension Atmosphere: MapStyleContent, PrimitiveMapContent {
    func visit(_ node: MapContentNode) {
        node.mount(MountedUniqueProperty(keyPath: \.atmosphere, value: self))
    }
}

// End of generated file.
