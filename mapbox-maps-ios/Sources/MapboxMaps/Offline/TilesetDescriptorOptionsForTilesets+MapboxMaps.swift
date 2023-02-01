import Foundation
@_implementationOnly import MapboxCoreMaps_Private

extension TilesetDescriptorOptionsForTilesets {
    /// Initializes a `TilesetDescriptorOptionsForTilesets` which is used in the creation of
    /// a `TilesetDescriptor`.
    ///
    /// - Parameters:
    ///   - tilesets: The tilesets associated with the tileset descriptor. An array, each element of which must be either a URI to a TileJSON resource or a JSON string representing the inline tileset. The provided URIs must have "mapbox://" scheme, e.g. "mapbox://mapbox.mapbox-streets-v8".
    ///   - zoomRange: Closed range zoom level for the tile package.
    ///   - pixelRatio: Pixel ratio to be accounted for when downloading raster
    ///         tiles. Typically this should match the scale used by the `MapView`,
    ///         most likely `UIScreen.main.scale`, which is the default value.
    ///
    /// - Note: The implementation loads and stores the loaded tiles in batches,
    ///     each batch has a pre-defined zoom range and it contains all child
    ///     tiles within the range. The zoom leveling scheme for the tile batches
    ///     can be defined in Tile JSON, otherwise the default scheme is used:
    ///
    /// * Global coverage: 0 - 5
    /// * Regional information: 6 - 10
    /// * Local information: 11 - 14
    /// * Streets detail: 15 - 16
    ///
    /// Internally, the implementation maps the given tile pack zoom range
    /// and geometry to a set of pre-defined batches to load, therefore
    /// it is highly recommended to choose the `minZoom` and `maxZoom` values
    /// in accordance with the tile batches zoom ranges (see the list above).
    public convenience init(tilesets: [String],
                            zoomRange: ClosedRange<UInt8>,
                            pixelRatio: Float = Float(UIScreen.main.scale)) {
        self.init(tilesets: tilesets,
                  minZoom: zoomRange.lowerBound,
                  maxZoom: zoomRange.upperBound,
                  pixelRatio: pixelRatio,
                  extraOptions: nil)
    }
}
