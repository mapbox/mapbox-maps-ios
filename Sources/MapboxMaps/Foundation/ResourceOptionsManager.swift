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
///         ResourceOptionsManager.default.resourceOptions.accessToken = "overridden-access-token"
///         return true
///     }
///     ```
public class ResourceOptionsManager {

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
            defaultInstance = ResourceOptionsManager(accessToken: nil)
        }
        return defaultInstance!
    }

    /// Convenience function to remove the default instance. Calling `default`
    /// again will re-create the default instance.
    public static func destroyDefault() {
        defaultInstance = nil
    }

    private static var defaultInstance: ResourceOptionsManager?

    /// Return the current resource options.
    public var resourceOptions: ResourceOptions {
        get {
            return _resourceOptions
        }
        set {
            update(newValue)
        }
    }

    private var _resourceOptions: ResourceOptions!
    private var bundle: Bundle

    /// Initializes a `ResourceOptionsManager` with an optional access token.
    ///
    /// If the supplied token is nil (which is the case for the `default`) then
    /// we will use appropriate defaults for the `ResourceOptions`, including
    /// searching for an access token in the application's Info.plist.
    ///
    /// You can override the shared global access token, using
    /// `ResourceOptionsManager.default`:
    ///
    ///     ```
    ///     ResourceOptionsManager.default.resourceOptions.accessToken = "overridden-access-token"
    ///     ```
    ///
    /// - Parameter accessToken: Valid access token or `nil`
    public convenience init(accessToken: String? = nil) {
        let resourceOptions = ResourceOptions(accessToken: accessToken ?? "")
        self.init(resourceOptions: resourceOptions)
    }

    /// Initializes a `ResourceOptionsManager` with the specified `resourceOptions`.
    ///
    /// - Parameter resourceOptions: Resource options to initialize the manager with.
    public convenience init(resourceOptions: ResourceOptions) {
        self.init(resourceOptions: resourceOptions, for: .main)
    }

    /// Initializes a `ResourceOptionsManager` with the specified access token
    /// and `Bundle`.
    ///
    /// - Parameters:
    ///     - accessToken: Valid access token or `nil`
    ///     - bundle: Bundle to search for an access token (used if resource
    ///         options is nil).
    internal init(resourceOptions: ResourceOptions, for bundle: Bundle) {
        self.bundle = bundle
        update(resourceOptions)
    }

    private func update(_ resourceOptions: ResourceOptions) {
        // Update access token
        let token = resourceOptions.accessToken.isEmpty ?
            defaultAccessToken() : resourceOptions.accessToken

        _resourceOptions = resourceOptions
        _resourceOptions.accessToken = token
    }

    private func defaultAccessToken() -> String {
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
