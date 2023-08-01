// This file is generated.
import Foundation

/// A light that has a direction and is located at infinite, so its rays are parallel. Simulates the sun light and it can cast shadows
///
/// - SeeAlso: [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-style-spec/#light)
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
@_spi(Experimental) public struct DirectionalLight: Codable, StyleEncodable {

    /// Unique light name
    public let id: String

    /// Type of the light.
    public let type: LightType = .directional

    /// Enable/Disable shadow casting for this light
    public var castShadows: Value<Bool>?

    /// Color of the directional light.
    public var color: Value<StyleColor>?

    /// Transition property for `color`
    public var colorTransition: StyleTransition?

    /// Direction of the light source specified as [a azimuthal angle, p polar angle] where a indicates the azimuthal angle of the light relative to north (in degrees and proceeding clockwise), and p indicates polar angle of the light (from 0 degree, directly above, to 180 degree, directly below).
    public var direction: Value<[Double]>?

    /// Transition property for `direction`
    public var directionTransition: StyleTransition?

    /// A multiplier for the color of the directional light.
    public var intensity: Value<Double>?

    /// Transition property for `intensity`
    public var intensityTransition: StyleTransition?

    /// Determines the shadow strength, affecting the shadow receiver surfaces final color. Values near 0.0 reduce the shadow contribution to the final color. Values near to 1.0 make occluded surfaces receive almost no directional light. Designed to be used mostly for transitioning between values 0 and 1.
    public var shadowIntensity: Value<Double>?

    /// Transition property for `shadowIntensity`
    public var shadowIntensityTransition: StyleTransition?

    public init(id: String = UUID().uuidString) {
        self.id = id
    }

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case castShadows = "cast-shadows"
        case color = "color"
        case colorTransition = "color-transition"
        case direction = "direction"
        case directionTransition = "direction-transition"
        case intensity = "intensity"
        case intensityTransition = "intensity-transition"
        case shadowIntensity = "shadow-intensity"
        case shadowIntensityTransition = "shadow-intensity-transition"
    }
}

// End of generated file.
