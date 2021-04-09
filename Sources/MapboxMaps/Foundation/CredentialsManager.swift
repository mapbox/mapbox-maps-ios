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
    ///
    /// This shared instance is used by the default initializers
    /// for `ResourceOptions` and `MapInitOptions`.
    ///
    /// The application's Info.plist will be searched for a valid access token
    /// under the key `MBXAccessToken`
    ///
    /// A valid access token must be provided or found.
    public static var `default` = CredentialsManager(internal: nil)

    /// Initializes a CredentialsManager with an access token.
    ///
    /// Use the shared `CredentialsManager.default` to set a globally shared
    /// access token.
    ///
    /// - Parameter accessToken: access token
    public convenience init(accessToken: String) {
        self.init(internal: accessToken)
    }

    /// Initializes a CredentialsManager with an optional access token.
    ///
    /// If the supplied token is nil (which is the case for the `default`) then
    /// we will search for an access token in the application's Info.plist.
    ///
    /// - Parameter accessToken: access token or nil
    internal init(internal accessToken: String?) {
        if let accessToken = accessToken {
            self.accessToken = accessToken
        } else {
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

extension CredentialsManager: Equatable {
    public static func == (lhs: CredentialsManager, rhs: CredentialsManager) -> Bool {
        return lhs.accessToken == rhs.accessToken
    }
}

extension CredentialsManager: CustomStringConvertible, CustomDebugStringConvertible {

    private func redactedAccessToken() -> String {
        let offset = min(4, accessToken.count)
        let startIndex = accessToken.index(accessToken.startIndex, offsetBy: offset)
        let result = accessToken.replacingCharacters(in: startIndex...,
                                                     with: String(repeating: "◻︎", count: accessToken.count - offset))
        return result
    }

    /// :nodoc:
    public var description: String {
        return "CredentialsManager: \(redactedAccessToken())"
    }

    /// :nodoc:
    public var debugDescription: String {
        let address = Unmanaged.passUnretained(self).toOpaque()
        return "CredentialsManager @ \(address): \(redactedAccessToken())"
    }
}
