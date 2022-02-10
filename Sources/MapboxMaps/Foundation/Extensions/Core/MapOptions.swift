extension MapOptions {
    /// Initialize a `MapOptions` object that is used when initializing a Map.
    ///
    /// For initializing a `MapView` please see `MapInitOptions`, and
    /// `MapOptions.default` for a convenient object that can be used in
    /// conjunction.
    ///
    /// - Parameters:
    ///   - constrainMode: The map constrain mode; default is `.heightOnly`.
    ///   - viewportMode: The viewport mode; default is `.default`.
    ///   - orientation: The view orientation; default is `.upwards`.
    ///   - crossSourceCollisions: Whether cross-source symbol collision detection should be enabled; default is `true`
    ///   - size: Size of the map, if nil (the default), a minimal default size will be used.
    ///   - pixelRatio: Pixel scale of the map view; default is the main screen's native scale.
    ///   - glyphsRasterizationOptions: A `GlyphsRasterizationOptions` object.
    public convenience init(constrainMode: ConstrainMode = .heightOnly,
                            viewportMode: ViewportMode = .default,
                            orientation: NorthOrientation = .upwards,
                            crossSourceCollisions: Bool = true,
                            optimizeForTerrain: Bool = true,
                            size: CGSize? = nil,
                            pixelRatio: CGFloat = UIScreen.main.nativeScale,
                            glyphsRasterizationOptions: GlyphsRasterizationOptions = GlyphsRasterizationOptions(fontFamilies: [])) {

        let mbmSize: Size?

        if let size = size {
            mbmSize = Size(width: Float(size.width), height: Float(size.height))
        } else {
            mbmSize = nil
        }

        self.init(__contextMode: nil,
                  constrainMode: constrainMode.NSNumber,
                  viewportMode: viewportMode.NSNumber,
                  orientation: orientation.NSNumber,
                  crossSourceCollisions: crossSourceCollisions.NSNumber,
                  optimizeForTerrain: optimizeForTerrain.NSNumber,
                  size: mbmSize,
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

    /// With terrain on, if `true`, the map will render for performance priority,
    /// which may lead to layer reordering allowing to maximize performance
    /// (layers that are draped over terrain will be drawn first, including fill,
    /// line, background, hillshade and raster). Any layers that are positioned
    /// after symbols are draped last, over symbols. Otherwise, if set to `false`,
    /// the map will always be drawn for layer order priority.
    ///
    /// By default, it is set to true.
    public var optimizeForTerrain: Bool {
        return __optimizeForTerrain?.boolValue ?? true
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

    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? MapOptions else {
            return false
        }

        guard type(of: self) == type(of: other) else {
            return false
        }

        return
            (constrainMode == other.constrainMode) &&
            (viewportMode == other.viewportMode) &&
            (orientation == other.orientation) &&
            (crossSourceCollisions == other.crossSourceCollisions) &&
            (size == other.size) &&
            (pixelRatio == other.pixelRatio) &&
            (glyphsRasterizationOptions == other.glyphsRasterizationOptions)
    }

    open override var hash: Int {
        var hasher = Hasher()
        hasher.combine(constrainMode)
        hasher.combine(viewportMode)
        hasher.combine(orientation)
        hasher.combine(crossSourceCollisions)
        hasher.combine(pixelRatio)
        hasher.combine(glyphsRasterizationOptions)
        return hasher.finalize()
    }
}
