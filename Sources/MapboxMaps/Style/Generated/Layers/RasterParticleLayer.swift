// This file is generated.
import UIKit

/// Particle animation driven by textures such as wind maps.
///
/// - SeeAlso: [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-style-spec/#layers-raster-particle)
@_documentation(visibility: public)
@_spi(Experimental) public struct RasterParticleLayer: Layer, Equatable {

    // MARK: - Conformance to `Layer` protocol
    /// Unique layer name
    @_documentation(visibility: public)
    public var id: String

    /// Rendering type of this layer.
    @_documentation(visibility: public)
    public let type: LayerType

    /// An expression specifying conditions on source features.
    /// Only features that match the filter are displayed.
    @_documentation(visibility: public)
    public var filter: Exp?

    /// Name of a source description to be used for this layer.
    /// Required for all layer types except ``BackgroundLayer``, ``SkyLayer``, and ``LocationIndicatorLayer``.
    @_documentation(visibility: public)
    public var source: String?

    /// Layer to use from a vector tile source.
    ///
    /// Required for vector tile sources.
    /// Prohibited for all other source types, including GeoJSON sources.
    @_documentation(visibility: public)
    public var sourceLayer: String?

    /// The slot this layer is assigned to. If specified, and a slot with that name exists, it will be placed at that position in the layer order.
    @_documentation(visibility: public)
    public var slot: Slot?

    /// The minimum zoom level for the layer. At zoom levels less than the minzoom, the layer will be hidden.
    @_documentation(visibility: public)
    public var minZoom: Double?

    /// The maximum zoom level for the layer. At zoom levels equal to or greater than the maxzoom, the layer will be hidden.
    @_documentation(visibility: public)
    public var maxZoom: Double?

    /// Whether this layer is displayed.
    @_documentation(visibility: public)
    public var visibility: Value<Visibility>

    /// Displayed band of raster array source layer
    @_documentation(visibility: public)
    public var rasterParticleArrayBand: Value<String>?

    /// Defines a color map by which to colorize a raster particle layer, parameterized by the `["raster-particle-speed"]` expression and evaluated at 256 uniformly spaced steps over the range specified by `raster-particle-max-speed`.
    @_documentation(visibility: public)
    public var rasterParticleColor: Value<StyleColor>?
    /// This property defines whether to use colorTheme defined color or not.
    /// By default it will use color defined by the root theme in the style.
    /// NOTE: - Expressions set to this property currently don't work.
    @_spi(Experimental) public var rasterParticleColorUseTheme: Value<ColorUseTheme>?

    /// Defines the amount of particles per tile.
    /// Default value: 512. Minimum value: 1.
    @_documentation(visibility: public)
    public var rasterParticleCount: Value<Double>?

    /// Defines defines the opacity coefficient applied to the faded particles in each frame. In practice, this property controls the length of the particle tail.
    /// Default value: 0.98. Value range: [0, 1]
    @_documentation(visibility: public)
    public var rasterParticleFadeOpacityFactor: Value<Double>?

    /// Transition options for `rasterParticleFadeOpacityFactor`.
    @_documentation(visibility: public)
    public var rasterParticleFadeOpacityFactorTransition: StyleTransition?

    /// Defines the maximum speed for particles. Velocities with magnitudes equal to or exceeding this value are clamped to the max value.
    /// Default value: 1. Minimum value: 1.
    @_documentation(visibility: public)
    public var rasterParticleMaxSpeed: Value<Double>?

    /// Defines a coefficient for a time period at which particles will restart at a random position, to avoid degeneration (empty areas without particles).
    /// Default value: 0.8. Value range: [0, 1]
    @_documentation(visibility: public)
    public var rasterParticleResetRateFactor: Value<Double>?

    /// Defines a coefficient for the speed of particles’ motion.
    /// Default value: 0.2. Value range: [0, 1]
    @_documentation(visibility: public)
    public var rasterParticleSpeedFactor: Value<Double>?

    /// Transition options for `rasterParticleSpeedFactor`.
    @_documentation(visibility: public)
    public var rasterParticleSpeedFactorTransition: StyleTransition?

