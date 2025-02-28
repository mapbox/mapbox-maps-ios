// This file is generated.
import UIKit

/// A light that has a direction and is located at infinite distance, so its rays are parallel. It simulates the sun light and can cast shadows.
///
/// - SeeAlso: [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-style-spec/#light)
public struct DirectionalLight: Codable, StyleEncodable, Equatable {

    /// Unique light name
    public let id: String

    /// Type of the light.
    public let type: LightType = .directional

    /// Enable/Disable shadow casting for this light
    /// Default value: false.
    public var castShadows: Value<Bool>?

    /// Color of the directional light.
    /// Default value: "#ffffff".
    public var color: Value<StyleColor>?

    /// Transition property for `color`
    public var colorTransition: StyleTransition?

    /// Direction of the light source specified as [a azimuthal angle, p polar angle] where a indicates the azimuthal angle of the light relative to north (in degrees and proceeding clockwise), and p indicates polar angle of the light (from 0 degree, directly above, to 180 degree, directly below).
    /// Default value: [210,30]. Minimum value: [0,0]. Maximum value: [360,90].
    public var direction: Value<[Double]>?

    /// Transition property for `direction`
    public var directionTransition: StyleTransition?

    /// A multiplier for the color of the directional light.
    /// Default value: 0.5. Value range: [0, 1]
    public var intensity: Value<Double>?

    /// Transition property for `intensity`
    public var intensityTransition: StyleTransition?

    /// Determines the shadow strength, affecting the shadow receiver surfaces final color. Values near 0.0 reduce the shadow contribution to the final color. Values near to 1.0 make occluded surfaces receive almost no directional light. Designed to be used mostly for transitioning between values 0 and 1.
    /// Default value: 1. Value range: [0, 1]
    public var shadowIntensity: Value<Double>?

    /// Transition property for `shadowIntensity`
    public var shadowIntensityTransition: StyleTransition?

    /// Creates a new Directional light.
    public init(id: String = UUID().uuidString) {
        self.id = id
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: RootCodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)

