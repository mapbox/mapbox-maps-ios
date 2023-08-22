// This file is generated.
import Foundation

/// An indirect light affecting all objects in the map adding a constant amount of light on them. It has no explicit direction and cannot cast shadows.
///
/// - SeeAlso: [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-style-spec/#light)
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
@_spi(Experimental) public struct AmbientLight: Codable, StyleEncodable {

    /// Unique light name
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public let id: String

    /// Type of the light.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public let type: LightType = .ambient

    /// Color of the ambient light.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public var color: Value<StyleColor>?

    /// Transition property for `color`
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public var colorTransition: StyleTransition?

    /// A multiplier for the color of the ambient light.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public var intensity: Value<Double>?

    /// Transition property for `intensity`
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public var intensityTransition: StyleTransition?

    /// Creates a new Ambient light.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
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

// End of generated file.
