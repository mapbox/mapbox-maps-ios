import Foundation

@objc public protocol MapInitOptionsDataSource {
    /// When you implement this method you should return a `MapInitOptions`.
    func mapInitOptions() -> MapInitOptions?
}

/// Options used when initializing `MapView`.
///
/// Contains the `ResourceOptions`, `MapOptions` (including `GlyphsRasterizationOptions`)
/// that are required to initialize a `MapView`.
public final class MapInitOptions: NSObject {

    /// Associated `ResourceOptions`
    public let resourceOptions: ResourceOptions

    /// Associated `MapOptions`
    public let mapOptions: MapOptions

    /// Initializer. The default initializer, i.e. `MapInitOptions()` will use
    /// the default `CredentialsManager` to use the current shared access token.
    ///
    /// - Parameters:
    ///   - resourceOptions: `ResourceOptions`; default creates an instance
    ///         using `CredentialsManager.default`
    ///   - mapOptions: `MapOptions`; see `GlyphsRasterizationOptions` for the default
    ///         used for glyph rendering.
    public init(resourceOptions: ResourceOptions = ResourceOptions(accessToken: CredentialsManager.default.accessToken ?? ""),
                mapOptions: MapOptions = MapOptions(constrainMode: .heightOnly)) {
        self.resourceOptions = resourceOptions
        self.mapOptions = mapOptions
    }

    /// :nodoc:
    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? MapInitOptions else {
            return false
        }

        return
            (resourceOptions == other.resourceOptions) &&
            (mapOptions == other.mapOptions)
    }

    /// :nodoc:
    public override var hash: Int {
        var hasher = Hasher()
        resourceOptions.hash(into: &hasher)
        mapOptions.hash(into: &hasher)
        return hasher.finalize()
    }
}
