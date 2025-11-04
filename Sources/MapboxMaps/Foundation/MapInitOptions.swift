import Foundation
@_implementationOnly import MapboxCoreMaps_Private

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

    /// Style URI for initializing the map. Defaults to Mapbox Standard.
    public var styleURI: StyleURI? { mapStyle?.data.asURI }

    /// String representation of JSON style spec. Has precedence over ``styleURI``.
    public var styleJSON: String? { mapStyle?.data.asJson }

    /// Map style for map initialization.
    public let mapStyle: MapStyle?

    /// Camera options for initializing the map. CameraOptions default to 0.0 for each value.
    public let cameraOptions: CameraOptions?

    /// Sample count to control multisample anti-aliasing (MSAA) option for rendering.
    ///
    /// Passing 4 enables MSAA x4 if it is supported. Default is 1 (MSAA turned off).
    /// - SeeAlso: [`MTKView/sampleCount`](https://developer.apple.com/documentation/metalkit/mtkview/1535991-samplecount)
    /// - SeeAlso: [`Improving edge-rendering quality with multisample antialiasing (MSAA)`](https://developer.apple.com/documentation/metal/metal_sample_code_library/improving_edge-rendering_quality_with_multisample_antialiasing_msaa)
    public let antialiasingSampleCount: Int

    public let locationDataModel: LocationDataModel?

    /// Creates new instance of ``MapInitOptions``.
    ///
    /// - Parameters:
    ///   - mapOptions: `MapOptions`; see `GlyphsRasterizationOptions` for the default
    ///         used for glyph rendering.
    ///   - cameraOptions: `CameraOptions` to be applied to the map, overriding
    ///         the default camera that has been specified in the style.
    ///   - styleURI: Style URI for the map to load. Defaults to `.standard`, but
    ///         can be `nil`.
    ///   - styleJSON: Style JSON in String representation. Has precedence over ``styleURI``.
    ///   - antialiasingSampleCount: Sample count to control multisample anti-aliasing (MSAA) option for rendering.
    convenience public init(
        mapOptions: MapOptions = MapOptions(),
        cameraOptions: CameraOptions? = nil,
        styleURI: StyleURI? = .standard,
        styleJSON: String? = nil,
        antialiasingSampleCount: Int = 1,
        locationDataModel: LocationDataModel? = nil
    ) {
        let mapStyle: MapStyle? = if let styleJSON {
            MapStyle(json: styleJSON)
        } else if let styleURI {
            MapStyle(uri: styleURI)
        } else {
            nil
        }
        self.init(mapStyle: mapStyle,
                  mapOptions: mapOptions,
                  cameraOptions: cameraOptions,
                  antialiasingSampleCount: antialiasingSampleCount,
                  locationDataModel: locationDataModel)
    }

    /// Creates new map init options.
    ///
    /// - Parameters:
    ///   - mapStyle:  Map style to load, defaults to Mapbox Standard style.
    ///   - mapOptions: Map rendering options.
    ///   - cameraOptions:  Camera options overriding the default camera that has been specified in the style.
    ///   - antialiasingSampleCount: Sample count to control multisample anti-aliasing (MSAA) option for rendering.
    public init(
        mapStyle: MapStyle?,
        mapOptions: MapOptions = MapOptions(),
        cameraOptions: CameraOptions? = nil,
        antialiasingSampleCount: Int = 1,
        locationDataModel: LocationDataModel? = nil
    ) {
        self.mapOptions = mapOptions
        self.cameraOptions = cameraOptions
        self.mapStyle = mapStyle
        self.antialiasingSampleCount = antialiasingSampleCount
        self.locationDataModel = locationDataModel
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
                glyphsRasterizationOptions: mapOptions.glyphsRasterizationOptions,
                scaleFactor: mapOptions.__scaleFactor)

            // Use the overriding style URI if provided (currently from IB)
            let resolvedStyle = if let overridingStyleURI,
                                   let uri = StyleURI(url: overridingStyleURI) {
                MapStyle(uri: uri)
            } else {
                mapStyle
            }

            return MapInitOptions(
                mapStyle: resolvedStyle,
                mapOptions: resolvedMapOptions,
                cameraOptions: cameraOptions,
                locationDataModel: locationDataModel)
        } else {
            return self
        }
    }
}
