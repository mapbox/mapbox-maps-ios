// This file is generated.
import Foundation

/// Represents 3D directional light.
/// - SeeAlso: [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-style-spec/#light)
@_spi(Experimental) public struct DirectionalLight: Light3DProtocol {
    public let lightType: Light3DType

    /// The unique ID for this light. This must be set when configuring the lights.
    public let id: String

    /// Direction of the light source specified as [a azimuthal angle, p polar angle] where a indicates the azimuthal angle of the light relative to north (in degrees and proceeding clockwise), and p indicates polar angle of the light (from 0 degree, directly above, to 180 degree, directly below).
    public var direction: Value<[Double]>?
    
    /// Transition property for `direction`
    public var directionTransition: StyleTransition?

    /// Color of the directional light.
    public var color: Value<StyleColor>?
    
    /// Transition property for `color`
    public var colorTransition: StyleTransition?

    /// A multiplier for the color of the directional light.
    public var intensity: Value<Double>?
    
    /// Transition property for `intensity`
    public var intensityTransition: StyleTransition?

    /// Enable/Disable shadow casting for this light
    public var castShadows: Value<Bool>?

    /// Determines the shadow strength, affecting the shadow receiver surfaces final color. Values near 0.0 reduce the shadow contribution to the final color. Values near to 1.0 make occluded surfaces almost black.
    public var shadowIntensity: Value<Double>?
    
    /// Transition property for `shadowIntensity`
    public var shadowIntensityTransition: StyleTransition?
    
    public init(id: String) {
        self.id = id
        self.lightType = .directional
    }
    
    enum CodingKeys: String, CodingKey {
        case lightType = "type"
        case id = "id"
        case direction = "direction"
        case directionTransition = "direction-transition"
        case color = "color"
        case colorTransition = "color-transition"
        case intensity = "intensity"
        case intensityTransition = "intensity-transition"
        case castShadows = "cast-shadows"
        case shadowIntensity = "shadow-intensity"
        case shadowIntensityTransition = "shadow-intensity-transition"
    }
}

// End of generated file.