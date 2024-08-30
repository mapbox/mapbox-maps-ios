import MapboxCoreMaps

/// Various options needed for tile cover.
    @_documentation(visibility: public)
@_spi(Experimental)
public struct TileCoverOptions: Sendable {
    /// Tile size of the source. Defaults to 512.
    @_documentation(visibility: public)
    public var tileSize: UInt16?

    /// Min zoom defined in the source between range [0, 22].
    /// if not provided or is out of range, defaults to 0.
    @_documentation(visibility: public)
    public var minZoom: UInt8?

    /// Max zoom defined in the source between range [0, 22].
    /// Should be greater than or equal to minZoom.
    /// If not provided or is out of range, defaults to 22.
    @_documentation(visibility: public)
    public var maxZoom: UInt8?

    /// Whether to round zoom values when calculating tilecover.
    /// Set this to true for raster and raster-dem sources.
    /// If not specified, defaults to false.
    @_documentation(visibility: public)
    public var roundZoom: Bool?

    /// Creates the TileCoverOptions.
    @_documentation(visibility: public)
    public init(
        tileSize: UInt16? = nil,
        minZoom: UInt8? = nil,
        maxZoom: UInt8? = nil,
        roundZoom: Bool? = nil
    ) {
        self.tileSize = tileSize
        self.minZoom = minZoom
        self.maxZoom = maxZoom
        self.roundZoom = roundZoom
    }
}

extension CoreTileCoverOptions {
    internal convenience init(_ options: TileCoverOptions) {
            self.init(
                __tileSize: options.tileSize.map { NSNumber(value: $0) },
                minZoom: options.minZoom.map { NSNumber(value: $0) },
                maxZoom: options.maxZoom.map { NSNumber(value: $0) },
                roundZoom: options.roundZoom.map { NSNumber(value: $0) })
    }
}
