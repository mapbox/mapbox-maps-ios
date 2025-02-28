// This file is generated

/// Displays a group of ``PolylineAnnotation``s.
///
/// When multiple annotation grouped, they render by a single layer. This makes annotations more performant and
/// allows to modify group-specific parameters.  For example, you canmodify ``lineCap(_:)`` or define layer slot with ``slot(_:)``.
///
/// - Note: `PolylineAnnotationGroup` is a SwiftUI analog to ``PolylineAnnotationManager``.
///
/// The group can be created with dynamic data, or static data. When first method is used, you specify array of identified data and provide a closure that creates a ``PolylineAnnotation`` from that data, similar to ``ForEvery``:
////// ```swift
/// Map {
///   PolylineAnnotationGroup(routes) { route in
///     PolylineAnnotation(lineCoordinates: route.coordinates)
///       .lineColor("blue")
///   }
///   .lineCap(.round)
///   .slot(.middle)
/// }
/// ```
///
/// When the number of annotations is static, you use static that groups one or more annotations:
////// ```swift
/// Map {
///     PolylineAnnotationGroup {
///         PolylineAnnotation(lineCoordinates: route.coordinates)
///             .lineColor("blue")
///         if let alternativeRoute {
///             PolylineAnnotation(lineCoordinates: alternativeRoute.coordinates)
///                 .lineColor("green")
///         }
///     }
///     .lineCap(.round)
///     .slot(.middle)
/// }
/// ```
import UIKit

public struct PolylineAnnotationGroup<Data: RandomAccessCollection, ID: Hashable> {
    let annotations: [(ID, PolylineAnnotation)]

    /// Creates a group that identifies data by given key path.
    ///
    /// - Parameters:
    ///     - data: Collection of data.
    ///     - id: Data identifier key path.
    ///     - content: A closure that creates annotation for a given data item.
    public init(_ data: Data, id: KeyPath<Data.Element, ID>, content: @escaping (Data.Element) -> PolylineAnnotation) {
        annotations = data.map { element in
            (element[keyPath: id], content(element))
        }
    }

    /// Creates a group from identifiable data.
    ///
    /// - Parameters:
    ///     - data: Collection of identifiable data.
    ///     - content: A closure that creates annotation for a given data item.
    public init(_ data: Data, content: @escaping (Data.Element) -> PolylineAnnotation) where Data.Element: Identifiable, Data.Element.ID == ID {
        self.init(data, id: \.id, content: content)
    }

    /// Creates static group.
    ///
    /// - Parameters:
    ///     - content: A builder closure that creates annotations.
    public init(@ArrayBuilder<PolylineAnnotation> content: @escaping () -> [PolylineAnnotation?])
        where Data == [(Int, PolylineAnnotation)], ID == Int {

        let annotations = content()
            .enumerated()
            .compactMap { $0.element == nil ? nil : ($0.offset, $0.element!) }
        self.init(annotations, id: \.0, content: \.1)
    }

    private func updateProperties(manager: PolylineAnnotationManager) {
        assign(manager, \.lineCap, value: lineCap)
        assign(manager, \.lineCrossSlope, value: lineCrossSlope)
        assign(manager, \.lineElevationReference, value: lineElevationReference)
        assign(manager, \.lineJoin, value: lineJoin)
        assign(manager, \.lineMiterLimit, value: lineMiterLimit)
        assign(manager, \.lineRoundLimit, value: lineRoundLimit)
        assign(manager, \.lineSortKey, value: lineSortKey)
        assign(manager, \.lineWidthUnit, value: lineWidthUnit)
        assign(manager, \.lineZOffset, value: lineZOffset)
        assign(manager, \.lineBlur, value: lineBlur)
        assign(manager, \.lineBorderColor, value: lineBorderColor)
        assign(manager, \.lineBorderWidth, value: lineBorderWidth)
        assign(manager, \.lineColor, value: lineColor)
        assign(manager, \.lineDasharray, value: lineDasharray)
        assign(manager, \.lineDepthOcclusionFactor, value: lineDepthOcclusionFactor)
        assign(manager, \.lineEmissiveStrength, value: lineEmissiveStrength)
        assign(manager, \.lineGapWidth, value: lineGapWidth)
        assign(manager, \.lineOcclusionOpacity, value: lineOcclusionOpacity)
        assign(manager, \.lineOffset, value: lineOffset)
        assign(manager, \.lineOpacity, value: lineOpacity)
        assign(manager, \.linePattern, value: linePattern)
        assign(manager, \.lineTranslate, value: lineTranslate)
        assign(manager, \.lineTranslateAnchor, value: lineTranslateAnchor)
        assign(manager, \.lineTrimColor, value: lineTrimColor)
        assign(manager, \.lineTrimFadeRange, value: lineTrimFadeRange)
        assign(manager, \.lineTrimOffset, value: lineTrimOffset)
        assign(manager, \.lineWidth, value: lineWidth)
        assign(manager, \.slot, value: slot)
        manager.tapRadius = tapRadius
        manager.longPressRadius = longPressRadius
    }

