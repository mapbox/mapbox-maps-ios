// This file is generated.
import Foundation

public enum Visibility: String, Codable, Sendable {
    /// The layer is visible.
    case visible = "visible"

    /// The layer is hidden.
    case none = "none"
}

/// Selects the base of fill-elevation. Some modes might require precomputed elevation data in the tileset.
@_documentation(visibility: public)
@_spi(Experimental)
public struct FillElevationReference: RawRepresentable, Codable, Hashable, Sendable {
    @_documentation(visibility: public)
    public let rawValue: String

    @_documentation(visibility: public)
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Elevated rendering is disabled.
    @_documentation(visibility: public)
    public static let none = FillElevationReference(rawValue: "none")

    /// Elevate geometry relative to HD roads. Use this mode to describe base polygons of the road networks.
    @_documentation(visibility: public)
    public static let hdRoadBase = FillElevationReference(rawValue: "hd-road-base")

    /// Elevated rendering is enabled. Use this mode to describe additive and stackable features such as 'hatched areas' that should exist only on top of road polygons.
    @_documentation(visibility: public)
    public static let hdRoadMarkup = FillElevationReference(rawValue: "hd-road-markup")
}

/// The display of line endings.
public struct LineCap: RawRepresentable, Codable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// A cap with a squared-off end which is drawn to the exact endpoint of the line.
    public static let butt = LineCap(rawValue: "butt")

    /// A cap with a rounded end which is drawn beyond the endpoint of the line at a radius of one-half of the line's width and centered on the endpoint of the line.
    public static let round = LineCap(rawValue: "round")

    /// A cap with a squared-off end which is drawn beyond the endpoint of the line at a distance of one-half of the line's width.
    public static let square = LineCap(rawValue: "square")
}

/// Selects the base of line-elevation. Some modes might require precomputed elevation data in the tileset.
@_documentation(visibility: public)
@_spi(Experimental)
public struct LineElevationReference: RawRepresentable, Codable, Hashable, Sendable {
    @_documentation(visibility: public)
    public let rawValue: String

    @_documentation(visibility: public)
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Elevated rendering is disabled.
    @_documentation(visibility: public)
    public static let none = LineElevationReference(rawValue: "none")

    /// Elevated rendering is enabled. Use this mode to elevate lines relative to the sea level.
    @_documentation(visibility: public)
    public static let sea = LineElevationReference(rawValue: "sea")

    /// Elevated rendering is enabled. Use this mode to elevate lines relative to the ground's height below them.
    @_documentation(visibility: public)
    public static let ground = LineElevationReference(rawValue: "ground")

    /// Elevated rendering is enabled. Use this mode to describe additive and stackable features that should exist only on top of road polygons.
    @_documentation(visibility: public)
    public static let hdRoadMarkup = LineElevationReference(rawValue: "hd-road-markup")
}

/// The display of lines when joining.
public struct LineJoin: RawRepresentable, Codable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// A join with a squared-off end which is drawn beyond the endpoint of the line at a distance of one-half of the line's width.
    public static let bevel = LineJoin(rawValue: "bevel")

    /// A join with a rounded end which is drawn beyond the endpoint of the line at a radius of one-half of the line's width and centered on the endpoint of the line.
    public static let round = LineJoin(rawValue: "round")

    /// A join with a sharp, angled corner which is drawn with the outer sides beyond the endpoint of the path until they meet.
    public static let miter = LineJoin(rawValue: "miter")

    /// Line segments are not joined together, each one creates a separate line. Useful in combination with line-pattern. Line-cap property is not respected. Can't be used with data-driven styling.
    public static let none = LineJoin(rawValue: "none")
}

/// Selects the unit of line-width. The same unit is automatically used for line-blur and line-offset. Note: This is an experimental property and might be removed in a future release.
@_documentation(visibility: public)
@_spi(Experimental)
public struct LineWidthUnit: RawRepresentable, Codable, Hashable, Sendable {
    @_documentation(visibility: public)
    public let rawValue: String

