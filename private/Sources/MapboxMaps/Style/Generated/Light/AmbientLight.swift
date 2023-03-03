// This file is generated.
import Foundation

/// Represents 3D ambient light.
/// - SeeAlso: [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-style-spec/#light)
@_spi(Experimental) public struct AmbientLight: Light3DProtocol {
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
    
    enum CodingKeys: String, CodingKey {
        case lightType = "type"
        case id = "id"
        case color = "color"
        case colorTransition = "color-transition"
        case intensity = "intensity"
        case intensityTransition = "intensity-transition"
    }
}

// End of generated file.