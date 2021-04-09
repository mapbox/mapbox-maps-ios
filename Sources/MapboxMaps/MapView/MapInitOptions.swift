import Foundation

@objc public protocol MapInitOptionsDataSource {
    /// When you implement this method you should return a `MapInitOptions`.
    func mapInitOptions() -> Any
}

/// Options used when initializing `MapView`.
///
/// Contains the `ResourceOptions`, `MapOptions` (including `GlyphsRasterizationOptions`)
/// that are required to initialize a `MapView`.
public struct MapInitOptions: Equatable {

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
    public init(resourceOptions: ResourceOptions = ResourceOptions(accessToken: CredentialsManager.default.accessToken),
                mapOptions: MapOptions = MapOptions()) {
        self.resourceOptions = resourceOptions
        self.mapOptions = mapOptions
    }
}