    @_documentation(visibility: public)
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Width is rendered in pixels.
    @_documentation(visibility: public)
    public static let pixels = LineWidthUnit(rawValue: "pixels")

    /// Width is rendered in meters.
    @_documentation(visibility: public)
    public static let meters = LineWidthUnit(rawValue: "meters")
}

/// Part of the icon placed closest to the anchor.
public struct IconAnchor: RawRepresentable, Codable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// The center of the icon is placed closest to the anchor.
    public static let center = IconAnchor(rawValue: "center")

    /// The left side of the icon is placed closest to the anchor.
    public static let left = IconAnchor(rawValue: "left")

    /// The right side of the icon is placed closest to the anchor.
    public static let right = IconAnchor(rawValue: "right")

    /// The top of the icon is placed closest to the anchor.
    public static let top = IconAnchor(rawValue: "top")

    /// The bottom of the icon is placed closest to the anchor.
    public static let bottom = IconAnchor(rawValue: "bottom")

    /// The top left corner of the icon is placed closest to the anchor.
    public static let topLeft = IconAnchor(rawValue: "top-left")

    /// The top right corner of the icon is placed closest to the anchor.
    public static let topRight = IconAnchor(rawValue: "top-right")

    /// The bottom left corner of the icon is placed closest to the anchor.
    public static let bottomLeft = IconAnchor(rawValue: "bottom-left")

    /// The bottom right corner of the icon is placed closest to the anchor.
    public static let bottomRight = IconAnchor(rawValue: "bottom-right")
}

/// Orientation of icon when map is pitched.
public struct IconPitchAlignment: RawRepresentable, Codable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// The icon is aligned to the plane of the map.
    public static let map = IconPitchAlignment(rawValue: "map")

    /// The icon is aligned to the plane of the viewport.
    public static let viewport = IconPitchAlignment(rawValue: "viewport")

    /// Automatically matches the value of ``IconRotationAlignment``.
    public static let auto = IconPitchAlignment(rawValue: "auto")
}

/// In combination with `symbol-placement`, determines the rotation behavior of icons.
public struct IconRotationAlignment: RawRepresentable, Codable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// When ``SymbolPlacement`` is set to ``SymbolPlacement/point``, aligns icons east-west. When ``SymbolPlacement`` is set to ``SymbolPlacement/line`` or ``SymbolPlacement/lineCenter`` aligns icon x-axes with the line.
    public static let map = IconRotationAlignment(rawValue: "map")

    /// Produces icons whose x-axes are aligned with the x-axis of the viewport, regardless of the value of ``SymbolPlacement``.
    public static let viewport = IconRotationAlignment(rawValue: "viewport")

    /// When ``SymbolPlacement`` is set to ``SymbolPlacement/point``, this is equivalent to ``IconRotationAlignment/viewport``. When ``SymbolPlacement`` is set to ``SymbolPlacement/line`` or ``SymbolPlacement/lineCenter`` this is equivalent to ``IconRotationAlignment/map``.
    public static let auto = IconRotationAlignment(rawValue: "auto")
}

/// Scales the icon to fit around the associated text.
public struct IconTextFit: RawRepresentable, Codable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// The icon is displayed at its intrinsic aspect ratio.
    public static let none = IconTextFit(rawValue: "none")

    /// The icon is scaled in the x-dimension to fit the width of the text.
    public static let width = IconTextFit(rawValue: "width")

    /// The icon is scaled in the y-dimension to fit the height of the text.
    public static let height = IconTextFit(rawValue: "height")

    /// The icon is scaled in both x- and y-dimensions.
    public static let both = IconTextFit(rawValue: "both")
}

/// Selects the base of symbol-elevation.
@_documentation(visibility: public)
@_spi(Experimental)
public struct SymbolElevationReference: RawRepresentable, Codable, Hashable, Sendable {
    @_documentation(visibility: public)
    public let rawValue: String

    @_documentation(visibility: public)
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Elevate symbols relative to the sea level.
    @_documentation(visibility: public)
    public static let sea = SymbolElevationReference(rawValue: "sea")

