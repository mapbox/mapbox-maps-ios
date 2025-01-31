// This file is generated.
import Foundation

/// The global terrain source.
///
/// - SeeAlso: [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-style-spec/#terrain)
public struct Terrain: Codable, Equatable {

    public var source: String

    public init(sourceId: String) {
        self.source = sourceId
    }

    /// Exaggerates the elevation of the terrain by multiplying the data from the DEM with this value.
    /// Default value: 1. Value range: [0, 1000]
    public var exaggeration: Value<Double>?

    /// Transition options for `Exaggeration`.
    public var exaggerationTransition: StyleTransition?


    enum CodingKeys: String, CodingKey {
        case source = "source"
        case exaggeration = "exaggeration"
        case exaggerationTransition = "exaggeration-transition"
    }
}

extension Terrain {
    /// Exaggerates the elevation of the terrain by multiplying the data from the DEM with this value.
    /// Default value: 1. Value range: [0, 1000]
    public func exaggeration(_ constant: Double) -> Self {
        with(self, setter(\.exaggeration, .constant(constant)))
    }

    /// Transition property for `exaggeration`
    public func exaggerationTransition(_ transition: StyleTransition) -> Self {
        with(self, setter(\.exaggerationTransition, transition))
    }

    /// Exaggerates the elevation of the terrain by multiplying the data from the DEM with this value.
    /// Default value: 1. Value range: [0, 1000]
    public func exaggeration(_ expression: Exp) -> Self {
        with(self, setter(\.exaggeration, .expression(expression)))
    }
}

extension Terrain: MapStyleContent, PrimitiveMapContent {
    func visit(_ node: MapContentNode) {
        node.mount(MountedUniqueProperty(keyPath: \.terrain, value: self))
    }
}

// End of generated file.
