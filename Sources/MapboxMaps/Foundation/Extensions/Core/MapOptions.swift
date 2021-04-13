extension MapboxCoreMaps.MapOptions {
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
    ///   - pixelRatio: Pixel scale of the map view; default is thee main screen's scale.
    ///   - glyphsRasterizationOptions: A `GlyphsRasterizationOptions` object.
    public convenience init(constrainMode: ConstrainMode = .heightOnly,
                            viewportMode: ViewportMode = .default,
                            orientation: NorthOrientation = .upwards,
                            crossSourceCollisions: Bool = true,
                            size: CGSize? = nil,
                            pixelRatio: CGFloat = UIScreen.main.scale,
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

    /// :nodoc:
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

    /// :nodoc:
    open override var hash: Int {
        var hasher = Hasher()
        constrainMode.hash(into: &hasher)
        viewportMode.hash(into: &hasher)
        orientation.hash(into: &hasher)
        crossSourceCollisions.hash(into: &hasher)
        pixelRatio.hash(into: &hasher)
        glyphsRasterizationOptions.hash(into: &hasher)
        return hasher.finalize()
    }
}
