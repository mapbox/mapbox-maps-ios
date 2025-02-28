// This file is generated.
import UIKit

/// A global directional light source which is only applied on 3D and hillshade layers. Using this type disables other light sources.
///
/// - SeeAlso: [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-style-spec/#light)
public struct FlatLight: Codable, StyleEncodable, Equatable {

    /// Unique light name
    public let id: String

    /// Type of the light.
    public let type: LightType = .flat

    /// Whether extruded geometries are lit relative to the map or viewport.
    /// Default value: "viewport".
    public var anchor: Value<Anchor>?

    /// Color tint for lighting extruded geometries.
    /// Default value: "#ffffff".
    public var color: Value<StyleColor>?

    /// Transition property for `color`
    public var colorTransition: StyleTransition?

    /// Intensity of lighting (on a scale from 0 to 1). Higher numbers will present as more extreme contrast.
    /// Default value: 0.5. Value range: [0, 1]
    public var intensity: Value<Double>?

    /// Transition property for `intensity`
    public var intensityTransition: StyleTransition?

    /// Position of the light source relative to lit (extruded) geometries, in [r radial coordinate, a azimuthal angle, p polar angle] where r indicates the distance from the center of the base of an object to its light, a indicates the position of the light relative to 0 degree (0 degree when `light.anchor` is set to `viewport` corresponds to the top of the viewport, or 0 degree when `light.anchor` is set to `map` corresponds to due north, and degrees proceed clockwise), and p indicates the height of the light (from 0 degree, directly above, to 180 degree, directly below).
    /// Default value: [1.15,210,30].
    public var position: Value<[Double]>?

    /// Transition property for `position`
    public var positionTransition: StyleTransition?

    /// Creates a new Flat light.
    public init(id: String = UUID().uuidString) {
        self.id = id
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: RootCodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)

        var propertiesContainer = container.nestedContainer(keyedBy: PropertiesCodingKeys.self, forKey: .properties)
        try propertiesContainer.encodeIfPresent(anchor, forKey: .anchor)
        try propertiesContainer.encodeIfPresent(color, forKey: .color)
        try propertiesContainer.encodeIfPresent(colorTransition, forKey: .colorTransition)
        try propertiesContainer.encodeIfPresent(intensity, forKey: .intensity)
        try propertiesContainer.encodeIfPresent(intensityTransition, forKey: .intensityTransition)
        try propertiesContainer.encodeIfPresent(position, forKey: .position)
        try propertiesContainer.encodeIfPresent(positionTransition, forKey: .positionTransition)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootCodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)

        if let propertiesContainer = try? container.nestedContainer(keyedBy: PropertiesCodingKeys.self, forKey: .properties) {
            self.anchor = try propertiesContainer.decodeIfPresent(Value<Anchor>.self, forKey: .anchor)
            self.color = try propertiesContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .color)
            self.colorTransition = try propertiesContainer.decodeIfPresent(StyleTransition.self, forKey: .colorTransition)
            self.intensity = try propertiesContainer.decodeIfPresent(Value<Double>.self, forKey: .intensity)
            self.intensityTransition = try propertiesContainer.decodeIfPresent(StyleTransition.self, forKey: .intensityTransition)
            self.position = try propertiesContainer.decodeIfPresent(Value<[Double]>.self, forKey: .position)
            self.positionTransition = try propertiesContainer.decodeIfPresent(StyleTransition.self, forKey: .positionTransition)
        }
    }

    enum RootCodingKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case properties = "properties"
    }

    enum PropertiesCodingKeys: String, CodingKey {
        case anchor = "anchor"
         case color = "color"
        case colorTransition = "color-transition"
         case intensity = "intensity"
        case intensityTransition = "intensity-transition"
         case position = "position"
        case positionTransition = "position-transition"
     }
}

extension FlatLight {
    /// Whether extruded geometries are lit relative to the map or viewport.
    /// Default value: "viewport".
    public func anchor(_ constant: Anchor) -> Self {
        with(self, setter(\.anchor, .constant(constant)))
    }

    /// Whether extruded geometries are lit relative to the map or viewport.
    /// Default value: "viewport".
    public func anchor(_ expression: Exp) -> Self {
        with(self, setter(\.anchor, .expression(expression)))
    }

    /// Color tint for lighting extruded geometries.
    /// Default value: "#ffffff".
    public func color(_ constant: StyleColor) -> Self {
        with(self, setter(\.color, .constant(constant)))
    }

    /// Color tint for lighting extruded geometries.
    /// Default value: "#ffffff".
    public func color(_ color: UIColor) -> Self {
        with(self, setter(\.color, .constant(StyleColor(color))))
    }

    /// Transition property for `color`
    public func colorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.colorTransition, transition))
    }

    /// Color tint for lighting extruded geometries.
    /// Default value: "#ffffff".
    public func color(_ expression: Exp) -> Self {
        with(self, setter(\.color, .expression(expression)))
    }

    /// Intensity of lighting (on a scale from 0 to 1). Higher numbers will present as more extreme contrast.
    /// Default value: 0.5. Value range: [0, 1]
    public func intensity(_ constant: Double) -> Self {
        with(self, setter(\.intensity, .constant(constant)))
    }

    /// Transition property for `intensity`
    public func intensityTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.intensityTransition, transition))
    }

    /// Intensity of lighting (on a scale from 0 to 1). Higher numbers will present as more extreme contrast.
    /// Default value: 0.5. Value range: [0, 1]
    public func intensity(_ expression: Exp) -> Self {
        with(self, setter(\.intensity, .expression(expression)))
    }

    /// Position of the light source relative to lit (extruded) geometries, in [r radial coordinate, a azimuthal angle, p polar angle] where r indicates the distance from the center of the base of an object to its light, a indicates the position of the light relative to 0 degree (0 degree when `light.anchor` is set to `viewport` corresponds to the top of the viewport, or 0 degree when `light.anchor` is set to `map` corresponds to due north, and degrees proceed clockwise), and p indicates the height of the light (from 0 degree, directly above, to 180 degree, directly below).
    /// Default value: [1.15,210,30].
    public func position(radial: Double, azimuthal: Double, polar: Double) -> Self {
        with(self, setter(\.position, .constant([radial, azimuthal, polar])))
    }

    /// Transition property for `position`
    public func positionTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.positionTransition, transition))
    }

    /// Position of the light source relative to lit (extruded) geometries, in [r radial coordinate, a azimuthal angle, p polar angle] where r indicates the distance from the center of the base of an object to its light, a indicates the position of the light relative to 0 degree (0 degree when `light.anchor` is set to `viewport` corresponds to the top of the viewport, or 0 degree when `light.anchor` is set to `map` corresponds to due north, and degrees proceed clockwise), and p indicates the height of the light (from 0 degree, directly above, to 180 degree, directly below).
    /// Default value: [1.15,210,30].
    public func position(_ expression: Exp) -> Self {
        with(self, setter(\.position, .expression(expression)))
    }
}

extension FlatLight: MapStyleContent, PrimitiveMapContent {
    func visit(_ node: MapContentNode) {
        node.mount(MountedUniqueProperty(keyPath: \.lights.flat, value: self))
    }
}
// End of generated file.
