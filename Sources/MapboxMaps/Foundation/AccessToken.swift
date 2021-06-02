@_implementationOnly import MapboxCommon_Private

/// Type that represents a Mapbox access token.
///
/// You can initialize this type with a string, for example:
///
///     `let token: AccessToken = "pk.mysecretaccesstoken"`
///
public enum AccessToken: ExpressibleByStringLiteral, CustomStringConvertible, CustomDebugStringConvertible, CustomReflectable, Hashable {
    /// :nodoc:
    public typealias StringLiteralType = String

    /// Case used when you have an existing access token string
    case tokenString(String)

    /// Used when you want the SDK to search the associated bundle for an access
    /// token
    case `default`(_ bundle: Bundle = .main)

    /// Convenience to initialize the enum with a string token
    public init(stringLiteral value: Self.StringLiteralType) {
        self = .tokenString(value)
    }

    /// :nodoc:
    public var description: String {
        switch self {
        case let .tokenString(token):
            return "\(token.redacted())"
        case .default:
            return ".default"
        }
    }

    /// :nodoc:
    public var debugDescription: String {
        return "AccessToken: \(description)"
    }

    /// :nodoc:
    public var customMirror: Mirror {
        return Mirror(reflecting: "")
    }

    internal var token: String {
        switch self {
        case let .tokenString(token):
            return token
        case let .default(bundle):
            return AccessToken.defaultToken(with: bundle)
        }
    }

    internal static func defaultToken(with bundle: Bundle) -> String {
        // Check User defaults. This is for development only
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

        token = token.trimmingCharacters(in: .whitespacesAndNewlines)

        if token.isEmpty {
            // You must provide a valid access token
            Log.error(forMessage: "Please provide a valid access token.", category: "ResourceOptions")
        }

        return token
    }

    /// :nodoc:
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (let .default(bundle1), let .default(bundle2)):
            return bundle1 == bundle2

        case (.default, let .tokenString(token)):
            return lhs.token == token

        case (let .tokenString(token), .default):
            return token == rhs.token

        case (let .tokenString(token1), let .tokenString(token2)):
            return token1 == token2
        }
    }
}
