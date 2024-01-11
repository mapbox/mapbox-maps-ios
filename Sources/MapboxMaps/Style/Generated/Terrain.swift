// This file is generated.
import Foundation


/// The global terrain source.
///
/// - SeeAlso: [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-style-spec/#terrain)
public struct Terrain: Codable, Equatable  {

    public var source: String

    public init(sourceId: String) {
        self.source = sourceId
    }

    /// Exaggerates the elevation of the terrain by multiplying the data from the DEM with this value.
    public var exaggeration: Value<Double>?
}

#if swift(>=5.8)
@_documentation(visibility: public)
#endif
@_spi(Experimental) extension Terrain: PrimitiveMapStyleContent {
    func _visit(_ visitor: MapStyleContentVisitor) {
        visitor.model.terrain = self
    }

    #if swift(>=5.8)
    @_documentation(visibility: public)
    #endif
    /// Exaggerates the elevation of the terrain by multiplying the data from the DEM with this value.
    public func exaggeration(_ newValue: Value<Double>) -> Self {
        with(self, setter(\.exaggeration, newValue))
    }
}

// End of generated file.