    /// Elevate symbols relative to the ground's height below them.
    @_documentation(visibility: public)
    public static let ground = SymbolElevationReference(rawValue: "ground")

    /// Use this mode to enable elevated behavior for features that are rendered on top of 3D road polygons. The feature is currently being developed.
    @_documentation(visibility: public)
    public static let hdRoadMarkup = SymbolElevationReference(rawValue: "hd-road-markup")
}

/// Label placement relative to its geometry.
public struct SymbolPlacement: RawRepresentable, Codable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// The label is placed at the point where the geometry is located.
    public static let point = SymbolPlacement(rawValue: "point")

    /// The label is placed along the line of the geometry. Can only be used on `LineString` and `Polygon` geometries.
    public static let line = SymbolPlacement(rawValue: "line")

    /// The label is placed at the center of the line of the geometry. Can only be used on `LineString` and `Polygon` geometries. Note that a single feature in a vector tile may contain multiple line geometries.
    public static let lineCenter = SymbolPlacement(rawValue: "line-center")
}

/// Determines whether overlapping symbols in the same layer are rendered in the order that they appear in the data source or by their y-position relative to the viewport. To control the order and prioritization of symbols otherwise, use `symbol-sort-key`.
public struct SymbolZOrder: RawRepresentable, Codable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Sorts symbols by `symbol-sort-key` if set. Otherwise, sorts symbols by their y-position relative to the viewport if `icon-allow-overlap` or `text-allow-overlap` is set to `true` or `icon-ignore-placement` or `text-ignore-placement` is `false`.
    public static let auto = SymbolZOrder(rawValue: "auto")

    /// Sorts symbols by their y-position relative to the viewport if any of the following is set to `true`: `icon-allow-overlap`, `text-allow-overlap`, `icon-ignore-placement`, `text-ignore-placement`.
    public static let viewportY = SymbolZOrder(rawValue: "viewport-y")

    /// Sorts symbols by `symbol-sort-key` if set. Otherwise, no sorting is applied; symbols are rendered in the same order as the source data.
    public static let source = SymbolZOrder(rawValue: "source")
}

/// Part of the text placed closest to the anchor.
public struct TextAnchor: RawRepresentable, Codable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// The center of the text is placed closest to the anchor.
    public static let center = TextAnchor(rawValue: "center")

    /// The left side of the text is placed closest to the anchor.
    public static let left = TextAnchor(rawValue: "left")

    /// The right side of the text is placed closest to the anchor.
    public static let right = TextAnchor(rawValue: "right")

    /// The top of the text is placed closest to the anchor.
    public static let top = TextAnchor(rawValue: "top")

    /// The bottom of the text is placed closest to the anchor.
    public static let bottom = TextAnchor(rawValue: "bottom")

    /// The top left corner of the text is placed closest to the anchor.
    public static let topLeft = TextAnchor(rawValue: "top-left")

    /// The top right corner of the text is placed closest to the anchor.
    public static let topRight = TextAnchor(rawValue: "top-right")

    /// The bottom left corner of the text is placed closest to the anchor.
    public static let bottomLeft = TextAnchor(rawValue: "bottom-left")

    /// The bottom right corner of the text is placed closest to the anchor.
    public static let bottomRight = TextAnchor(rawValue: "bottom-right")
}

/// Text justification options.
public struct TextJustify: RawRepresentable, Codable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// The text is aligned towards the anchor position.
    public static let auto = TextJustify(rawValue: "auto")

    /// The text is aligned to the left.
    public static let left = TextJustify(rawValue: "left")

    /// The text is centered.
    public static let center = TextJustify(rawValue: "center")

    /// The text is aligned to the right.
    public static let right = TextJustify(rawValue: "right")
}

/// Orientation of text when map is pitched.
public struct TextPitchAlignment: RawRepresentable, Codable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// The text is aligned to the plane of the map.
    public static let map = TextPitchAlignment(rawValue: "map")

    /// The text is aligned to the plane of the viewport.
    public static let viewport = TextPitchAlignment(rawValue: "viewport")

    /// Automatically matches the value of ``TextRotationAlignment``.
    public static let auto = TextPitchAlignment(rawValue: "auto")
}

