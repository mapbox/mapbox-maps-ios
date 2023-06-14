// This file is generated.
import Foundation

/// Represents 3D directional light.
/// - SeeAlso: [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-style-spec/#light)
@_spi(Experimental) public struct DirectionalLight: Light3DProtocol {
    /// Type of the light.
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

    enum RootCodingKeys: String, CodingKey {
        case type
        case id
        case properties
    }

    enum PropertyCodingKeys: String, CodingKey {
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

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: RootCodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(lightType, forKey: .type)

        var propertyContainer = container.nestedContainer(keyedBy: PropertyCodingKeys.self, forKey: .properties)
        try propertyContainer.encodeIfPresent(direction, forKey: .direction)
        try propertyContainer.encodeIfPresent(directionTransition, forKey: .directionTransition)
        try propertyContainer.encodeIfPresent(color, forKey: .color)
        try propertyContainer.encodeIfPresent(colorTransition, forKey: .colorTransition)
        try propertyContainer.encodeIfPresent(intensity, forKey: .intensity)
        try propertyContainer.encodeIfPresent(intensityTransition, forKey: .intensityTransition)
        try propertyContainer.encodeIfPresent(castShadows, forKey: .castShadows)
        try propertyContainer.encodeIfPresent(shadowIntensity, forKey: .shadowIntensity)
        try propertyContainer.encodeIfPresent(shadowIntensityTransition, forKey: .shadowIntensityTransition)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootCodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        lightType = try container.decode(Light3DType.self, forKey: .type)

        if let propertyContainer = try? container.nestedContainer(keyedBy: PropertyCodingKeys.self, forKey: .properties) {
            direction = try propertyContainer.decodeIfPresent(Value<[Double]>.self, forKey: .direction)
            directionTransition = try propertyContainer.decodeIfPresent(StyleTransition.self, forKey: .directionTransition)
            color = try propertyContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .color)
            colorTransition = try propertyContainer.decodeIfPresent(StyleTransition.self, forKey: .colorTransition)
            intensity = try propertyContainer.decodeIfPresent(Value<Double>.self, forKey: .intensity)
            intensityTransition = try propertyContainer.decodeIfPresent(StyleTransition.self, forKey: .intensityTransition)
            castShadows = try propertyContainer.decodeIfPresent(Value<Bool>.self, forKey: .castShadows)
            shadowIntensity = try propertyContainer.decodeIfPresent(Value<Double>.self, forKey: .shadowIntensity)
            shadowIntensityTransition = try propertyContainer.decodeIfPresent(StyleTransition.self, forKey: .shadowIntensityTransition)
        }
    }
}

// End of generated file.
