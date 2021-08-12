/// Set of options for taking map snapshot with Snapshotter.
public struct MapSnapshotOptions {
    /// Dimensions of the snapshot in points.
    public var size: CGSize

    /// Ratio between the number device-independent and screen pixels.
    public var pixelRatio: CGFloat

    /// Glyphs rasterization options to use for client-side text rendering.
    /// By default, `GlyphsRasterizationOptions` will use `.ideographsRasterizedLocally`
    public var glyphsRasterizationOptions: GlyphsRasterizationOptions

    /// Resource fetching options to be used by the snapshotter.
    public var resourceOptions: ResourceOptions

    /// Flag that determines if the logo should be shown on the snapshot
    public var showsLogo: Bool

    /// Flag that determines if attribution should be shown on the snapshot
    public var showsAttribution: Bool

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
    ///   - showsLogo: Flag that determines if the logo should be shown on the snapshot
    ///   - showsAttribution: Flag that determines if attribution should be shown on the snapshot
    public init(size: CGSize,
                pixelRatio: CGFloat,
                glyphsRasterizationOptions: GlyphsRasterizationOptions = GlyphsRasterizationOptions(),
                resourceOptions: ResourceOptions = ResourceOptionsManager.default.resourceOptions,
                showsLogo: Bool = true,
                showsAttribution: Bool = true) {
        precondition(pixelRatio > 0)
        precondition(size.width * pixelRatio <= 8192, "Width or scale too great.")
        precondition(size.height * pixelRatio <= 8192, "Height or scale too great.")

        self.size = size
        self.pixelRatio = pixelRatio
        self.glyphsRasterizationOptions = glyphsRasterizationOptions
        self.resourceOptions = resourceOptions
        self.showsLogo = showsLogo
        self.showsAttribution = showsAttribution
    }
}

extension MapSnapshotOptions {
    internal init(_ objcValue: MapboxCoreMaps.MapSnapshotOptions) {
        self.init(size: CGSize(objcValue.__size),
                  pixelRatio: CGFloat(objcValue.pixelRatio),
                  glyphsRasterizationOptions: objcValue.glyphsRasterizationOptions ?? GlyphsRasterizationOptions(),
                  resourceOptions: ResourceOptions(objcValue.resourceOptions))
    }
}

extension MapboxCoreMaps.MapSnapshotOptions {
    internal convenience init(_ swiftValue: MapSnapshotOptions) {
        let size = swiftValue.size
        let coreOptions = MapboxCoreMaps.ResourceOptions(swiftValue.resourceOptions)

        self.init(__size: Size(width: Float(size.width), height: Float(size.height)),
                  pixelRatio: Float(swiftValue.pixelRatio),
                  glyphsRasterizationOptions: swiftValue.glyphsRasterizationOptions,
                  resourceOptions: coreOptions)
    }
}