/// In combination with `symbol-placement`, determines the rotation behavior of the individual glyphs forming the text.
public struct TextRotationAlignment: RawRepresentable, Codable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// When ``SymbolPlacement`` is set to ``SymbolPlacement/point``, aligns text east-west. When ``SymbolPlacement`` is set to ``SymbolPlacement/line`` or ``SymbolPlacement/lineCenter`` aligns text x-axes with the line.
    public static let map = TextRotationAlignment(rawValue: "map")

    /// Produces glyphs whose x-axes are aligned with the x-axis of the viewport, regardless of the value of ``SymbolPlacement``.
    public static let viewport = TextRotationAlignment(rawValue: "viewport")

    /// When ``SymbolPlacement`` is set to ``SymbolPlacement/point``, this is equivalent to ``TextRotationAlignment/viewport``. When ``SymbolPlacement`` is set to ``SymbolPlacement/line`` or ``SymbolPlacement/lineCenter`` this is equivalent to ``TextRotationAlignment/map``.
    public static let auto = TextRotationAlignment(rawValue: "auto")
}

/// Specifies how to capitalize text, similar to the CSS `text-transform` property.
public struct TextTransform: RawRepresentable, Codable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// The text is not altered.
    public static let none = TextTransform(rawValue: "none")

    /// Forces all letters to be displayed in uppercase.
    public static let uppercase = TextTransform(rawValue: "uppercase")

    /// Forces all letters to be displayed in lowercase.
    public static let lowercase = TextTransform(rawValue: "lowercase")
}

/// Controls the frame of reference for `fill-translate`.
public struct FillTranslateAnchor: RawRepresentable, Codable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// The fill is translated relative to the map.
    public static let map = FillTranslateAnchor(rawValue: "map")

    /// The fill is translated relative to the viewport.
    public static let viewport = FillTranslateAnchor(rawValue: "viewport")
}

/// Controls the frame of reference for `line-translate`.
public struct LineTranslateAnchor: RawRepresentable, Codable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// The line is translated relative to the map.
    public static let map = LineTranslateAnchor(rawValue: "map")

    /// The line is translated relative to the viewport.
    public static let viewport = LineTranslateAnchor(rawValue: "viewport")
}

/// Controls the frame of reference for `icon-translate`.
public struct IconTranslateAnchor: RawRepresentable, Codable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Icons are translated relative to the map.
    public static let map = IconTranslateAnchor(rawValue: "map")

    /// Icons are translated relative to the viewport.
    public static let viewport = IconTranslateAnchor(rawValue: "viewport")
}

/// Controls the frame of reference for `text-translate`.
public struct TextTranslateAnchor: RawRepresentable, Codable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// The text is translated relative to the map.
    public static let map = TextTranslateAnchor(rawValue: "map")

    /// The text is translated relative to the viewport.
    public static let viewport = TextTranslateAnchor(rawValue: "viewport")
}

/// Orientation of circle when map is pitched.
public struct CirclePitchAlignment: RawRepresentable, Codable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// The circle is aligned to the plane of the map.
    public static let map = CirclePitchAlignment(rawValue: "map")

    /// The circle is aligned to the plane of the viewport.
    public static let viewport = CirclePitchAlignment(rawValue: "viewport")
}

/// Controls the scaling behavior of the circle when the map is pitched.
public struct CirclePitchScale: RawRepresentable, Codable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Circles are scaled according to their apparent distance to the camera.
    public static let map = CirclePitchScale(rawValue: "map")

    /// Circles are not scaled.
    public static let viewport = CirclePitchScale(rawValue: "viewport")
}

/// Controls the frame of reference for `circle-translate`.
public struct CircleTranslateAnchor: RawRepresentable, Codable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// The circle is translated relative to the map.
    public static let map = CircleTranslateAnchor(rawValue: "map")

    /// The circle is translated relative to the viewport.
    public static let viewport = CircleTranslateAnchor(rawValue: "viewport")
}

