import Foundation

extension TileRegionLoadOptions {
    /// Initializes a `TileRegionLoadOptions`, required for
    /// `TileStore.loadTileRegion(forId:loadOptions:)`
    ///
    /// - Parameters:
    ///   - geometry: The tile region's associated geometry (optional).
    ///   - descriptors: The tile region's tileset descriptors. If presented, will update the region
    ///   with new descriptor.
    ///   - metadata: A custom JSON value to be associated with this tile region.
    ///   - extraOptions: Restrict the tile region load request to the
    ///         specified network types. If none of the specified network types
    ///         is available, the load request fails with an error. Must be a valid JSON object.
    ///   - acceptExpired: is not a strict bandwidth limit, but only
    ///         limits the average download speed. Tile regions may be temporarily
    ///         downloaded with higher speed, then downloading will pause until the rolling
    ///         average has dropped below this value.
    ///   - networkRestriction: Classify network types based on cost.
    ///   - averageBytesPerSecond: Limits the download speed of the tile region.
    ///
    /// - Note: If `metadata` is not a valid JSON object, then this initializer returns `nil`.
    public convenience init?(
        geometry: Geometry?,
        descriptors: [TilesetDescriptor]? = nil,
        metadata: Any? = nil,
        acceptExpired: Bool = false,
        networkRestriction: NetworkRestriction = .none,
        averageBytesPerSecond: Int? = nil,
        extraOptions: Any? = nil
    ) {

        guard metadata.map(JSONSerialization.isValidJSONObject(_:)) != false else { return nil }

        let extraOptions = extraOptions.flatMap { JSONSerialization.isValidJSONObject($0) ? $0 : nil }
        let commonGeometry = geometry.flatMap(MapboxCommon.Geometry.init(_:))

        self.init(__geometry: commonGeometry,
                  descriptors: descriptors,
                  metadata: metadata,
                  acceptExpired: acceptExpired,
                  networkRestriction: networkRestriction,
                  startLocation: nil, // Not yet implemented
                  averageBytesPerSecond: averageBytesPerSecond?.NSNumber,
                  extraOptions: extraOptions)
    }

    /// Limits the download speed of the tile region.
    ///
    /// Note that this is not a strict bandwidth limit, but only limits the
    /// average download speed. Tile regions may be temporarily downloaded with
    /// higher speed, then downloading will pause until the rolling average has
    /// dropped below this value.
    ///
    /// If unspecified, the download speed will not be restricted.
    public var averageBytesPerSecond: Int? {
        __averageBytesPerSecond?.intValue
    }

    /// The geometry supported by these options.
    public var geometry: Geometry? {
        guard let commonGeometry = __geometry else {
            return nil
        }

        return Geometry(commonGeometry)
    }
}
