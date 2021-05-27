import Foundation

extension MapSnapshotOptions {
    /// Initializes a `MapSnapshotOptions`
    /// - Parameters:
    ///   - size: Dimensions of the snapshot in points
    ///   - pixelRatio: Ratio of device-independent and screen pixels.
    ///   - glyphsRasterizationOptions: Glyphs rasterization options to use for
    ///         client-side text rendering. Default mode is
    ///         `.ideographsRasterizedLocally`
    ///   - resourceOptions: Resource fetching options to be used by the
    ///         snapshotter. Default uses the access token provided by
    ///         `ResourceOptionsManager.default`
    public convenience init(size: CGSize,
                            pixelRatio: CGFloat,
                            glyphsRasterizationOptions: GlyphsRasterizationOptions? = GlyphsRasterizationOptions(),
                            resourceOptions: ResourceOptions = ResourceOptionsManager.default.resourceOptions) {
        precondition(pixelRatio > 0)
        precondition(size.width * pixelRatio <= 8192, "Width or scale too great.")
        precondition(size.height * pixelRatio <= 8192, "Height or scale too great.")

        let coreOptions = MapboxCoreMaps.ResourceOptions(resourceOptions)

        self.init(__size: Size(width: Float(size.width), height: Float(size.height)),
                  pixelRatio: Float(pixelRatio),
                  glyphsRasterizationOptions: glyphsRasterizationOptions,
                  resourceOptions: coreOptions)
    }

    /// Dimensions of the snapshot in points
    public var size: CGSize {
        return CGSize(__size)
    }
}
