import Foundation
@_implementationOnly import MapboxCoreMaps_Private
@_implementationOnly import MapboxCommon_Private

/// Configurations for the external resources that are used by Maps API object,
/// such as maps data directory and base URL.
///
/// The Maps API objects include instances of Map, Snapshotter, OfflineManager and OfflineRegionManager classes.
///
/// The resource options changes are taken into consideration by the Maps API objects during their construction phase.
/// Any changes made to the resource options during runtime will not impact objects that have already been created.
///
/// Every resource option has a default value, which does not have to be overridden by the client most of the time.
/// If the default resource options need to be overridden, it is recommended to do it once at the application start and
/// before any of the Maps API objects are constructed. Although it is technically possible to run Maps API objects that use different
/// resource options, such a setup might cause performance implications.
public enum MapboxMapsOptions {

    /// The base URL that would be used by the Maps engine to make HTTP requests.
    /// By default the engine uses the base URL `https://api.mapbox.com`
    public static var baseURL: URL {
        get { URL(string: MapsResourceOptions.__getBaseURL())! }
        set { MapsResourceOptions.__setBaseURLForBaseURL(newValue.absoluteString) }
    }

    /// The path to the Maps data folder.
    ///
    /// The engine will use this folder for storing offline style packages and temporary data.
    /// The application must have sufficient permissions to create files within the provided directory. If a data path is not provided, the default location will be used.
    public static var dataPath: URL {
        get { URL(fileURLWithPath: MapsResourceOptions.__getDataPath()) }
        set { MapsResourceOptions.__setDataPathForDataPath(newValue.path) }
    }

    /// The path to the Maps asset folder. Default is application's main bundle path.
    ///
    /// The path to the folder where application assets are located. Resources whose protocol is `asset://`
    /// will be fetched from an asset folder or asset management system provided by respective platform.
    public static var assetPath: URL {
        get { URL(fileURLWithPath: MapsResourceOptions.__getAssetPath()) }
        set { MapsResourceOptions.__setAssetPathForAssetPath(newValue.path) }
    }

    /// The tile store usage mode for the Maps API objects. Default is `readOnly`.
    public static var tileStoreUsageMode: TileStoreUsageMode {
        get { MapsResourceOptions.__getTileStoreUsageMode() }
        set { MapsResourceOptions.__setTileStoreUsageModeFor(newValue) }
    }

    /// The tile store instance for the Maps API objects.
    ///
    /// This resource option is taken into consideration by the Maps API objects only if tile store usage is enabled.
    /// If `nil` is set, but``tileStoreUsageMode`` is enabled, a tile store at the default location will be created and used.
    public static var tileStore: TileStore? {
        get { MapsResourceOptions.__getTileStore() }
        set { MapsResourceOptions.__setTileStoreFor(newValue) }
    }

    /// Clears temporary map data.
    ///
    /// Clears temporary map data from the data path defined in the given resource
    /// options. Useful to reduce the disk usage or in case the disk cache contains
    /// invalid data.
    ///
    /// - Note: Calling this API will affect all maps that use the same data path
    /// and does not affect persistent map data like offline style packages.
    ///
    /// - Parameter completion: Called once the request is complete
    internal static func clearData(completion: @escaping (Error?) -> Void) {
        MapsResourceOptions.__clearData(forCallback: coreAPIClosureAdapter(for: completion, concreteErrorType: MapError.self))
    }
}
