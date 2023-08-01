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
    public let id: String

    /// Type of the light.
    public let type: LightType = .ambient

    /// Color of the ambient light.
    public var color: Value<StyleColor>?

    /// Transition property for `color`
    public var colorTransition: StyleTransition?

    /// A multiplier for the color of the ambient light.
    public var intensity: Value<Double>?

    /// Transition property for `intensity`
    public var intensityTransition: StyleTransition?

    public init(id: String = UUID().uuidString) {
        self.id = id
    }

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case color = "color"
        case colorTransition = "color-transition"
        case intensity = "intensity"
        case intensityTransition = "intensity-transition"
    }
}

// End of generated file.
