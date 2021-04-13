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

    private var bundle: Bundle

    /// Backing property for accessToken
    private var _accessToken: String?

    /// Access token.
    ///
    /// This property has "null resettable" behavior; if you set `accessToken`
    /// to `nil`, we will return the application's default access token.
    public var accessToken: String! {
        get {
            return _accessToken ?? defaultAccessToken()
        }
        set {
            _accessToken = newValue
        }
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
    public private(set) static var `default` = CredentialsManager(accessToken: nil)

    /// Initializes a CredentialsManager with an access token.
    ///
    /// If the supplied token is nil (which is the case for the `default`) then
    /// we will search for an access token in the application's Info.plist.

    /// Use the shared `CredentialsManager.default` to set a globally shared
    /// access token.
    ///
    /// - Parameter accessToken: access token or nil
    public convenience init(accessToken: String?) {
        self.init(accessToken: accessToken, for: .main)
    }

    /// Initializes a CredentialsManager with an optional access token.
    ///
    /// - Parameters:
    ///     - accessToken: access token or nil
    ///     - bundle: Bundle to search for an access token (used if access token
    ///         is nil).
    internal init(accessToken: String?, for bundle: Bundle) {
        self._accessToken = accessToken
        self.bundle = bundle
    }

    internal func defaultAccessToken() -> String? {
        // Check User defaults
        #if DEBUG
        if let accessToken = UserDefaults.standard.string(forKey: "MBXAccessToken") {
            print("Found access token from UserDefaults (command line parameter?)")
            return accessToken
        }
        #endif

        // Check application plist
        if let accessToken = bundle.infoDictionary?["MBXAccessToken"] as? String {
            return accessToken
        }
        // Check for a bundled file
        else if let url = bundle.url(forResource: "MapboxAccessToken", withExtension: nil),
                let token = try? String(contentsOf: url) {
            return token
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
