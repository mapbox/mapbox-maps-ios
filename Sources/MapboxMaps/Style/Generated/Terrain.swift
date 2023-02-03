// This file is generated.
import Foundation


/// The global terrain source.
///
/// - SeeAlso: [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-style-spec/#terrain)
public struct Terrain: Codable, Equatable  {

    public var source: String

    public init(sourceId: String, exaggeration: Value<Double>? = nil) {
        self.source = sourceId
        self.exaggeration = exaggeration
    }
    

    /// Exaggerates the elevation of the terrain by multiplying the data from the DEM with this value.
    public var exaggeration: Value<Double>?
}

// End of generated file.