    // MARK: - Common layer properties

    private var lineCap: LineCap?
    /// The display of line endings.
    /// Default value: "butt".
    public func lineCap(_ newValue: LineCap) -> Self {
        with(self, setter(\.lineCap, newValue))
    }

    private var lineCrossSlope: Double?
    /// Defines the slope of an elevated line. A value of 0 creates a horizontal line. A value of 1 creates a vertical line. Other values are currently not supported. If undefined, the line follows the terrain slope. This is an experimental property with some known issues:
    ///  - Vertical lines don't support line caps
    ///  - `line-join: round` is not supported with this property
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func lineCrossSlope(_ newValue: Double) -> Self {
        with(self, setter(\.lineCrossSlope, newValue))
    }

    private var lineElevationReference: LineElevationReference?
    /// Selects the base of line-elevation. Some modes might require precomputed elevation data in the tileset.
    /// Default value: "none".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func lineElevationReference(_ newValue: LineElevationReference) -> Self {
        with(self, setter(\.lineElevationReference, newValue))
    }

    private var lineJoin: LineJoin?
    /// The display of lines when joining.
    /// Default value: "miter".
    public func lineJoin(_ newValue: LineJoin) -> Self {
        with(self, setter(\.lineJoin, newValue))
    }

    private var lineMiterLimit: Double?
    /// Used to automatically convert miter joins to bevel joins for sharp angles.
    /// Default value: 2.
    public func lineMiterLimit(_ newValue: Double) -> Self {
        with(self, setter(\.lineMiterLimit, newValue))
    }

    private var lineRoundLimit: Double?
    /// Used to automatically convert round joins to miter joins for shallow angles.
    /// Default value: 1.05.
    public func lineRoundLimit(_ newValue: Double) -> Self {
        with(self, setter(\.lineRoundLimit, newValue))
    }

    private var lineSortKey: Double?
    /// Sorts features in ascending order based on this value. Features with a higher sort key will appear above features with a lower sort key.
    public func lineSortKey(_ newValue: Double) -> Self {
        with(self, setter(\.lineSortKey, newValue))
    }

    private var lineWidthUnit: LineWidthUnit?
    /// Selects the unit of line-width. The same unit is automatically used for line-blur and line-offset. Note: This is an experimental property and might be removed in a future release.
    /// Default value: "pixels".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func lineWidthUnit(_ newValue: LineWidthUnit) -> Self {
        with(self, setter(\.lineWidthUnit, newValue))
    }

    private var lineZOffset: Double?
    /// Vertical offset from ground, in meters. Defaults to 0. This is an experimental property with some known issues:
    ///  - Not supported for globe projection at the moment
    ///  - Elevated line discontinuity is possible on tile borders with terrain enabled
    ///  - Rendering artifacts can happen near line joins and line caps depending on the line styling
    ///  - Rendering artifacts relating to `line-opacity` and `line-blur`
    ///  - Elevated line visibility is determined by layer order
    ///  - Z-fighting issues can happen with intersecting elevated lines
    ///  - Elevated lines don't cast shadows
    /// Default value: 0.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func lineZOffset(_ newValue: Double) -> Self {
        with(self, setter(\.lineZOffset, newValue))
    }

    private var lineBlur: Double?
    /// Blur applied to the line, in pixels.
    /// Default value: 0. Minimum value: 0. The unit of lineBlur is in pixels.
    public func lineBlur(_ newValue: Double) -> Self {
        with(self, setter(\.lineBlur, newValue))
    }

    private var lineBorderColor: StyleColor?
    /// The color of the line border. If line-border-width is greater than zero and the alpha value of this color is 0 (default), the color for the border will be selected automatically based on the line color.
    /// Default value: "rgba(0, 0, 0, 0)".
    public func lineBorderColor(_ color: UIColor) -> Self {
        with(self, setter(\.lineBorderColor, StyleColor(color)))
    }

    private var lineBorderWidth: Double?
    /// The width of the line border. A value of zero means no border.
    /// Default value: 0. Minimum value: 0.
    public func lineBorderWidth(_ newValue: Double) -> Self {
        with(self, setter(\.lineBorderWidth, newValue))
    }

    private var lineColor: StyleColor?
    /// The color with which the line will be drawn.
    /// Default value: "#000000".
    public func lineColor(_ color: UIColor) -> Self {
        with(self, setter(\.lineColor, StyleColor(color)))
    }

    private var lineDasharray: [Double]?
    /// Specifies the lengths of the alternating dashes and gaps that form the dash pattern. The lengths are later scaled by the line width. To convert a dash length to pixels, multiply the length by the current line width. Note that GeoJSON sources with `lineMetrics: true` specified won't render dashed lines to the expected scale. Also note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    /// Minimum value: 0. The unit of lineDasharray is in line widths.
    public func lineDasharray(_ newValue: [Double]) -> Self {
        with(self, setter(\.lineDasharray, newValue))
    }

    private var lineDepthOcclusionFactor: Double?
    /// Decrease line layer opacity based on occlusion from 3D objects. Value 0 disables occlusion, value 1 means fully occluded.
    /// Default value: 1. Value range: [0, 1]
    public func lineDepthOcclusionFactor(_ newValue: Double) -> Self {
        with(self, setter(\.lineDepthOcclusionFactor, newValue))
    }

    private var lineEmissiveStrength: Double?
    /// Controls the intensity of light emitted on the source features.
    /// Default value: 0. Minimum value: 0. The unit of lineEmissiveStrength is in intensity.
    public func lineEmissiveStrength(_ newValue: Double) -> Self {
        with(self, setter(\.lineEmissiveStrength, newValue))
    }

    private var lineGapWidth: Double?
    /// Draws a line casing outside of a line's actual path. Value indicates the width of the inner gap.
    /// Default value: 0. Minimum value: 0. The unit of lineGapWidth is in pixels.
    public func lineGapWidth(_ newValue: Double) -> Self {
        with(self, setter(\.lineGapWidth, newValue))
    }

    private var lineOcclusionOpacity: Double?
    /// Opacity multiplier (multiplies line-opacity value) of the line part that is occluded by 3D objects. Value 0 hides occluded part, value 1 means the same opacity as non-occluded part. The property is not supported when `line-opacity` has data-driven styling.
    /// Default value: 0. Value range: [0, 1]
    public func lineOcclusionOpacity(_ newValue: Double) -> Self {
        with(self, setter(\.lineOcclusionOpacity, newValue))
    }

    private var lineOffset: Double?
    /// The line's offset. For linear features, a positive value offsets the line to the right, relative to the direction of the line, and a negative value to the left. For polygon features, a positive value results in an inset, and a negative value results in an outset.
    /// Default value: 0. The unit of lineOffset is in pixels.
    public func lineOffset(_ newValue: Double) -> Self {
        with(self, setter(\.lineOffset, newValue))
    }

    private var lineOpacity: Double?
    /// The opacity at which the line will be drawn.
    /// Default value: 1. Value range: [0, 1]
    public func lineOpacity(_ newValue: Double) -> Self {
        with(self, setter(\.lineOpacity, newValue))
    }

    private var linePattern: String?
    /// Name of image in sprite to use for drawing image lines. For seamless patterns, image width must be a factor of two (2, 4, 8, ..., 512). Note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    public func linePattern(_ newValue: String) -> Self {
        with(self, setter(\.linePattern, newValue))
    }

    private var lineTranslate: [Double]?
    /// The geometry's offset. Values are [x, y] where negatives indicate left and up, respectively.
    /// Default value: [0,0]. The unit of lineTranslate is in pixels.
    public func lineTranslate(x: Double, y: Double) -> Self {
        with(self, setter(\.lineTranslate, [x, y]))
    }

    private var lineTranslateAnchor: LineTranslateAnchor?
    /// Controls the frame of reference for `line-translate`.
    /// Default value: "map".
    public func lineTranslateAnchor(_ newValue: LineTranslateAnchor) -> Self {
        with(self, setter(\.lineTranslateAnchor, newValue))
    }

    private var lineTrimColor: StyleColor?
    /// The color to be used for rendering the trimmed line section that is defined by the `line-trim-offset` property.
    /// Default value: "transparent".
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func lineTrimColor(_ color: UIColor) -> Self {
        with(self, setter(\.lineTrimColor, StyleColor(color)))
    }

    private var lineTrimFadeRange: [Double]?
    /// The fade range for the trim-start and trim-end points is defined by the `line-trim-offset` property. The first element of the array represents the fade range from the trim-start point toward the end of the line, while the second element defines the fade range from the trim-end point toward the beginning of the line. The fade result is achieved by interpolating between `line-trim-color` and the color specified by the `line-color` or the `line-gradient` property.
    /// Default value: [0,0]. Minimum value: [0,0]. Maximum value: [1,1].
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func lineTrimFadeRange(start: Double, end: Double) -> Self {
        with(self, setter(\.lineTrimFadeRange, [start, end]))
    }

    private var lineTrimOffset: [Double]?
    /// The line part between [trim-start, trim-end] will be painted using `line-trim-color,` which is transparent by default to produce a route vanishing effect. The line trim-off offset is based on the whole line range [0.0, 1.0].
    /// Default value: [0,0]. Minimum value: [0,0]. Maximum value: [1,1].
    public func lineTrimOffset(start: Double, end: Double) -> Self {
        with(self, setter(\.lineTrimOffset, [start, end]))
    }

    private var lineWidth: Double?
    /// Stroke thickness.
    /// Default value: 1. Minimum value: 0. The unit of lineWidth is in pixels.
    public func lineWidth(_ newValue: Double) -> Self {
        with(self, setter(\.lineWidth, newValue))
    }

    private var slot: String?
    /// Slot for the underlying layer.
    ///
    /// Use this property to position the annotations relative to other map features if you use Mapbox Standard Style.
    /// See <doc:Migrate-to-v11##21-The-Mapbox-Standard-Style> for more info.
    @available(*, deprecated, message: "Use Slot type instead of string")
    public func slot(_ newValue: String) -> Self {
        with(self, setter(\.slot, newValue))
    }

    /// Slot for the underlying layer.
    ///
    /// Use this property to position the annotations relative to other map features if you use Mapbox Standard Style.
    /// See <doc:Migrate-to-v11##21-The-Mapbox-Standard-Style> for more info.
    public func slot(_ newValue: Slot?) -> Self {
        with(self, setter(\.slot, newValue?.rawValue))
    }

    private var layerId: String?

    /// Specifies identifier for underlying implementation layer.
    ///
    /// Use the identifier to create view annotations bound the annotations from the group.
    /// For more information, see the ``MapViewAnnotation/init(layerId:featureId:content:)``.
    public func layerId(_ layerId: String) -> Self {
        with(self, setter(\.layerId, layerId))
    }

    var tapRadius: CGFloat?
    var longPressRadius: CGFloat?

    /// A custom tappable area radius. Default value is 0.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public func tapRadius(_ radius: CGFloat? = nil) -> Self {
        with(self, setter(\.tapRadius, radius))
    }

    /// A custom tappable area radius. Default value is 0.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public func longPressRadius(_ radius: CGFloat? = nil) -> Self {
        with(self, setter(\.longPressRadius, radius))
    }
}

extension PolylineAnnotationGroup: MapContent, PrimitiveMapContent {
    func visit(_ node: MapContentNode) {
        let group = MountedAnnotationGroup(
            layerId: layerId ?? node.id.stringId,
            clusterOptions: nil,
            annotations: annotations,
            updateProperties: updateProperties
        )
        node.mount(group)
    }
}

// End of generated file.
