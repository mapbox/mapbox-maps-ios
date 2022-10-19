import Foundation

extension TileRegionLoadOptions {
    /// Initializes a `TileRegionLoadOptions`, required for
    /// `TileStore.loadTileRegion(forId:loadOptions:)`
    ///
    /// - Parameters:
    ///   - geometry: The tile region's associated geometry (optional).
    ///   - descriptors: The tile region's tileset descriptors.
    ///   - metadata: A custom JSON value to be associated with this tile region.
    ///   - tileLoadOptions: Restrict the tile region load request to the
    ///         specified network types. If none of the specified network types
    ///         is available, the load request fails with an error.
    ///   - averageBytesPerSecond: Limits the download speed of the tile region.
    ///
    /// `averageBytesPerSecond` is not a strict bandwidth limit, but only
    /// limits the average download speed. Tile regions may be temporarily
    /// downloaded with higher speed, then downloading will pause until the rolling
    /// average has dropped below this value.
    ///
    /// If `metadata` is not a valid JSON object, then this initializer returns
    /// `nil`.
    public convenience init?(geometry: Geometry?,
                             descriptors: [TilesetDescriptor],
                             metadata: Any? = nil,
                             acceptExpired: Bool = false,
                             networkRestriction: NetworkRestriction = .none,
                             averageBytesPerSecond: Int? = nil) {
        if let metadata = metadata {
            guard JSONSerialization.isValidJSONObject(metadata) else {
                return nil
            }
        }

        var commonGeometry: MapboxCommon.Geometry?
        if let geometry = geometry {
            commonGeometry = MapboxCommon.Geometry(geometry)
        }

        self.init(__geometry: commonGeometry,
                  descriptors: descriptors.isEmpty ? nil : descriptors,
                  metadata: metadata,
                  acceptExpired: acceptExpired,
                  networkRestriction: networkRestriction,
                  start: nil, // Not yet implemented
                  averageBytesPerSecond: averageBytesPerSecond?.NSNumber,
                  extraOptions: nil)
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
