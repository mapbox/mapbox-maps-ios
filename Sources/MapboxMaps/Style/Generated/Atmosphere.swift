// This file is generated.
import Foundation


/// A style's fog property is a global effect that improves depth perception by fading out distant objects.
///
/// - SeeAlso: [Mapbox Style Specification](https://docs.mapbox.com/mapbox-gl-js/style-spec/fog/)
public struct Atmosphere: Codable  {

    /// The color of the atmosphere region immediately below the horizon and within the `range` and above the horizon and within `horizon-blend`. Using opacity is recommended only for smoothly transitioning fog on/off as anything less than 100% opacity results in more tiles loaded and drawn.
    public var color: Value<StyleColor>?

    /// Transition property for `color`
    public var colorTransition: StyleTransition?

    /// The color of the atmosphere region above the horizon, `high-color` extends further above the horizon than the `color` property and its spread can be controlled with `horizon-blend`. The opacity can be set to `0` to remove the high atmosphere color contribution.
    public var highColor: Value<StyleColor>?

    /// Transition property for `highColor`
    public var highColorTransition: StyleTransition?

    /// Horizon blend applies a smooth fade from the color of the atmosphere to the color of space. A value of zero leaves a sharp transition from atmosphere to space. Increasing the value blends the color of atmosphere into increasingly high angles of the sky.
    public var horizonBlend: Value<Double>?

    /// Transition property for `horizonBlend`
    public var horizonBlendTransition: StyleTransition?

    /// The start and end distance range in which fog fades from fully transparent to fully opaque. The distance to the point at the center of the map is defined as zero, so that negative range values are closer to the camera, and positive values are farther away.
    public var range: Value<[Double]>?

    /// Transition property for `range`
    public var rangeTransition: StyleTransition?

    /// The color of the region above the horizon and after the end of the `horizon-blend` contribution. The opacity can be set to `0` to have a transparent background.
    public var spaceColor: Value<StyleColor>?

    /// Transition property for `spaceColor`
    public var spaceColorTransition: StyleTransition?

    /// A value controlling the star intensity where `0` will show no stars and `1` will show stars at their maximum intensity.
    public var starIntensity: Value<Double>?

    /// Transition property for `starIntensity`
    public var starIntensityTransition: StyleTransition?

    public init() {}

    enum CodingKeys: String, CodingKey {
        case color = "color"
        case colorTransition = "color-transition"
        case highColor = "high-color"
        case highColorTransition = "high-color-transition"
        case horizonBlend = "horizon-blend"
        case horizonBlendTransition = "horizon-blend-transition"
        case range = "range"
        case rangeTransition = "range-transition"
        case spaceColor = "space-color"
        case spaceColorTransition = "space-color-transition"
        case starIntensity = "star-intensity"
        case starIntensityTransition = "star-intensity-transition"
    }
}

// End of generated file.
