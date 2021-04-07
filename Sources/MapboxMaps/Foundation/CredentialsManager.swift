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
    public var accessToken: String {
        didSet {
            precondition(accessToken.count > 0)
        }
    }

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
        else if let accessToken = Self.defaultAccessToken() {
            self.accessToken = accessToken
        }
        else {
            fatalError("No valid access token found")
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

extension NSNumber {
    // Useful for converting between NSNumbers and Core enums
    internal func intValueAsRawRepresentable<T>() -> T? where
        T: RawRepresentable,
        T.RawValue == Int {
        return T(rawValue: intValue)
    }
}

extension RawRepresentable where Self.RawValue == Int {
    internal var number: NSNumber {
        NSNumber(value: rawValue)
    }
}

extension Bool {
    internal var number: NSNumber {
        NSNumber(value: self)
    }
}

extension CGSize {
    internal var mbmSize: Size {
        return Size(width: Float(width), height: Float(height))
    }
}

extension MapboxCoreMaps.MapOptions {
    /// TODO: docs
    public convenience init(//contextMode: ContextMode? = nil,
                            //constrainMode: ConstrainMode? = nil,
                            //viewportMode: ViewportMode? = nil,
                            //orientation: NorthOrientation? = nil,
                            crossSourceCollisions: Bool = true,
                            size: CGSize?,
                            pixelRatio: CGFloat,
                            glyphsRasterizationOptions: GlyphsRasterizationOptions) {

        self.init(__contextMode: nil, //contextMode?.number,
                  constrainMode: nil, //constrainMode?.number,
                  viewportMode: nil, //viewportMode?.number,
                  orientation: nil, //orientation?.number,
                  crossSourceCollisions: crossSourceCollisions.number,
                  size: size?.mbmSize,
                  pixelRatio: Float(pixelRatio),
                  glyphsRasterizationOptions: glyphsRasterizationOptions)
    }

    /// The map context mode. This can be used for optimizations, if we know
    /// that the drawing context is not shared with other code.

    // TODO: Is this valid for metal??
    internal var contextMode: ContextMode? {
        return __contextMode?.intValueAsRawRepresentable()
    }

    /// The map constrain mode. This can be used to limit the map to wrap around
    /// the globe horizontally. Defaults to `.heightOnly`.
    internal var constrainMode: ConstrainMode {
        return __constrainMode?.intValueAsRawRepresentable() ?? .heightOnly
    }

    /// The viewport mode. This can be used to flip the vertical orientation of
    /// the map as some devices may use inverted orientation.
    internal var viewportMode: ViewportMode? {
        return __viewportMode?.intValueAsRawRepresentable()
    }

    /// The orientation of the Map. Defaults to `.upwards`.
    internal var orientation: NorthOrientation {
        return __orientation?.intValueAsRawRepresentable() ?? .upwards
    }

    /// Specifies whether cross-source symbol collision detection should be
    /// enabled. Defaults to true.
    public var crossSourceCollisions: Bool {
        return __crossSourceCollisions?.boolValue ?? true
    }

    /// The size of the map object and renderer backend. For Apple platforms this
    /// is specified with points (or device-independent pixel units). Other
    /// platforms, such as Android, use screen pixel units.
    ///
    /// For MapView usage, this can be left as nil, since view resizing will
    /// ensure the correct size is updated.
    public var size: CGSize? {
        guard let size = __size else {
            return nil
        }

        return CGSize(width: Double(size.width), height: Double(size.height))
    }

    /// A default MapOptions that uses the main screen's scale, and default
    /// `GlyphsRasterizationOptions`.
    public static let `default` = MapboxCoreMaps.MapOptions(size: nil,
                                                            pixelRatio: UIScreen.main.scale,
                                                            glyphsRasterizationOptions: GlyphsRasterizationOptions.default)
}

extension ResourceOptions {
    public static let `default` = ResourceOptions(accessToken: CredentialsManager.default.accessToken)
}

public struct MapboxOptions {
    public let resourceOptions: ResourceOptions
    public let mapOptions: MapboxCoreMaps.MapOptions
    public let renderOptions: RenderOptions

    // Maybe?
    /*
    public init(credentialsManager: CredentialsManager = CredentialsManager.default,
                renderOptions: RenderOptions = RenderOptions()) {

        let resourceOptions = ResourceOptions(accessToken: credentialsManager.accessToken)
        let mapOptions = MapboxCoreMaps.MapOptions(size: nil,
                                                   pixelRatio: UIScreen.main.scale,
                                                   glyphsRasterizationOptions: GlyphsRasterizationOptions.default)

        self.init(resourceOptions: resourceOptions,
                  mapOptions: mapOptions,
                  renderOptions: renderOptions)
    }

    public init(resourceOptions: ResourceOptions,
                mapOptions: MapboxCoreMaps.MapOptions,
                renderOptions: RenderOptions) {
        self.resourceOptions = resourceOptions
        self.mapOptions = mapOptions
        self.renderOptions = renderOptions
    }
 */

    // Or
    public init(resourceOptions: ResourceOptions = ResourceOptions.default,
                mapOptions: MapboxCoreMaps.MapOptions = MapboxCoreMaps.MapOptions.default,
                renderOptions: RenderOptions = RenderOptions()) {
        self.resourceOptions = resourceOptions
        self.mapOptions = mapOptions
        self.renderOptions = renderOptions
    }


}
