// This file is generated.
import Foundation

/// The global light source.
///
/// - SeeAlso: [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-style-spec/#light)
public struct Light: Codable {

    /// Whether extruded geometries are lit relative to the map or viewport.
    public var anchor: Anchor?

    /// Color tint for lighting extruded geometries.
    public var color: StyleColor?

    /// Transition property for `color`
    public var colorTransition: StyleTransition?

    /// Intensity of lighting (on a scale from 0 to 1). Higher numbers will present as more extreme contrast.
    public var intensity: Double?

    /// Transition property for `intensity`
    public var intensityTransition: StyleTransition?

    /// Position of the light source relative to lit (extruded) geometries, in [r radial coordinate, a azimuthal angle, p polar angle] where r indicates the distance from the center of the base of an object to its light, a indicates the position of the light relative to 0 degree (0 degree when `light.anchor` is set to `viewport` corresponds to the top of the viewport, or 0 degree when `light.anchor` is set to `map` corresponds to due north, and degrees proceed clockwise), and p indicates the height of the light (from 0 degree, directly above, to 180 degree, directly below).
    public var position: [Double]?

    /// Transition property for `position`
    public var positionTransition: StyleTransition?

    public init() {}

    enum CodingKeys: String, CodingKey {
        case anchor = "anchor"
        case color = "color"
        case colorTransition = "color-transition"
        case intensity = "intensity"
        case intensityTransition = "intensity-transition"
        case position = "position"
        case positionTransition = "position-transition"
    }
}

// End of generated file.
