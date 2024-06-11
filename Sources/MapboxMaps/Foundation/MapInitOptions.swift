import Foundation

/// A protocol used to provide ``MapInitOptions`` when initializing a ``MapView`` with a Storyboard or
/// a nib.
@objc public protocol MapInitOptionsProvider {
    /// A method to be called when ``MapView`` needs initialization options
    /// - Returns: Initializations options for the ``MapView``.
    func mapInitOptions() -> MapInitOptions
}

/// Options used when initializing `MapView`.
///
/// Contains the `MapOptions` (including `GlyphsRasterizationOptions`)
/// that are required to initialize a `MapView`.
public final class MapInitOptions: NSObject {

    /// Associated `MapOptions`
    public let mapOptions: MapOptions

    /// Style URI for initializing the map. Defaults to Mapbox Streets.
    public let styleURI: StyleURI?

    /// String representation of JSON style spec. Has precedence over ``styleURI``.
    public let styleJSON: String?

    /// Camera options for initializing the map. CameraOptions default to 0.0 for each value.
    public let cameraOptions: CameraOptions?

    /// Sample count to control multisample anti-aliasing (MSAA) option for rendering.
    ///
    /// Passing 4 enables MSAA x4 if it is supported. Default is 1 (MSAA turned off).
    /// - SeeAlso: [`MTKView/sampleCount`](https://developer.apple.com/documentation/metalkit/mtkview/1535991-samplecount)
    /// - SeeAlso: [`Improving edge-rendering quality with multisample antialiasing (MSAA)`](https://developer.apple.com/documentation/metal/metal_sample_code_library/improving_edge-rendering_quality_with_multisample_antialiasing_msaa)
    public let antialiasingSampleCount: Int

    /// Creates new instance of ``MapInitOptions``.
    ///
    /// - Parameters:
    ///   - mapOptions: `MapOptions`; see `GlyphsRasterizationOptions` for the default
    ///         used for glyph rendering.
    ///   - cameraOptions: `CameraOptions` to be applied to the map, overriding
    ///         the default camera that has been specified in the style.
    ///   - styleURI: Style URI for the map to load. Defaults to `.streets`, but
    ///         can be `nil`.
    ///   - styleJSON: Style JSON in String representation. Has precedence over ``styleURI``.
    ///   - antialiasingSampleCount: Sample count to control multisample anti-aliasing (MSAA) option for rendering.
    public init(
        mapOptions: MapOptions = MapOptions(),
        cameraOptions: CameraOptions? = nil,
        styleURI: StyleURI? = .standard,
        styleJSON: String? = nil,
        antialiasingSampleCount: Int = 1
    ) {
        self.mapOptions      = mapOptions
        self.cameraOptions   = cameraOptions
        self.styleURI        = styleURI
        self.styleJSON       = styleJSON
        self.antialiasingSampleCount = antialiasingSampleCount
    }

    /// :nodoc:
    /// See https://developer.apple.com/forums/thread/650054 for context
    @available(*, unavailable)
    internal override init() {
        fatalError("This initializer should not be called.")
    }

    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? MapInitOptions else {
            return false
        }

        return mapOptions == other.mapOptions &&
            cameraOptions == other.cameraOptions &&
            styleURI == other.styleURI &&
            styleJSON == other.styleJSON
    }

    public override var hash: Int {
        var hasher = Hasher()
        hasher.combine(mapOptions)
        hasher.combine(cameraOptions)
        hasher.combine(styleURI)
        hasher.combine(styleJSON)
        return hasher.finalize()
    }
}

extension MapInitOptions {
    func resolved(
        in bounds: CGRect,
        overridingStyleURI: URL?
    ) -> MapInitOptions {
        if self.mapOptions.size == nil {
            // Update using the view's size
            let resolvedMapOptions = MapOptions(
                __contextMode: mapOptions.__contextMode,
                constrainMode: mapOptions.__constrainMode,
                viewportMode: mapOptions.__viewportMode,
                orientation: mapOptions.__orientation,
                crossSourceCollisions: mapOptions.__crossSourceCollisions,
                size: Size(width: Float(bounds.width), height: Float(bounds.height)),
                pixelRatio: mapOptions.pixelRatio,
                glyphsRasterizationOptions: mapOptions.glyphsRasterizationOptions)

            // Use the overriding style URI if provided (currently from IB)
            let resolvedStyleURI = overridingStyleURI.map { StyleURI(url: $0) } ?? styleURI

            return MapInitOptions(
                mapOptions: resolvedMapOptions,
                cameraOptions: cameraOptions,
                styleURI: resolvedStyleURI,
                styleJSON: styleJSON)
        } else {
            return self
        }
    }
}
