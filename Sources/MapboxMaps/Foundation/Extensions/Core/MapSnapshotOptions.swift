/// Set of options for taking map snapshot with Snapshotter.
public struct MapSnapshotOptions: Sendable {
    /// Dimensions of the snapshot in points.
    public var size: CGSize

    /// Ratio between the number device-independent and screen pixels.
    public var pixelRatio: CGFloat

    /// Glyphs rasterization options to use for client-side text rendering.
    /// By default, `GlyphsRasterizationOptions` will use `.ideographsRasterizedLocally`
    public var glyphsRasterizationOptions: GlyphsRasterizationOptions

    /// Scale factor to scale map shapshot icons and texts. Default is `1.0`.
    @_spi(Experimental)
    public var scaleFactor: CGFloat

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
    ///   - showsLogo: Flag that determines if the logo should be shown on the snapshot
    ///   - showsAttribution: Flag that determines if attribution should be shown on the snapshot
    ///   - scaleFactor: Scale factor to scale map snapshot icons and texts. Default is `1.0`.
    public init(size: CGSize,
                pixelRatio: CGFloat,
                glyphsRasterizationOptions: GlyphsRasterizationOptions = GlyphsRasterizationOptions(),
                showsLogo: Bool = true,
                showsAttribution: Bool = true,
                scaleFactor: CGFloat = 1.0) {
        precondition(pixelRatio > 0)
        precondition(scaleFactor > 0)
        precondition(size.width * pixelRatio <= 8192, "Width or scale too great.")
        precondition(size.height * pixelRatio <= 8192, "Height or scale too great.")

        self.size = size
        self.pixelRatio = pixelRatio
        self.glyphsRasterizationOptions = glyphsRasterizationOptions
        self.showsLogo = showsLogo
        self.showsAttribution = showsAttribution
        self.scaleFactor = scaleFactor
    }
}

extension MapSnapshotOptions {
    internal init(_ objcValue: CoreMapSnapshotOptions) {
        self.init(size: CGSize(objcValue.__size),
                  pixelRatio: CGFloat(objcValue.pixelRatio),
                  glyphsRasterizationOptions: objcValue.glyphsRasterizationOptions ?? GlyphsRasterizationOptions(),
                  scaleFactor: CGFloat(objcValue.__scaleFactor))
    }
}

extension CoreMapSnapshotOptions {
    internal convenience init(_ swiftValue: MapSnapshotOptions) {
        let size = swiftValue.size

        self.init(__size: Size(width: Float(size.width), height: Float(size.height)),
                  pixelRatio: Float(swiftValue.pixelRatio),
                  glyphsRasterizationOptions: swiftValue.glyphsRasterizationOptions,
                  scaleFactor: Float(swiftValue.scaleFactor))
    }
}
