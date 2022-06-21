// This file is generated.
import Foundation

/// A spherical dome around the map that is always rendered behind all other layers.
///
/// - SeeAlso: [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-style-spec/#layers-sky)
public struct SkyLayer: Layer {

    // MARK: - Conformance to `Layer` protocol
    public var id: String
    public let type: LayerType
    public var filter: Expression?
    public var source: String?
    public var sourceLayer: String?
    public var minZoom: Double?
    public var maxZoom: Double?

    /// Whether this layer is displayed.
    public var visibility: Value<Visibility>?

    /// A color used to tweak the main atmospheric scattering coefficients. Using white applies the default coefficients giving the natural blue color to the atmosphere. This color affects how heavily the corresponding wavelength is represented during scattering. The alpha channel describes the density of the atmosphere, with 1 maximum density and 0 no density.
    public var skyAtmosphereColor: Value<StyleColor>?

    /// A color applied to the atmosphere sun halo. The alpha channel describes how strongly the sun halo is represented in an atmosphere sky layer.
    public var skyAtmosphereHaloColor: Value<StyleColor>?

    /// Position of the sun center [a azimuthal angle, p polar angle]. The azimuthal angle indicates the position of the sun relative to 0 degree north, where degrees proceed clockwise. The polar angle indicates the height of the sun, where 0 degree is directly above, at zenith, and 90 degree at the horizon. When this property is ommitted, the sun center is directly inherited from the light position.
    public var skyAtmosphereSun: Value<[Double]>?

    /// Intensity of the sun as a light source in the atmosphere (on a scale from 0 to a 100). Setting higher values will brighten up the sky.
    public var skyAtmosphereSunIntensity: Value<Double>?

    /// Defines a radial color gradient with which to color the sky. The color values can be interpolated with an expression using `sky-radial-progress`. The range [0, 1] for the interpolant covers a radial distance (in degrees) of [0, `sky-gradient-radius`] centered at the position specified by `sky-gradient-center`.
    public var skyGradient: Value<StyleColor>?

    /// Position of the gradient center [a azimuthal angle, p polar angle]. The azimuthal angle indicates the position of the gradient center relative to 0 degree north, where degrees proceed clockwise. The polar angle indicates the height of the gradient center, where 0 degree is directly above, at zenith, and 90 degree at the horizon.
    public var skyGradientCenter: Value<[Double]>?

    /// The angular distance (measured in degrees) from `sky-gradient-center` up to which the gradient extends. A value of 180 causes the gradient to wrap around to the opposite direction from `sky-gradient-center`.
    public var skyGradientRadius: Value<Double>?

    /// The opacity of the entire sky layer.
    public var skyOpacity: Value<Double>?

    /// Transition options for `skyOpacity`.
    public var skyOpacityTransition: StyleTransition?

    /// The type of the sky
    public var skyType: Value<SkyType>?

    public init(id: String) {
        self.id = id
        self.type = LayerType.sky
        self.visibility = .constant(.visible)
    }

    public func encode(to encoder: Encoder) throws {
        let nilEncoder = NilEncoder(userInfo: encoder.userInfo)

        var container = encoder.container(keyedBy: RootCodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try nilEncoder.encode(filter, forKey: .filter, to: &container)
        try nilEncoder.encode(source, forKey: .source, to: &container)
        try nilEncoder.encode(sourceLayer, forKey: .sourceLayer, to: &container)
        try nilEncoder.encode(minZoom, forKey: .minZoom, to: &container)
        try nilEncoder.encode(maxZoom, forKey: .maxZoom, to: &container)

        var paintContainer = container.nestedContainer(keyedBy: PaintCodingKeys.self, forKey: .paint)
        try nilEncoder.encode(skyAtmosphereColor, forKey: .skyAtmosphereColor, to: &paintContainer)
        try nilEncoder.encode(skyAtmosphereHaloColor, forKey: .skyAtmosphereHaloColor, to: &paintContainer)
        try nilEncoder.encode(skyAtmosphereSun, forKey: .skyAtmosphereSun, to: &paintContainer)
        try nilEncoder.encode(skyAtmosphereSunIntensity, forKey: .skyAtmosphereSunIntensity, to: &paintContainer)
        try nilEncoder.encode(skyGradient, forKey: .skyGradient, to: &paintContainer)
        try nilEncoder.encode(skyGradientCenter, forKey: .skyGradientCenter, to: &paintContainer)
        try nilEncoder.encode(skyGradientRadius, forKey: .skyGradientRadius, to: &paintContainer)
        try nilEncoder.encode(skyOpacity, forKey: .skyOpacity, to: &paintContainer)
        try nilEncoder.encode(skyOpacityTransition, forKey: .skyOpacityTransition, to: &paintContainer)
        try nilEncoder.encode(skyType, forKey: .skyType, to: &paintContainer)

        var layoutContainer = container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout)
        try nilEncoder.encode(visibility, forKey: .visibility, to: &layoutContainer)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootCodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(LayerType.self, forKey: .type)
        filter = try container.decodeIfPresent(Expression.self, forKey: .filter)
        source = try container.decodeIfPresent(String.self, forKey: .source)
        sourceLayer = try container.decodeIfPresent(String.self, forKey: .sourceLayer)
        minZoom = try container.decodeIfPresent(Double.self, forKey: .minZoom)
        maxZoom = try container.decodeIfPresent(Double.self, forKey: .maxZoom)

        if let paintContainer = try? container.nestedContainer(keyedBy: PaintCodingKeys.self, forKey: .paint) {
            skyAtmosphereColor = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .skyAtmosphereColor)
            skyAtmosphereHaloColor = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .skyAtmosphereHaloColor)
            skyAtmosphereSun = try paintContainer.decodeIfPresent(Value<[Double]>.self, forKey: .skyAtmosphereSun)
            skyAtmosphereSunIntensity = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .skyAtmosphereSunIntensity)
            skyGradient = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .skyGradient)
            skyGradientCenter = try paintContainer.decodeIfPresent(Value<[Double]>.self, forKey: .skyGradientCenter)
            skyGradientRadius = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .skyGradientRadius)
            skyOpacity = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .skyOpacity)
            skyOpacityTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .skyOpacityTransition)
            skyType = try paintContainer.decodeIfPresent(Value<SkyType>.self, forKey: .skyType)
        }

        if let layoutContainer = try? container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout) {
            visibility = try layoutContainer.decodeIfPresent(Value<Visibility>.self, forKey: .visibility)
        }
    }

    enum RootCodingKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case filter = "filter"
        case source = "source"
        case sourceLayer = "source-layer"
        case minZoom = "minzoom"
        case maxZoom = "maxzoom"
        case layout = "layout"
        case paint = "paint"
    }

    enum LayoutCodingKeys: String, CodingKey {
        case visibility = "visibility"
    }

    enum PaintCodingKeys: String, CodingKey {
        case skyAtmosphereColor = "sky-atmosphere-color"
        case skyAtmosphereHaloColor = "sky-atmosphere-halo-color"
        case skyAtmosphereSun = "sky-atmosphere-sun"
        case skyAtmosphereSunIntensity = "sky-atmosphere-sun-intensity"
        case skyGradient = "sky-gradient"
        case skyGradientCenter = "sky-gradient-center"
        case skyGradientRadius = "sky-gradient-radius"
        case skyOpacity = "sky-opacity"
        case skyOpacityTransition = "sky-opacity-transition"
        case skyType = "sky-type"
    }
}

// End of generated file.