        var propertiesContainer = container.nestedContainer(keyedBy: PropertiesCodingKeys.self, forKey: .properties)
        try propertiesContainer.encodeIfPresent(castShadows, forKey: .castShadows)
        try propertiesContainer.encodeIfPresent(color, forKey: .color)
        try propertiesContainer.encodeIfPresent(colorTransition, forKey: .colorTransition)
        try propertiesContainer.encodeIfPresent(direction, forKey: .direction)
        try propertiesContainer.encodeIfPresent(directionTransition, forKey: .directionTransition)
        try propertiesContainer.encodeIfPresent(intensity, forKey: .intensity)
        try propertiesContainer.encodeIfPresent(intensityTransition, forKey: .intensityTransition)
        try propertiesContainer.encodeIfPresent(shadowIntensity, forKey: .shadowIntensity)
        try propertiesContainer.encodeIfPresent(shadowIntensityTransition, forKey: .shadowIntensityTransition)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootCodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)

        if let propertiesContainer = try? container.nestedContainer(keyedBy: PropertiesCodingKeys.self, forKey: .properties) {
            self.castShadows = try propertiesContainer.decodeIfPresent(Value<Bool>.self, forKey: .castShadows)
            self.color = try propertiesContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .color)
            self.colorTransition = try propertiesContainer.decodeIfPresent(StyleTransition.self, forKey: .colorTransition)
            self.direction = try propertiesContainer.decodeIfPresent(Value<[Double]>.self, forKey: .direction)
            self.directionTransition = try propertiesContainer.decodeIfPresent(StyleTransition.self, forKey: .directionTransition)
            self.intensity = try propertiesContainer.decodeIfPresent(Value<Double>.self, forKey: .intensity)
            self.intensityTransition = try propertiesContainer.decodeIfPresent(StyleTransition.self, forKey: .intensityTransition)
            self.shadowIntensity = try propertiesContainer.decodeIfPresent(Value<Double>.self, forKey: .shadowIntensity)
            self.shadowIntensityTransition = try propertiesContainer.decodeIfPresent(StyleTransition.self, forKey: .shadowIntensityTransition)
        }
    }

    enum RootCodingKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case properties = "properties"
    }

    enum PropertiesCodingKeys: String, CodingKey {
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

extension DirectionalLight {
    /// Enable/Disable shadow casting for this light
    /// Default value: false.
    public func castShadows(_ constant: Bool) -> Self {
        with(self, setter(\.castShadows, .constant(constant)))
    }

    /// Enable/Disable shadow casting for this light
    /// Default value: false.
    public func castShadows(_ expression: Exp) -> Self {
        with(self, setter(\.castShadows, .expression(expression)))
    }

    /// Color of the directional light.
    /// Default value: "#ffffff".
    public func color(_ constant: StyleColor) -> Self {
        with(self, setter(\.color, .constant(constant)))
    }

    /// Color of the directional light.
    /// Default value: "#ffffff".
    public func color(_ color: UIColor) -> Self {
        with(self, setter(\.color, .constant(StyleColor(color))))
    }

    /// Transition property for `color`
    public func colorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.colorTransition, transition))
    }

    /// Color of the directional light.
    /// Default value: "#ffffff".
    public func color(_ expression: Exp) -> Self {
        with(self, setter(\.color, .expression(expression)))
    }

    /// Direction of the light source specified as [a azimuthal angle, p polar angle] where a indicates the azimuthal angle of the light relative to north (in degrees and proceeding clockwise), and p indicates polar angle of the light (from 0 degree, directly above, to 180 degree, directly below).
    /// Default value: [210,30]. Minimum value: [0,0]. Maximum value: [360,90].
    public func direction(azimuthal: Double, polar: Double) -> Self {
        with(self, setter(\.direction, .constant([azimuthal, polar])))
    }

    /// Transition property for `direction`
    public func directionTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.directionTransition, transition))
    }

    /// Direction of the light source specified as [a azimuthal angle, p polar angle] where a indicates the azimuthal angle of the light relative to north (in degrees and proceeding clockwise), and p indicates polar angle of the light (from 0 degree, directly above, to 180 degree, directly below).
    /// Default value: [210,30]. Minimum value: [0,0]. Maximum value: [360,90].
    public func direction(_ expression: Exp) -> Self {
        with(self, setter(\.direction, .expression(expression)))
    }

    /// A multiplier for the color of the directional light.
    /// Default value: 0.5. Value range: [0, 1]
    public func intensity(_ constant: Double) -> Self {
        with(self, setter(\.intensity, .constant(constant)))
    }

    /// Transition property for `intensity`
    public func intensityTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.intensityTransition, transition))
    }

    /// A multiplier for the color of the directional light.
    /// Default value: 0.5. Value range: [0, 1]
    public func intensity(_ expression: Exp) -> Self {
        with(self, setter(\.intensity, .expression(expression)))
    }

    /// Determines the shadow strength, affecting the shadow receiver surfaces final color. Values near 0.0 reduce the shadow contribution to the final color. Values near to 1.0 make occluded surfaces receive almost no directional light. Designed to be used mostly for transitioning between values 0 and 1.
    /// Default value: 1. Value range: [0, 1]
    public func shadowIntensity(_ constant: Double) -> Self {
        with(self, setter(\.shadowIntensity, .constant(constant)))
    }

    /// Transition property for `shadowIntensity`
    public func shadowIntensityTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.shadowIntensityTransition, transition))
    }

    /// Determines the shadow strength, affecting the shadow receiver surfaces final color. Values near 0.0 reduce the shadow contribution to the final color. Values near to 1.0 make occluded surfaces receive almost no directional light. Designed to be used mostly for transitioning between values 0 and 1.
    /// Default value: 1. Value range: [0, 1]
    public func shadowIntensity(_ expression: Exp) -> Self {
        with(self, setter(\.shadowIntensity, .expression(expression)))
    }
}

extension DirectionalLight: MapStyleContent, PrimitiveMapContent {
    func visit(_ node: MapContentNode) {
        node.mount(MountedUniqueProperty(keyPath: \.lights.directional, value: self))
    }
}
// End of generated file.
