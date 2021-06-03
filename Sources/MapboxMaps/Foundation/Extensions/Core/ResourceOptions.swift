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
    public var cachePathURL: URL?

    /// The path to the assets. The default, `nil`, uses the main bundle.
    public var assetPathURL: URL?

    /// The size of the cache in bytes. The default, `nil`, uses `defaultCacheSize`
    public var cacheSize: UInt64?

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
    ///     that the `TileStore` is initialised with a valid access token.
    ///
    ///     For example:
    ///
    ///     ```
    ///     tileStore.setOptionForKey(TileStoreOptions.mapboxAccessToken, value: accessToken)
    ///     ```
    public var tileStore: TileStore?

    /// Tile store usage mode
    public var tileStoreUsageMode: TileStoreUsageMode

    /// The default size of the cache. Used if `cacheSize` is set to `nil`
    public static let defaultCacheSize: UInt64 = (1024*1024*50)

    /// Initialize a `ResourceOptions`, used by both `MapView`s and `Snapshotter`s
    /// - Parameters:
    ///   - accessToken: Mapbox access token. You must provide a valid token.
    ///   - baseUrl: Base url for resource requests; default is `nil`
    ///   - cachePath: Path to database cache; default is `nil`, which will create
    ///         a path in the application's "support directory"
    ///   - assetPath: Path to assets; default is `nil`, which will use the application's
    ///         resource bundle. `assetPath` is expected to be path to a bundle.
    ///   - cacheSize: Size of the cache.
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
    ///     storing it in the ambient cache.
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
    ///     in the ambient cache won’t be used as long as the up-to-date tile pack
    ///     exists in the cache.
    public init(accessToken: String,
                baseURL: URL? = nil,
                cachePathURL: URL? = nil,
                assetPathURL: URL? = nil,
                cacheSize: UInt64 = Self.defaultCacheSize,
                tileStore: TileStore? = nil,
                tileStoreUsageMode: TileStoreUsageMode = .readOnly) {
        self.accessToken        = accessToken
        self.baseURL            = baseURL
        self.cachePathURL       = cachePathURL ?? ResourceOptions.cacheURLIncludingSubdirectory()
        self.assetPathURL       = assetPathURL ?? Bundle.main.resourceURL
        self.cacheSize          = cacheSize
        self.tileStore          = tileStore
        self.tileStoreUsageMode = tileStoreUsageMode
    }

    private static func cacheURLIncludingSubdirectory() -> URL {
        do {
            var cacheDirectoryURL = try FileManager.default.url(for: .applicationSupportDirectory,
                                                                in: .userDomainMask,
                                                                appropriateFor: nil,
                                                                create: true)

            cacheDirectoryURL = cacheDirectoryURL.appendingPathComponent(".mapbox")
            cacheDirectoryURL = cacheDirectoryURL.appendingPathComponent("maps")

            try FileManager.default.createDirectory(at: cacheDirectoryURL,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)

            cacheDirectoryURL.setTemporaryResourceValue(true, forKey: .isExcludedFromBackupKey)

            return cacheDirectoryURL.appendingPathComponent("ambient_cache.db")
        } catch {
            fatalError("Failed to create cache directory: \(error)")
        }
    }
}

extension ResourceOptions: Hashable {
    /// :nodoc:
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return (lhs.accessToken == rhs.accessToken)
            && ((lhs.baseURL == rhs.baseURL)
                    || (lhs.baseURL == nil)
                    || (rhs.baseURL == nil))
            && (lhs.cachePathURL == rhs.cachePathURL)
            && (lhs.assetPathURL == rhs.assetPathURL)
            && (lhs.cacheSize == rhs.cacheSize)
            && ((lhs.tileStore == rhs.tileStore)
                    || (lhs.tileStore == nil)
                    || (rhs.tileStore == nil))
            && (lhs.tileStoreUsageMode == rhs.tileStoreUsageMode)
    }

    /// :nodoc:
    public func hash(into hasher: inout Hasher) {
        hasher.combine(accessToken)
        hasher.combine(baseURL)
        hasher.combine(cachePathURL)
        hasher.combine(assetPathURL)
        hasher.combine(cacheSize)
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

    /// :nodoc:
    public var description: String {
        return "ResourceOptions: \(redactedAccessToken())"
    }

    /// :nodoc:
    public var debugDescription: String {
        withUnsafePointer(to: self) {
            return "ResourceOptions @ \($0): \(redactedAccessToken())"
        }
    }
}

// MARK: - Conversion to/from internal type

extension ResourceOptions {
    internal init(_ objcValue: MapboxCoreMaps.ResourceOptions) {

        let baseURL      = objcValue.baseURL.flatMap { URL(fileURLWithPath: $0) }
        let cachePathURL = objcValue.cachePath.flatMap { URL(fileURLWithPath: $0) }
        let assetPathURL = objcValue.assetPath.flatMap { URL(fileURLWithPath: $0) }

        self.init(accessToken: objcValue.accessToken,
                  baseURL: baseURL,
                  cachePathURL: cachePathURL,
                  assetPathURL: assetPathURL,
                  cacheSize: objcValue.__cacheSize?.uint64Value ?? Self.defaultCacheSize,
                  tileStore: objcValue.tileStore,
                  tileStoreUsageMode: objcValue.tileStoreUsageMode)
    }
}

extension MapboxCoreMaps.ResourceOptions {
    internal convenience init(_ swiftValue: ResourceOptions) {
        self.init(__accessToken: swiftValue.accessToken,
                  baseURL: swiftValue.baseURL?.path,
                  cachePath: swiftValue.cachePathURL?.path,
                  assetPath: swiftValue.assetPathURL?.path,
                  cacheSize: swiftValue.cacheSize?.NSNumber,
                  tileStore: swiftValue.tileStore,
                  tileStoreUsageMode: swiftValue.tileStoreUsageMode)
    }
}
