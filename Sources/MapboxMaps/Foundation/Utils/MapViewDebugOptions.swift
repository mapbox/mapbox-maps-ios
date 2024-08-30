import Foundation

/// Options for enabling debugging features in a map.
public struct MapViewDebugOptions: OptionSet, Hashable, Sendable {
    public let rawValue: Int

    /// Edges of tile boundaries are shown as thick, red lines to help diagnose
    /// tile clipping issues.
    public static let tileBorders = MapViewDebugOptions(rawValue: 1 << 0)

    /// Each tile shows its tile coordinate (x/y/z) in the upper-left corner.
    public static let parseStatus = MapViewDebugOptions(rawValue: 1 << 1)

    /// Each tile shows a timestamp indicating when it was loaded.
    public static let timestamps = MapViewDebugOptions(rawValue: 1 << 2)

    /// Edges of glyphs and symbols are shown as faint, green lines to help
    /// diagnose collision and label placement issues.
    public static let collision = MapViewDebugOptions(rawValue: 1 << 3)

    /// Each drawing operation is replaced by a translucent fill. Overlapping
    /// drawing operations appear more prominent to help diagnose overdrawing.
    public static let overdraw = MapViewDebugOptions(rawValue: 1 << 4)

    /// The stencil buffer is shown instead of the color buffer.
    public static let stencilClip = MapViewDebugOptions(rawValue: 1 << 5)

    /// The depth buffer is shown instead of the color buffer.
    public static let depthBuffer = MapViewDebugOptions(rawValue: 1 << 6)

    /// Show 3D model bounding boxes.
    public static let modelBounds = MapViewDebugOptions(rawValue: 1 << 7)

    /// Each tile shows its local lighting conditions in the upper-left corner. (If `lights` properties are used, otherwise they show zero.)
    public static let light = MapViewDebugOptions(rawValue: 1 << 11)

    /// Show a debug UIView with information about the CameraState
    /// including lat, long, zoom, pitch, & bearing.
    public static let camera = MapViewDebugOptions(rawValue: 1 << 16)

    /// Draws camera padding frame.
    public static let padding = MapViewDebugOptions(rawValue: 1 << 17)

    var nativeDebugOptions: [MapDebugOptions] {
        var nativeDebugOptions = [MapDebugOptions]()
        if contains(.tileBorders) { nativeDebugOptions.append( .tileBorders ) }
        if contains(.parseStatus) { nativeDebugOptions.append( .parseStatus ) }
        if contains(.timestamps) { nativeDebugOptions.append( .timestamps ) }
        if contains(.collision) { nativeDebugOptions.append(.collision) }
        if contains(.overdraw) { nativeDebugOptions.append( .overdraw ) }
        if contains(.stencilClip) { nativeDebugOptions.append( .stencilClip ) }
        if contains(.depthBuffer) { nativeDebugOptions.append( .depthBuffer ) }
        if contains(.modelBounds) { nativeDebugOptions.append( .modelBounds ) }
        if contains(.light) { nativeDebugOptions.append( .light ) }
        return nativeDebugOptions
    }

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
