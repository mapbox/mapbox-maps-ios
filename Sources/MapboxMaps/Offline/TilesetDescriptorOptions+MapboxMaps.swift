import UIKit

extension TilesetDescriptorOptions {
    /// Initializes a `TilesetDescriptorOptions` which is used in the creation of
    /// a `TilesetDescriptor`.
    ///
    /// - Parameters:
    ///   - styleURI: The style associated with the tileset descriptor.
    ///   - zoomRange: Closed range zoom level for the tile package.
    ///   - pixelRatio: Pixel ratio to be accounted for when downloading raster
    ///         tiles. Typically this should match the scale used by the `MapView`,
    ///         most likely `UIScreen.main.scale`, which is the default value.
    ///   - tilesets: The tilesets associated with the tileset descriptor. An array, each element of which must be either a URI to a TileJSON resource or a JSON string representing the inline tileset. The provided URIs must have "mapbox://" scheme, e.g. "mapbox://mapbox.mapbox-streets-v8".
    ///   - stylePackOptions: Style package load options, associated with the
    ///         tileset descriptor.
    ///   - extraOptions: Extra tileset descriptor options. Must be a valid JSON object.
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
    /// it is highly recommended to choose the minZoom and maxZoom values
    /// in accordance with the tile batches zoom ranges (see the list above).
    ///
    /// - Note: If a `stylePackOptions` is provided, `OfflineManager` will create a
    ///     style package while resolving the corresponding tileset descriptor
    ///     and load all the resources as defined in the provided style package
    ///     options. i.e. resolving the corresponding tileset descriptor
    ///     will be equivalent to calling the `loadStylePack()` method of
    ///     `OfflineManager`.
    ///
    ///     If not provided, resolving of the corresponding tileset descriptor
    ///     will not cause creating of a new style package but the loaded
    ///     resources will be stored in the disk cache.
    ///
    ///     Style package creation requires nonempty `styleURL`,
    ///     which will be the created style package identifier.
    public convenience init(
        styleURI: StyleURI,
        zoomRange: ClosedRange<UInt8>,
        pixelRatio: Float? = nil,
        tilesets: [String]?,
        stylePackOptions: StylePackLoadOptions? = nil,
        extraOptions: Any? = nil
    ) {
        let extraOptions = extraOptions.flatMap { JSONSerialization.isValidJSONObject($0) ? $0 : nil }
        self.init(
            styleURI: styleURI.rawValue,
            minZoom: zoomRange.lowerBound,
            maxZoom: zoomRange.upperBound,
            pixelRatio: pixelRatio ?? Float(ScreenShim.scale),
            tilesets: tilesets,
            stylePack: stylePackOptions,
            extraOptions: extraOptions)
    }
}
