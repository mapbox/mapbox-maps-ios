// This file is generated.
import Foundation

/// A global directional light source which is only applied on 3D layers and hillshade layers. Using this type disables other light sources.
///
/// - SeeAlso: [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-style-spec/#light)
public struct FlatLight: Codable, StyleEncodable {

    /// Unique light name
    public let id: String

    /// Type of the light.
    public let type: LightType = .flat

    /// Whether extruded geometries are lit relative to the map or viewport.
    public var anchor: Value<Anchor>?

    /// Color tint for lighting extruded geometries.
    public var color: Value<StyleColor>?

    /// Transition property for `color`
    public var colorTransition: StyleTransition?

    /// Intensity of lighting (on a scale from 0 to 1). Higher numbers will present as more extreme contrast.
    public var intensity: Value<Double>?

    /// Transition property for `intensity`
    public var intensityTransition: StyleTransition?

    /// Position of the light source relative to lit (extruded) geometries, in [r radial coordinate, a azimuthal angle, p polar angle] where r indicates the distance from the center of the base of an object to its light, a indicates the position of the light relative to 0 degree (0 degree when `light.anchor` is set to `viewport` corresponds to the top of the viewport, or 0 degree when `light.anchor` is set to `map` corresponds to due north, and degrees proceed clockwise), and p indicates the height of the light (from 0 degree, directly above, to 180 degree, directly below).
    public var position: Value<[Double]>?

    /// Transition property for `position`
    public var positionTransition: StyleTransition?

    /// Creates a new Flat light.
    public init(id: String = UUID().uuidString) {
        self.id = id
    }

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case type = "type"
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
