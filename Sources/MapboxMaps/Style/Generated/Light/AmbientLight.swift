// This file is generated.
import Foundation

/// Represents 3D ambient light.
/// - SeeAlso: [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-style-spec/#light)
@_spi(Experimental) public struct AmbientLight: Light3DProtocol {
    /// Type of the light.
    public let lightType: Light3DType

    /// The unique ID for this light. This must be set when configuring the lights.
    public let id: String

    /// Color of the ambient light.
    public var color: Value<StyleColor>?

    /// Transition property for `color`
    public var colorTransition: StyleTransition?

    /// A multiplier for the color of the ambient light.
    public var intensity: Value<Double>?

    /// Transition property for `intensity`
    public var intensityTransition: StyleTransition?

    public init(id: String) {
        self.id = id
        self.lightType = .ambient
    }

    enum RootCodingKeys: String, CodingKey {
        case type
        case id
        case properties
    }

    enum PropertyCodingKeys: String, CodingKey {
        case color = "color"
        case colorTransition = "color-transition"
        case intensity = "intensity"
        case intensityTransition = "intensity-transition"
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: RootCodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(lightType, forKey: .type)

        var propertyContainer = container.nestedContainer(keyedBy: PropertyCodingKeys.self, forKey: .properties)
        try propertyContainer.encodeIfPresent(color, forKey: .color)
        try propertyContainer.encodeIfPresent(colorTransition, forKey: .colorTransition)
        try propertyContainer.encodeIfPresent(intensity, forKey: .intensity)
        try propertyContainer.encodeIfPresent(intensityTransition, forKey: .intensityTransition)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootCodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        lightType = try container.decode(Light3DType.self, forKey: .type)

        if let propertyContainer = try? container.nestedContainer(keyedBy: PropertyCodingKeys.self, forKey: .properties) {
            color = try propertyContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .color)
            colorTransition = try propertyContainer.decodeIfPresent(StyleTransition.self, forKey: .colorTransition)
            intensity = try propertyContainer.decodeIfPresent(Value<Double>.self, forKey: .intensity)
            intensityTransition = try propertyContainer.decodeIfPresent(StyleTransition.self, forKey: .intensityTransition)
        }
    }
}

// End of generated file.
