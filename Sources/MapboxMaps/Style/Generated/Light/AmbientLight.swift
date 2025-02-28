// This file is generated.
import UIKit

/// An indirect light affecting all objects in the map adding a constant amount of light on them. It has no explicit direction and cannot cast shadows.
///
/// - SeeAlso: [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-style-spec/#light)
public struct AmbientLight: Codable, StyleEncodable, Equatable {

    /// Unique light name
    public let id: String

    /// Type of the light.
    public let type: LightType = .ambient

    /// Color of the ambient light.
    /// Default value: "#ffffff".
    public var color: Value<StyleColor>?

    /// Transition property for `color`
    public var colorTransition: StyleTransition?

    /// A multiplier for the color of the ambient light.
    /// Default value: 0.5. Value range: [0, 1]
    public var intensity: Value<Double>?

    /// Transition property for `intensity`
    public var intensityTransition: StyleTransition?

    /// Creates a new Ambient light.
    public init(id: String = UUID().uuidString) {
        self.id = id
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: RootCodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)

        var propertiesContainer = container.nestedContainer(keyedBy: PropertiesCodingKeys.self, forKey: .properties)
        try propertiesContainer.encodeIfPresent(color, forKey: .color)
        try propertiesContainer.encodeIfPresent(colorTransition, forKey: .colorTransition)
        try propertiesContainer.encodeIfPresent(intensity, forKey: .intensity)
        try propertiesContainer.encodeIfPresent(intensityTransition, forKey: .intensityTransition)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootCodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)

        if let propertiesContainer = try? container.nestedContainer(keyedBy: PropertiesCodingKeys.self, forKey: .properties) {
            self.color = try propertiesContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .color)
            self.colorTransition = try propertiesContainer.decodeIfPresent(StyleTransition.self, forKey: .colorTransition)
            self.intensity = try propertiesContainer.decodeIfPresent(Value<Double>.self, forKey: .intensity)
            self.intensityTransition = try propertiesContainer.decodeIfPresent(StyleTransition.self, forKey: .intensityTransition)
        }
    }

    enum RootCodingKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case properties = "properties"
    }

    enum PropertiesCodingKeys: String, CodingKey {
        case color = "color"
        case colorTransition = "color-transition"
         case intensity = "intensity"
        case intensityTransition = "intensity-transition"
     }
}

extension AmbientLight {
    /// Color of the ambient light.
    /// Default value: "#ffffff".
    public func color(_ constant: StyleColor) -> Self {
        with(self, setter(\.color, .constant(constant)))
    }

    /// Color of the ambient light.
    /// Default value: "#ffffff".
    public func color(_ color: UIColor) -> Self {
        with(self, setter(\.color, .constant(StyleColor(color))))
    }

    /// Transition property for `color`
    public func colorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.colorTransition, transition))
    }

    /// Color of the ambient light.
    /// Default value: "#ffffff".
    public func color(_ expression: Exp) -> Self {
        with(self, setter(\.color, .expression(expression)))
    }

    /// A multiplier for the color of the ambient light.
    /// Default value: 0.5. Value range: [0, 1]
    public func intensity(_ constant: Double) -> Self {
        with(self, setter(\.intensity, .constant(constant)))
    }

    /// Transition property for `intensity`
    public func intensityTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.intensityTransition, transition))
    }

    /// A multiplier for the color of the ambient light.
    /// Default value: 0.5. Value range: [0, 1]
    public func intensity(_ expression: Exp) -> Self {
        with(self, setter(\.intensity, .expression(expression)))
    }
}

extension AmbientLight: MapStyleContent, PrimitiveMapContent {
    func visit(_ node: MapContentNode) {
        node.mount(MountedUniqueProperty(keyPath: \.lights.ambient, value: self))
    }
}
// End of generated file.