    @_documentation(visibility: public)
    public init(id: String, source: String) {
        self.source = source
        self.id = id
        self.type = LayerType.rasterParticle
        self.visibility = .constant(.visible)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: RootCodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encodeIfPresent(filter, forKey: .filter)
        try container.encodeIfPresent(source, forKey: .source)
        try container.encodeIfPresent(sourceLayer, forKey: .sourceLayer)
        try container.encodeIfPresent(slot, forKey: .slot)
        try container.encodeIfPresent(minZoom, forKey: .minZoom)
        try container.encodeIfPresent(maxZoom, forKey: .maxZoom)

        var paintContainer = container.nestedContainer(keyedBy: PaintCodingKeys.self, forKey: .paint)
        try paintContainer.encodeIfPresent(rasterParticleArrayBand, forKey: .rasterParticleArrayBand)
        try paintContainer.encodeIfPresent(rasterParticleColor, forKey: .rasterParticleColor)
        try paintContainer.encodeIfPresent(rasterParticleColorUseTheme, forKey: .rasterParticleColorUseTheme)
        try paintContainer.encodeIfPresent(rasterParticleCount, forKey: .rasterParticleCount)
        try paintContainer.encodeIfPresent(rasterParticleFadeOpacityFactor, forKey: .rasterParticleFadeOpacityFactor)
        try paintContainer.encodeIfPresent(rasterParticleFadeOpacityFactorTransition, forKey: .rasterParticleFadeOpacityFactorTransition)
        try paintContainer.encodeIfPresent(rasterParticleMaxSpeed, forKey: .rasterParticleMaxSpeed)
        try paintContainer.encodeIfPresent(rasterParticleResetRateFactor, forKey: .rasterParticleResetRateFactor)
        try paintContainer.encodeIfPresent(rasterParticleSpeedFactor, forKey: .rasterParticleSpeedFactor)
        try paintContainer.encodeIfPresent(rasterParticleSpeedFactorTransition, forKey: .rasterParticleSpeedFactorTransition)

        var layoutContainer = container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout)
        try layoutContainer.encode(visibility, forKey: .visibility)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: RootCodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(LayerType.self, forKey: .type)
        filter = try container.decodeIfPresent(Exp.self, forKey: .filter)
        source = try container.decodeIfPresent(String.self, forKey: .source)
        sourceLayer = try container.decodeIfPresent(String.self, forKey: .sourceLayer)
        slot = try container.decodeIfPresent(Slot.self, forKey: .slot)
        minZoom = try container.decodeIfPresent(Double.self, forKey: .minZoom)
        maxZoom = try container.decodeIfPresent(Double.self, forKey: .maxZoom)

        if let paintContainer = try? container.nestedContainer(keyedBy: PaintCodingKeys.self, forKey: .paint) {
            rasterParticleArrayBand = try paintContainer.decodeIfPresent(Value<String>.self, forKey: .rasterParticleArrayBand)
            rasterParticleColor = try paintContainer.decodeIfPresent(Value<StyleColor>.self, forKey: .rasterParticleColor)
            rasterParticleColorUseTheme = try paintContainer.decodeIfPresent(Value<ColorUseTheme>.self, forKey: .rasterParticleColorUseTheme)
            rasterParticleCount = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .rasterParticleCount)
            rasterParticleFadeOpacityFactor = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .rasterParticleFadeOpacityFactor)
            rasterParticleFadeOpacityFactorTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .rasterParticleFadeOpacityFactorTransition)
            rasterParticleMaxSpeed = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .rasterParticleMaxSpeed)
            rasterParticleResetRateFactor = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .rasterParticleResetRateFactor)
            rasterParticleSpeedFactor = try paintContainer.decodeIfPresent(Value<Double>.self, forKey: .rasterParticleSpeedFactor)
            rasterParticleSpeedFactorTransition = try paintContainer.decodeIfPresent(StyleTransition.self, forKey: .rasterParticleSpeedFactorTransition)
        }

        var visibilityEncoded: Value<Visibility>?
        if let layoutContainer = try? container.nestedContainer(keyedBy: LayoutCodingKeys.self, forKey: .layout) {
            visibilityEncoded = try layoutContainer.decodeIfPresent(Value<Visibility>.self, forKey: .visibility)
        }
        visibility = visibilityEncoded ?? .constant(.visible)
    }

    enum RootCodingKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case filter = "filter"
        case source = "source"
        case sourceLayer = "source-layer"
        case slot = "slot"
        case minZoom = "minzoom"
        case maxZoom = "maxzoom"
        case layout = "layout"
        case paint = "paint"
    }

    enum LayoutCodingKeys: String, CodingKey {
        case visibility = "visibility"
    }

    enum PaintCodingKeys: String, CodingKey {
        case rasterParticleArrayBand = "raster-particle-array-band"
        case rasterParticleColor = "raster-particle-color"
        case rasterParticleColorUseTheme = "raster-particle-color-use-theme"
        case rasterParticleCount = "raster-particle-count"
        case rasterParticleFadeOpacityFactor = "raster-particle-fade-opacity-factor"
        case rasterParticleFadeOpacityFactorTransition = "raster-particle-fade-opacity-factor-transition"
        case rasterParticleMaxSpeed = "raster-particle-max-speed"
        case rasterParticleResetRateFactor = "raster-particle-reset-rate-factor"
        case rasterParticleSpeedFactor = "raster-particle-speed-factor"
        case rasterParticleSpeedFactorTransition = "raster-particle-speed-factor-transition"
    }
}