/// Controls the behavior of fill extrusion base over terrain
@_documentation(visibility: public)
@_spi(Experimental)
public struct FillExtrusionBaseAlignment: RawRepresentable, Codable, Hashable, Sendable {
    @_documentation(visibility: public)
    public let rawValue: String

    @_documentation(visibility: public)
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// The fill extrusion base follows terrain slope.
    @_documentation(visibility: public)
    public static let terrain = FillExtrusionBaseAlignment(rawValue: "terrain")

    /// The fill extrusion base is flat over terrain.
    @_documentation(visibility: public)
    public static let flat = FillExtrusionBaseAlignment(rawValue: "flat")
}

/// Controls the behavior of fill extrusion height over terrain
@_documentation(visibility: public)
@_spi(Experimental)
public struct FillExtrusionHeightAlignment: RawRepresentable, Codable, Hashable, Sendable {
    @_documentation(visibility: public)
    public let rawValue: String

    @_documentation(visibility: public)
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// The fill extrusion height follows terrain slope.
    @_documentation(visibility: public)
    public static let terrain = FillExtrusionHeightAlignment(rawValue: "terrain")

    /// The fill extrusion height is flat over terrain.
    @_documentation(visibility: public)
    public static let flat = FillExtrusionHeightAlignment(rawValue: "flat")
}

/// Controls the frame of reference for `fill-extrusion-translate`.
public struct FillExtrusionTranslateAnchor: RawRepresentable, Codable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// The fill extrusion is translated relative to the map.
    public static let map = FillExtrusionTranslateAnchor(rawValue: "map")

    /// The fill extrusion is translated relative to the viewport.
    public static let viewport = FillExtrusionTranslateAnchor(rawValue: "viewport")
}

/// The resampling/interpolation method to use for overscaling, also known as texture magnification filter
public struct RasterResampling: RawRepresentable, Codable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// (Bi)linear filtering interpolates pixel values using the weighted average of the four closest original source pixels creating a smooth but blurry look when overscaled
    public static let linear = RasterResampling(rawValue: "linear")

    /// Nearest neighbor filtering interpolates pixel values using the nearest original source pixel creating a sharp but pixelated look when overscaled
    public static let nearest = RasterResampling(rawValue: "nearest")
}

/// Direction of light source when map is rotated.
public struct HillshadeIlluminationAnchor: RawRepresentable, Codable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// The hillshade illumination is relative to the north direction.
    public static let map = HillshadeIlluminationAnchor(rawValue: "map")

    /// The hillshade illumination is relative to the top of the viewport.
    public static let viewport = HillshadeIlluminationAnchor(rawValue: "viewport")
}

/// Selects the base of the model. Some modes might require precomputed elevation data in the tileset.
@_documentation(visibility: public)
@_spi(Experimental)
public struct ModelElevationReference: RawRepresentable, Codable, Hashable, Sendable {
    @_documentation(visibility: public)
    public let rawValue: String

    @_documentation(visibility: public)
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Elevated rendering is enabled. Use this mode to elevate lines relative to the sea level.
    @_documentation(visibility: public)
    public static let sea = ModelElevationReference(rawValue: "sea")

    /// Elevated rendering is enabled. Use this mode to elevate lines relative to the ground's height below them.
    @_documentation(visibility: public)
    public static let ground = ModelElevationReference(rawValue: "ground")
}

/// Defines scaling mode. Only applies to location-indicator type layers.
@_documentation(visibility: public)
@_spi(Experimental)
public struct ModelScaleMode: RawRepresentable, Codable, Hashable, Sendable {
    @_documentation(visibility: public)
    public let rawValue: String

    @_documentation(visibility: public)
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Model is scaled so that it's always the same size relative to other map features. The property model-scale specifies how many meters each unit in the model file should cover.
    @_documentation(visibility: public)
    public static let map = ModelScaleMode(rawValue: "map")

    /// Model is scaled so that it's always the same size on the screen. The property model-scale specifies how many pixels each unit in model file should cover.
    @_documentation(visibility: public)
    public static let viewport = ModelScaleMode(rawValue: "viewport")
}

