import Foundation
@_implementationOnly import MapboxCommon_Private

/// Convenience class that manages a global `ResourceOptions`
///
/// It's possible to create `ResourceOptionsManager` instances as you need them,
/// however it's convenient to use the default object (`default`).
///
/// For example, we recommend that the Mapbox access token be set in
/// `application(_:didFinishLaunchingWithOptions:)` rather than relying on the
/// value in your application's Info.plist:
///
///     ```
///     func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
///         // Override point for customization after application launch.
///         ResourceOptionsManager.default.update { resourceOptions in
///             resourceOptions.accessToken = "overridden-access-token"
///         }
///         return true
///     }
///     ```
public class ResourceOptionsManager {

    /// Errors that can be thrown by `ResourceOptionsManager`
    public enum ResourceOptionsError: Error {
        case invalidToken
    }

    /// Default instance
    ///
    /// This shared instance is used by the default initializers
    /// for `ResourceOptions` and `MapInitOptions`.
    ///
    /// The application's Info.plist will be searched for a valid access token
    /// under the key `MBXAccessToken`
    ///
    /// A valid access token must be provided or found.
    public static var `default`: ResourceOptionsManager {
        if defaultInstance == nil {
            defaultInstance = ResourceOptionsManager(resourceOptions: nil)
        }
        return defaultInstance!
    }

    /// :nodoc:
    /// Convenience function to remove the default instance. Calling `default`
    /// again will re-create the default instance.
    internal static func destroyDefault() {
        defaultInstance = nil
    }

    private static var defaultInstance: ResourceOptionsManager?

    /// Return the current resource options. To modify the options use `update(_:)`
    public var resourceOptions: ResourceOptions {
        return _resourceOptions
    }

    private var _resourceOptions: ResourceOptions!
    private var tileStore: TileStore!
    private var bundle: Bundle

    /// Initializes a `ResourceOptionsManager` with a `ResourceOptions`
    ///
    /// If the supplied options is nil (which is the case for the `default`) then
    /// we will use appropriate defaults, including searching for an access token
    /// in the application's Info.plist.
    ///
    /// Use the shared `ResourceOptionsManager.default` to set a globally shared
    /// access token:
    ///
    ///     ```
    ///     ResourceOptionsManager.default.update { resourceOptions in
    ///         resourceOptions.accessToken = "overridden-access-token"
    ///     }
    ///     ```
    ///
    /// - Parameter resourceOptions: `ResourceOptions` or `nil`
    ///
    /// - Attention:
    ///     This initializer will set the `TileStore`'s access token if tile store
    ///     usage is enabled.
    public convenience init(resourceOptions: ResourceOptions? = nil) {
        self.init(resourceOptions: resourceOptions, for: .main)
    }

    /// Initializes a `ResourceOptionsManager` with the specified resource options
    /// and `Bundle`.
    ///
    /// - Parameters:
    ///     - resourceOptions: `ResourceOptions` or `nil`
    ///     - bundle: Bundle to search for an access token (used if resource
    ///         options is nil).
    internal init(resourceOptions: ResourceOptions?, for bundle: Bundle) {
        self.bundle = bundle
        reset(resourceOptions: resourceOptions)
    }

    /// Update the stored resource options
    /// - Parameter block: Closure called with the current resource options to
    ///     be modified.
    public func update(_ block: (inout ResourceOptions) -> Void) {
        block(&_resourceOptions)
    }

    /// Reset the manager to the specified resource options, or defaults if
    /// `nil` is supplied.
    ///
    /// - Parameter resourceOptions: `ResourceOptions` or `nil`
    /// - Attention:
    ///     This function will set the `TileStore`'s access token if tile store
    ///     usage is enabled.
    public func reset(resourceOptions: ResourceOptions? = nil) {
        let resolvedOptions = resourceOptions ?? ResourceOptions(accessToken: defaultAccessToken())
        let resolvedTileStore = resolvedOptions.tileStore ?? TileStore.default

        if resolvedOptions.tileStoreUsageMode != .disabled {
            resolvedTileStore.setAccessToken(resolvedOptions.accessToken)
        }

        self._resourceOptions = resolvedOptions
        self.tileStore = resolvedTileStore
    }

    internal func defaultAccessToken() -> String {
        // Check User defaults
        #if DEBUG
        if let accessToken = UserDefaults.standard.string(forKey: "MBXAccessToken") {
            print("Found access token from UserDefaults (command line parameter?)")
            return accessToken
        }
        #endif

        var token = ""

        // Check application plist
        if let accessToken = bundle.infoDictionary?["MBXAccessToken"] as? String {
            token = accessToken
        }
        // Check for a bundled file
        else if let url = bundle.url(forResource: "MapboxAccessToken", withExtension: nil),
                let tokenFromFile = try? String(contentsOf: url) {
            token = tokenFromFile
        }

        if token.isEmpty {
            Log.warning(forMessage: "Empty access token.", category: "ResourceOptions")
        }

        return token
    }
}

extension ResourceOptionsManager: Equatable {
    /// :nodoc:
    public static func == (lhs: ResourceOptionsManager, rhs: ResourceOptionsManager) -> Bool {
        return (lhs.resourceOptions == rhs.resourceOptions)
            && (lhs.bundle == rhs.bundle)
            && (lhs.tileStore == rhs.tileStore)
    }
}