extension RasterParticleLayer {
    /// An expression specifying conditions on source features.
    /// Only features that match the filter are displayed.
    public func filter(_ newValue: Exp) -> Self {
        with(self, setter(\.filter, newValue))
    }

    /// Name of a source description to be used for this layer.
    /// Required for all layer types except ``BackgroundLayer``, ``SkyLayer``, and ``LocationIndicatorLayer``.
    public func source(_ newValue: String) -> Self {
        with(self, setter(\.source, newValue))
    }

    /// Layer to use from a vector tile source.
    ///
    /// Required for vector tile sources.
    /// Prohibited for all other source types, including GeoJSON sources.
    public func sourceLayer(_ newValue: String) -> Self {
        with(self, setter(\.sourceLayer, newValue))
    }

    /// The slot this layer is assigned to.
    /// If specified, and a slot with that name exists, it will be placed at that position in the layer order.
    public func slot(_ newValue: Slot?) -> Self {
        with(self, setter(\.slot, newValue))
    }

    /// The minimum zoom level for the layer. At zoom levels less than the minzoom, the layer will be hidden.
    public func minZoom(_ newValue: Double) -> Self {
        with(self, setter(\.minZoom, newValue))
    }

    /// The maximum zoom level for the layer. At zoom levels equal to or greater than the maxzoom, the layer will be hidden.
    public func maxZoom(_ newValue: Double) -> Self {
        with(self, setter(\.maxZoom, newValue))
    }

    /// Displayed band of raster array source layer
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func rasterParticleArrayBand(_ constant: String) -> Self {
        with(self, setter(\.rasterParticleArrayBand, .constant(constant)))
    }

    /// Displayed band of raster array source layer
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func rasterParticleArrayBand(_ expression: Exp) -> Self {
        with(self, setter(\.rasterParticleArrayBand, .expression(expression)))
    }