/// Defines rendering behavior of model in respect to other 3D scene objects.
@_documentation(visibility: public)
@_spi(Experimental)
public struct ModelType: RawRepresentable, Codable, Hashable, Sendable {
    @_documentation(visibility: public)
    public let rawValue: String

    @_documentation(visibility: public)
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Integrated to 3D scene, using depth testing, along with terrain, fill-extrusions and custom layer.
    @_documentation(visibility: public)
    public static let common3d = ModelType(rawValue: "common-3d")

    /// Displayed over other 3D content, occluded by terrain.
    @_documentation(visibility: public)
    public static let locationIndicator = ModelType(rawValue: "location-indicator")
}

/// Orientation of background layer.
@_documentation(visibility: public)
@_spi(Experimental)
public struct BackgroundPitchAlignment: RawRepresentable, Codable, Hashable, Sendable {
    @_documentation(visibility: public)
    public let rawValue: String

    @_documentation(visibility: public)
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// The background is aligned to the plane of the map.
    @_documentation(visibility: public)
    public static let map = BackgroundPitchAlignment(rawValue: "map")

    /// The background is aligned to the plane of the viewport, covering the whole screen. Note: This mode disables the automatic reordering of the layer when terrain or globe projection is used.
    @_documentation(visibility: public)
    public static let viewport = BackgroundPitchAlignment(rawValue: "viewport")
}

/// The type of the sky
public struct SkyType: RawRepresentable, Codable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Renders the sky with a gradient that can be configured with `sky-gradient-radius` and `sky-gradient`.
    public static let gradient = SkyType(rawValue: "gradient")

    /// Renders the sky with a simulated atmospheric scattering algorithm, the sun direction can be attached to the light position or explicitly set through `sky-atmosphere-sun`.
    public static let atmosphere = SkyType(rawValue: "atmosphere")
}

/// Whether extruded geometries are lit relative to the map or viewport.
public struct Anchor: RawRepresentable, Codable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// The position of the light source is aligned to the rotation of the map.
    public static let map = Anchor(rawValue: "map")

    /// The position of the light source is aligned to the rotation of the viewport. If terrain is enabled, performance regressions may occur in certain scenarios, particularly on lower-end hardware. Ensure that you test your target scenarios on the appropriate hardware to verify performance.
    public static let viewport = Anchor(rawValue: "viewport")
}

/// The name of the projection to be used for rendering the map.
public struct StyleProjectionName: RawRepresentable, Codable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// The Mercator projection is the default projection.
    public static let mercator = StyleProjectionName(rawValue: "mercator")

    /// A globe projection.
    public static let globe = StyleProjectionName(rawValue: "globe")
}

/// The property allows control over a symbol's orientation. Note that the property values act as a hint, so that a symbol whose language doesn’t support the provided orientation will be laid out in its natural orientation. Example: English point symbol will be rendered horizontally even if array value contains single 'vertical' enum value. For symbol with point placement, the order of elements in an array define priority order for the placement of an orientation variant. For symbol with line placement, the default text writing mode is either ['horizontal', 'vertical'] or ['vertical', 'horizontal'], the order doesn't affect the placement.
public struct TextWritingMode: RawRepresentable, Codable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// If a text's language supports horizontal writing mode, symbols would be laid out horizontally.
    public static let horizontal = TextWritingMode(rawValue: "horizontal")

    /// If a text's language supports vertical writing mode, symbols would be laid out vertically.
    public static let vertical = TextWritingMode(rawValue: "vertical")
}

/// Layer types that will also be removed if fallen below this clip layer.
public struct ClipLayerTypes: RawRepresentable, Codable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// If present the clip layer would remove all 3d model layers below it. Currently only instanced models (e.g. trees) are removed.
    public static let model = ClipLayerTypes(rawValue: "model")

    /// If present the clip layer would remove all symbol layers below it.
    public static let symbol = ClipLayerTypes(rawValue: "symbol")
}
