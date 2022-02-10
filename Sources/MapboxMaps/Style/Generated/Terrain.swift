// This file is generated.
import Foundation


/// The global terrain source.
///
/// - SeeAlso: [Mapbox Style Specification](https://www.mapbox.com/mapbox-gl-style-spec/#terrain)
public struct Terrain: Codable  {

    public var source: String

    public init(sourceId: String) {
        self.source = sourceId
    }

    /// Exaggerates the elevation of the terrain by multiplying the data from the DEM with this value.
    public var exaggeration: Value<Double>?
}

// End of generated file.
