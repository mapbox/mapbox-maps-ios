import Foundation
@_implementationOnly import MapboxCommon_Private

// MARK: - ResourceOptions

/// Options to configure access to a resource
public struct ResourceOptions {

    /// The access token to access the resource. This should be a valid, non-empty,
    /// Mapbox access token
    public var accessToken: String

    /// The base URL. Leave as `nil` unless you have a reason to change this.
    public var baseURL: URL?

    /// The file URL to the cache. The default, `nil`, will choose an appropriate
    /// location on the device. The default location is excluded from backups.
    public var dataPathURL: URL?

    /// The path to the assets. The default, `nil`, uses the main bundle.
    public var assetPathURL: URL?

    /// The tile store instance
    ///
    /// This setting can be applied only if tile store usage is enabled,
    /// otherwise it is ignored.
    ///
    /// If not set and tile store usage is enabled, a tile store at the default
    /// location will be created and used.
    ///
    /// - Attention:
    ///     If you create a `ResourceOptions` (rather than using `ResourceOptionsManager`
    ///     to manage one) that uses a custom TileStore, you will need to ensure
    ///     that the `TileStore` is initialized with a valid access token.
    ///
    ///     For example:
    ///
    ///     ```
    ///     tileStore.setOptionForKey(TileStoreOptions.mapboxAccessToken, value: accessToken)
    ///     ```
    public var tileStore: TileStore?

    /// Tile store usage mode
    public var tileStoreUsageMode: TileStoreUsageMode

    /// Initialize a `ResourceOptions`, used by both `MapView`s and `Snapshotter`s
    /// - Parameters:
    ///   - accessToken: Mapbox access token. You must provide a valid token.
    ///   - baseUrl: Base url for resource requests; default is `nil`
    ///   - dataPathURL: Path to database cache; default is `nil`, which will create
    ///         a path in a suitable application directory that is excluded from
    ///         backups.
    ///   - assetPathURL: Path to assets; default is `nil`, which will use the
    ///         application's resource bundle. `assetPath` is expected to be path
    ///         to a bundle.
    ///   - tileStore: A tile store is only used if `tileStoreEnabled` is `true`,
    ///         otherwise this argument is ignored. If `nil` (and `tileStoreEnabled`
    ///         is `true`, the a default tile store will be created and used.
    ///   - tileStoreUsageMode: Enables or disables tile store usage.
    ///
    /// - Attention:
    ///     If `tileStoreUsageMode` is `.readonly` (the default): Tile loading
    ///     first checks the tile store when requesting a tile: If a tile pack is
    ///     already loaded, the tile will be extracted and returned. Otherwise,
    ///     the implementation falls back to requesting the individual tile and
    ///     storing it in the disk cache.
    ///
    ///     If `tileStoreUsageMode` is `.readAndUpdate`: *All* tile requests are
    ///     converted to tile pack requests, i.e. the tile pack that includes the
    ///     requested tile will be loaded, and the tile extracted from it. In
    ///     this mode, no individual tile requests will be made.
    ///
    ///     This mode can be useful if the map trajectory is predefined and the
    ///     user cannot pan freely (e.g. navigation use cases), so that there is
    ///     a good chance tile packs are already loaded in the vicinity of the
    ///     user.
    ///
    ///     If users can pan freely, this mode is not recommended. Otherwise,
    ///     panning will download tile packs instead of using individual tiles.
    ///     Note that this means that we could first download an individual tile,
    ///     and then a tile pack that also includes this tile. The individual tile
    ///     in the disk cache won’t be used as long as the up-to-date tile pack
    ///     exists in the cache.
    public init(accessToken: String,
                baseURL: URL? = nil,
                dataPathURL: URL? = nil,
                assetPathURL: URL? = nil,
                tileStore: TileStore? = nil,
                tileStoreUsageMode: TileStoreUsageMode = .readOnly) {
        self.accessToken        = accessToken
        self.baseURL            = baseURL
        self.dataPathURL        = dataPathURL
        self.assetPathURL       = assetPathURL ?? Bundle.main.resourceURL
        self.tileStore          = tileStore
        self.tileStoreUsageMode = tileStoreUsageMode
    }
}

extension ResourceOptions: Hashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return (lhs.accessToken == rhs.accessToken)
            && ((lhs.baseURL == rhs.baseURL)
                    || (lhs.baseURL == nil)
                    || (rhs.baseURL == nil))
            && ((lhs.dataPathURL == rhs.dataPathURL)
                || (lhs.dataPathURL == nil)
                || (rhs.dataPathURL == nil))
            && (lhs.assetPathURL == rhs.assetPathURL)
            && ((lhs.tileStore == rhs.tileStore)
                    || (lhs.tileStore == nil)
                    || (rhs.tileStore == nil))
            && (lhs.tileStoreUsageMode == rhs.tileStoreUsageMode)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(accessToken)
        hasher.combine(baseURL)
        hasher.combine(dataPathURL)
        hasher.combine(assetPathURL)
        hasher.combine(tileStore)
        hasher.combine(tileStoreUsageMode)
    }
}

extension ResourceOptions: CustomStringConvertible, CustomDebugStringConvertible {
    private func redactedAccessToken() -> String {
        let offset = min(4, accessToken.count)
        let startIndex = accessToken.index(accessToken.startIndex, offsetBy: offset)
        let result = accessToken.replacingCharacters(in: startIndex...,
                                                     with: String(repeating: "◻︎", count: accessToken.count - offset))
        return result
    }

    public var description: String {
        return "ResourceOptions: \(redactedAccessToken())"
    }

    public var debugDescription: String {
        withUnsafePointer(to: self) {
            return "ResourceOptions @ \($0): \(redactedAccessToken())"
        }
    }
}

// MARK: - Conversion to/from internal type

extension ResourceOptions {
    internal init(_ objcValue: MapboxCoreMaps.ResourceOptions) {

        let baseURL: URL?
        if let baseURLString = objcValue.baseURL {
            baseURL = URL(string: baseURLString)
        } else {
            baseURL = nil
        }
        let dataPathURL = objcValue.dataPath.flatMap { URL(fileURLWithPath: $0) }
        let assetPathURL = objcValue.assetPath.flatMap { URL(fileURLWithPath: $0) }

        self.init(accessToken: objcValue.accessToken,
                  baseURL: baseURL,
                  dataPathURL: dataPathURL,
                  assetPathURL: assetPathURL,
                  tileStore: objcValue.tileStore,
                  tileStoreUsageMode: objcValue.tileStoreUsageMode)
    }
}

extension MapboxCoreMaps.ResourceOptions {
    internal convenience init(_ swiftValue: ResourceOptions) {
        self.init(accessToken: swiftValue.accessToken,
                  baseURL: swiftValue.baseURL?.absoluteString,
                  dataPath: swiftValue.dataPathURL?.path,
                  assetPath: swiftValue.assetPathURL?.path,
                  tileStore: swiftValue.tileStore,
                  tileStoreUsageMode: swiftValue.tileStoreUsageMode)
    }
}
