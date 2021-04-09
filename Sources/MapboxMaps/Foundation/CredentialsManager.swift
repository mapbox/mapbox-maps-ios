import Foundation

/// Convenience class that holds MapboxMaps related secrets.
///
/// It's possible to create `CredentialsManager` instances as you need them,
/// however it's convenient to use the default object (`default`).
///
/// For example, we recommend that the Mapbox access token be set in
/// `application(_:didFinishLaunchingWithOptions:)` rather than relying on the
/// value in your application's Info.plist:
///
///     ```
///     func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
///         // Override point for customization after application launch.
///         CredentialsManager.default.accessToken = "overridden-access-token"
///         return true
///     }
///     ```
public class CredentialsManager {

    /// Access token
    public var accessToken: String

    /// Default instance
    public static let `default` = CredentialsManager()

    /// Initializes a CredentialsManager with an access token.
    ///
    /// If the supplied token is nil (which is the case for the `default`) then
    /// we will search for an access token in the application's Info.plist.
    ///
    /// A valid access token must be provided or found.
    ///
    /// - Parameter accessToken: access token or nil
    public init(accessToken: String? = nil) {
        if let accessToken = accessToken {
            self.accessToken = accessToken
        }
        else {
            self.accessToken = Self.defaultAccessToken() ?? ""
        }
    }

    internal static func defaultAccessToken() -> String? {
        // Check User defaults
        if let accessToken = UserDefaults.standard.string(forKey: "MBXAccessToken") {
            print("Found access token from UserDefaults (command line parameter?)")
            return accessToken
        }
        // Check application plist
        else if let accessToken = Bundle.main.infoDictionary?["MBXAccessToken"] as? String {
            return accessToken
        }

        return nil
    }
}
