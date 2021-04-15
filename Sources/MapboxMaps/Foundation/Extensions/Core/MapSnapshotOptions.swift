import Foundation

extension MapSnapshotOptions {
    /// Initializes a `MapSnapshotOptions`
    /// - Parameters:
    ///   - size: Dimensions of the snapshot in points
    ///   - pixelRatio: Ratio of device-independent and screen pixels. Default
    ///         is 1.0.
    ///   - glyphsRasterizationOptions: Glyphs rasterization options to use for
    ///         client-side text rendering. Default mode is
    ///         `.ideographsRasterizedLocally`
    ///   - resourceOptions: Resource fetching options to be used by the
    ///         snapshotter. Default uses the access token provided by
    ///         `CredentialsManager.default`
    public convenience init(size: CGSize,
                            pixelRatio: Float = 1.0,
                            glyphsRasterizationOptions: GlyphsRasterizationOptions? = GlyphsRasterizationOptions(fontFamilies: []),
                            resourceOptions: ResourceOptions = ResourceOptions(accessToken: CredentialsManager.default.accessToken ?? "")) {
        self.init(__size: Size(width: Float(size.width), height: Float(size.height)),
                  pixelRatio: pixelRatio,
                  glyphsRasterizationOptions: glyphsRasterizationOptions,
                  resourceOptions: resourceOptions)
    }

    /// Dimensions of the snapshot in points
    public var size: CGSize {
        return CGSize(width: CGFloat(__size.width), height: CGFloat(__size.height))
    }
}