    /// Defines a color map by which to colorize a raster particle layer, parameterized by the `["raster-particle-speed"]` expression and evaluated at 256 uniformly spaced steps over the range specified by `raster-particle-max-speed`.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func rasterParticleColor(_ constant: StyleColor) -> Self {
        with(self, setter(\.rasterParticleColor, .constant(constant)))
    }

    /// Defines a color map by which to colorize a raster particle layer, parameterized by the `["raster-particle-speed"]` expression and evaluated at 256 uniformly spaced steps over the range specified by `raster-particle-max-speed`.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func rasterParticleColor(_ color: UIColor) -> Self {
        with(self, setter(\.rasterParticleColor, .constant(StyleColor(color))))
    }

    /// Defines a color map by which to colorize a raster particle layer, parameterized by the `["raster-particle-speed"]` expression and evaluated at 256 uniformly spaced steps over the range specified by `raster-particle-max-speed`.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func rasterParticleColor(_ expression: Exp) -> Self {
        with(self, setter(\.rasterParticleColor, .expression(expression)))
    }

    /// This property defines whether the `rasterParticleColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func rasterParticleColorUseTheme(_ useTheme: ColorUseTheme) -> Self {
        with(self, setter(\.rasterParticleColorUseTheme, .constant(useTheme)))
    }

    /// This property defines whether the `rasterParticleColor` uses colorTheme from the style or not.
    /// By default it will use color defined by the root theme in the style.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func rasterParticleColorUseTheme(_ expression: Exp) -> Self {
        with(self, setter(\.rasterParticleColorUseTheme, .expression(expression)))
    }

    /// Defines the amount of particles per tile.
    /// Default value: 512. Minimum value: 1.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func rasterParticleCount(_ constant: Double) -> Self {
        with(self, setter(\.rasterParticleCount, .constant(constant)))
    }

    /// Defines the amount of particles per tile.
    /// Default value: 512. Minimum value: 1.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func rasterParticleCount(_ expression: Exp) -> Self {
        with(self, setter(\.rasterParticleCount, .expression(expression)))
    }

    /// Defines defines the opacity coefficient applied to the faded particles in each frame. In practice, this property controls the length of the particle tail.
    /// Default value: 0.98. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func rasterParticleFadeOpacityFactor(_ constant: Double) -> Self {
        with(self, setter(\.rasterParticleFadeOpacityFactor, .constant(constant)))
    }

    /// Transition property for `rasterParticleFadeOpacityFactor`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func rasterParticleFadeOpacityFactorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.rasterParticleFadeOpacityFactorTransition, transition))
    }

    /// Defines defines the opacity coefficient applied to the faded particles in each frame. In practice, this property controls the length of the particle tail.
    /// Default value: 0.98. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func rasterParticleFadeOpacityFactor(_ expression: Exp) -> Self {
        with(self, setter(\.rasterParticleFadeOpacityFactor, .expression(expression)))
    }

    /// Defines the maximum speed for particles. Velocities with magnitudes equal to or exceeding this value are clamped to the max value.
    /// Default value: 1. Minimum value: 1.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func rasterParticleMaxSpeed(_ constant: Double) -> Self {
        with(self, setter(\.rasterParticleMaxSpeed, .constant(constant)))
    }

    /// Defines the maximum speed for particles. Velocities with magnitudes equal to or exceeding this value are clamped to the max value.
    /// Default value: 1. Minimum value: 1.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func rasterParticleMaxSpeed(_ expression: Exp) -> Self {
        with(self, setter(\.rasterParticleMaxSpeed, .expression(expression)))
    }

    /// Defines a coefficient for a time period at which particles will restart at a random position, to avoid degeneration (empty areas without particles).
    /// Default value: 0.8. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func rasterParticleResetRateFactor(_ constant: Double) -> Self {
        with(self, setter(\.rasterParticleResetRateFactor, .constant(constant)))
    }

    /// Defines a coefficient for a time period at which particles will restart at a random position, to avoid degeneration (empty areas without particles).
    /// Default value: 0.8. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func rasterParticleResetRateFactor(_ expression: Exp) -> Self {
        with(self, setter(\.rasterParticleResetRateFactor, .expression(expression)))
    }

    /// Defines a coefficient for the speed of particles’ motion.
    /// Default value: 0.2. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func rasterParticleSpeedFactor(_ constant: Double) -> Self {
        with(self, setter(\.rasterParticleSpeedFactor, .constant(constant)))
    }

    /// Transition property for `rasterParticleSpeedFactor`
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func rasterParticleSpeedFactorTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.rasterParticleSpeedFactorTransition, transition))
    }

    /// Defines a coefficient for the speed of particles’ motion.
    /// Default value: 0.2. Value range: [0, 1]
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func rasterParticleSpeedFactor(_ expression: Exp) -> Self {
        with(self, setter(\.rasterParticleSpeedFactor, .expression(expression)))
    }
}

extension RasterParticleLayer: MapStyleContent, PrimitiveMapContent {
    func visit(_ node: MapContentNode) {
        node.mount(MountedLayer(layer: self))
    }
}

// End of generated file.
