import MapboxCoreMaps

extension MapboxCoreMaps.MapOptions {
    /// Initialize a `MapOptions` object that is used when initializing a Map.
    ///
    /// For initializing a `MapView` please see `MapInitOptions`, and
    /// `MapOptions.default` for a convenient object that can be used in
    /// conjunction.
    ///
    /// - Parameters:
    ///   - constrainMode: The map constrain mode, defaults to `.heightOnly`.
    ///   - viewportMode: The viewport mode, defaults to `.default`.
    ///   - orientation: The view orientation, defaults to North pointing `.upwards`.
    ///   - crossSourceCollisions: Whether cross-source symbol collision detection should be enabled.
    ///   - size: Size of the map, if nil, a default size will be used.
    ///   - pixelRatio: Pixel scale of the map view; typically this should.
    ///   - glyphsRasterizationOptions: A `GlyphsRasterizationOptions` object.
    public convenience init(constrainMode: ConstrainMode = .heightOnly,
                            viewportMode: ViewportMode = .default,
                            orientation: NorthOrientation = .upwards,
                            crossSourceCollisions: Bool = true,
                            size: CGSize?,
                            pixelRatio: CGFloat,
                            glyphsRasterizationOptions: GlyphsRasterizationOptions) {

        self.init(__contextMode: nil,
                  constrainMode: constrainMode.NSNumber,
                  viewportMode: viewportMode.NSNumber,
                  orientation: orientation.NSNumber,
                  crossSourceCollisions: crossSourceCollisions.NSNumber,
                  size: size?.mbmSize,
                  pixelRatio: Float(pixelRatio),
                  glyphsRasterizationOptions: glyphsRasterizationOptions)
    }

    /// The map constrain mode. This can be used to limit the map to wrap around
    /// the globe horizontally. Default is `.heightOnly`.
    internal var constrainMode: ConstrainMode {
        return __constrainMode?.intValueAsRawRepresentable() ?? .heightOnly
    }

    /// The viewport mode. This can be used to flip the vertical orientation of
    /// the map as some devices may use inverted orientation.
    internal var viewportMode: ViewportMode? {
        return __viewportMode?.intValueAsRawRepresentable()
    }

    /// The orientation of the Map. Default is `.upwards`.
    internal var orientation: NorthOrientation {
        return __orientation?.intValueAsRawRepresentable() ?? .upwards
    }

    /// Specifies whether cross-source symbol collision detection should be
    /// enabled. Default is `true`.
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
