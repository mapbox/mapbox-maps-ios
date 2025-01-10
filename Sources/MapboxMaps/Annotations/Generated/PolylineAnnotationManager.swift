// This file is generated.

/// An instance of `PolylineAnnotationManager` is responsible for a collection of `PolylineAnnotation`s.
public class PolylineAnnotationManager: AnnotationManager, AnnotationManagerInternal, AnnotationManagerImplDelegate {
    typealias Impl = AnnotationManagerImpl<PolylineAnnotation>

    public var sourceId: String { impl.id }
    public var layerId: String { impl.id }
    public var id: String { impl.id }

    let impl: AnnotationManagerImpl<PolylineAnnotation>

    /// The collection of ``PolylineAnnotation`` being managed.
    ///
    /// Each annotation must have a unique identifier. Duplicate IDs will cause only the first annotation to be displayed, while the rest will be ignored.
    public var annotations: [PolylineAnnotation] {
        get { impl.annotations }
        set { impl.annotations = newValue }
    }

    /// A custom tappable area radius. Default value is 0.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public var tapRadius: CGFloat? {
        get { impl.tapRadius }
        set { impl.tapRadius = newValue }
    }

    /// A custom tappable area radius. Default value is 0.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public var longPressRadius: CGFloat? {
        get { impl.longPressRadius }
        set { impl.longPressRadius = newValue }
    }

    /// Set this delegate in order to be called back if a tap occurs on an annotation being managed by this manager.
    /// - NOTE: This annotation manager listens to tap events via the ``GestureManager/singleTapGestureRecognizer``.
    @available(*, deprecated, message: "Use tapHandler property of Annotation")
    public weak var delegate: AnnotationInteractionDelegate? {
        get { _delegate }
        set { _delegate = newValue }
    }
    private weak var _delegate: AnnotationInteractionDelegate?

    required init(params: AnnotationManagerParams, deps: AnnotationManagerDeps) {
        self.impl = .init(params: params, deps: deps)
        impl.delegate = self
    }

    func didTap(_ annotations: [Annotation]) {
        _delegate?.annotationManager(self, didDetectTappedAnnotations: annotations)
    }

    func syncImages() {}
    func removeAllImages() {}

    // MARK: - Common layer properties

    /// The display of line endings.
    /// Default value: "butt".
    public var lineCap: LineCap? {
        get { impl.layerProperties["line-cap"].flatMap { $0 as? String }.flatMap(LineCap.init(rawValue:)) }
        set { impl.layerProperties["line-cap"] = newValue?.rawValue }
    }

    /// Defines the slope of an elevated line. A value of 0 creates a horizontal line. A value of 1 creates a vertical line. Other values are currently not supported. If undefined, the line follows the terrain slope. This is an experimental property with some known issues:
    ///  - Vertical lines don't support line caps
    ///  - `line-join: round` is not supported with this property
    @_documentation(visibility: public)
    @_spi(Experimental) public var lineCrossSlope: Double? {
        get { impl.layerProperties["line-cross-slope"] as? Double }
        set { impl.layerProperties["line-cross-slope"] = newValue }
    }

    /// Selects the base of line-elevation. Some modes might require precomputed elevation data in the tileset.
    /// Default value: "none".
    @_documentation(visibility: public)
    @_spi(Experimental) public var lineElevationReference: LineElevationReference? {
        get { impl.layerProperties["line-elevation-reference"].flatMap { $0 as? String }.flatMap(LineElevationReference.init(rawValue:)) }
        set { impl.layerProperties["line-elevation-reference"] = newValue?.rawValue }
    }

    /// The display of lines when joining.
    /// Default value: "miter".
    public var lineJoin: LineJoin? {
        get { impl.layerProperties["line-join"].flatMap { $0 as? String }.flatMap(LineJoin.init(rawValue:)) }
        set { impl.layerProperties["line-join"] = newValue?.rawValue }
    }

    /// Used to automatically convert miter joins to bevel joins for sharp angles.
    /// Default value: 2.
    public var lineMiterLimit: Double? {
        get { impl.layerProperties["line-miter-limit"] as? Double }
        set { impl.layerProperties["line-miter-limit"] = newValue }
    }

    /// Used to automatically convert round joins to miter joins for shallow angles.
    /// Default value: 1.05.
    public var lineRoundLimit: Double? {
        get { impl.layerProperties["line-round-limit"] as? Double }
        set { impl.layerProperties["line-round-limit"] = newValue }
    }

    /// Sorts features in ascending order based on this value. Features with a higher sort key will appear above features with a lower sort key.
    public var lineSortKey: Double? {
        get { impl.layerProperties["line-sort-key"] as? Double }
        set { impl.layerProperties["line-sort-key"] = newValue }
    }

    /// Selects the unit of line-width. The same unit is automatically used for line-blur and line-offset. Note: This is an experimental property and might be removed in a future release.
    /// Default value: "pixels".
    @_documentation(visibility: public)
    @_spi(Experimental) public var lineWidthUnit: LineWidthUnit? {
        get { impl.layerProperties["line-width-unit"].flatMap { $0 as? String }.flatMap(LineWidthUnit.init(rawValue:)) }
        set { impl.layerProperties["line-width-unit"] = newValue?.rawValue }
    }

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
    @_spi(Experimental) public var lineZOffset: Double? {
        get { impl.layerProperties["line-z-offset"] as? Double }
        set { impl.layerProperties["line-z-offset"] = newValue }
    }

    /// Blur applied to the line, in pixels.
    /// Default value: 0. Minimum value: 0. The unit of lineBlur is in pixels.
    public var lineBlur: Double? {
        get { impl.layerProperties["line-blur"] as? Double }
        set { impl.layerProperties["line-blur"] = newValue }
    }

    /// The color of the line border. If line-border-width is greater than zero and the alpha value of this color is 0 (default), the color for the border will be selected automatically based on the line color.
    /// Default value: "rgba(0, 0, 0, 0)".
    public var lineBorderColor: StyleColor? {
        get { impl.layerProperties["line-border-color"].flatMap { $0 as? String }.flatMap(StyleColor.init(rawValue:)) }
        set { impl.layerProperties["line-border-color"] = newValue?.rawValue }
    }

    /// The width of the line border. A value of zero means no border.
    /// Default value: 0. Minimum value: 0.
    public var lineBorderWidth: Double? {
        get { impl.layerProperties["line-border-width"] as? Double }
        set { impl.layerProperties["line-border-width"] = newValue }
    }

    /// The color with which the line will be drawn.
    /// Default value: "#000000".
    public var lineColor: StyleColor? {
        get { impl.layerProperties["line-color"].flatMap { $0 as? String }.flatMap(StyleColor.init(rawValue:)) }
        set { impl.layerProperties["line-color"] = newValue?.rawValue }
    }

    /// Specifies the lengths of the alternating dashes and gaps that form the dash pattern. The lengths are later scaled by the line width. To convert a dash length to pixels, multiply the length by the current line width. Note that GeoJSON sources with `lineMetrics: true` specified won't render dashed lines to the expected scale. Also note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    /// Minimum value: 0. The unit of lineDasharray is in line widths.
    public var lineDasharray: [Double]? {
        get { impl.layerProperties["line-dasharray"] as? [Double] }
        set { impl.layerProperties["line-dasharray"] = newValue }
    }

    /// Decrease line layer opacity based on occlusion from 3D objects. Value 0 disables occlusion, value 1 means fully occluded.
    /// Default value: 1. Value range: [0, 1]
    public var lineDepthOcclusionFactor: Double? {
        get { impl.layerProperties["line-depth-occlusion-factor"] as? Double }
        set { impl.layerProperties["line-depth-occlusion-factor"] = newValue }
    }

    /// Controls the intensity of light emitted on the source features.
    /// Default value: 0. Minimum value: 0. The unit of lineEmissiveStrength is in intensity.
    public var lineEmissiveStrength: Double? {
        get { impl.layerProperties["line-emissive-strength"] as? Double }
        set { impl.layerProperties["line-emissive-strength"] = newValue }
    }

    /// Draws a line casing outside of a line's actual path. Value indicates the width of the inner gap.
    /// Default value: 0. Minimum value: 0. The unit of lineGapWidth is in pixels.
    public var lineGapWidth: Double? {
        get { impl.layerProperties["line-gap-width"] as? Double }
        set { impl.layerProperties["line-gap-width"] = newValue }
    }

    /// Opacity multiplier (multiplies line-opacity value) of the line part that is occluded by 3D objects. Value 0 hides occluded part, value 1 means the same opacity as non-occluded part. The property is not supported when `line-opacity` has data-driven styling.
    /// Default value: 0. Value range: [0, 1]
    public var lineOcclusionOpacity: Double? {
        get { impl.layerProperties["line-occlusion-opacity"] as? Double }
        set { impl.layerProperties["line-occlusion-opacity"] = newValue }
    }

    /// The line's offset. For linear features, a positive value offsets the line to the right, relative to the direction of the line, and a negative value to the left. For polygon features, a positive value results in an inset, and a negative value results in an outset.
    /// Default value: 0. The unit of lineOffset is in pixels.
    public var lineOffset: Double? {
        get { impl.layerProperties["line-offset"] as? Double }
        set { impl.layerProperties["line-offset"] = newValue }
    }

    /// The opacity at which the line will be drawn.
    /// Default value: 1. Value range: [0, 1]
    public var lineOpacity: Double? {
        get { impl.layerProperties["line-opacity"] as? Double }
        set { impl.layerProperties["line-opacity"] = newValue }
    }

    /// Name of image in sprite to use for drawing image lines. For seamless patterns, image width must be a factor of two (2, 4, 8, ..., 512). Note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    public var linePattern: String? {
        get { impl.layerProperties["line-pattern"] as? String }
        set { impl.layerProperties["line-pattern"] = newValue }
    }

    /// The geometry's offset. Values are [x, y] where negatives indicate left and up, respectively.
    /// Default value: [0,0]. The unit of lineTranslate is in pixels.
    public var lineTranslate: [Double]? {
        get { impl.layerProperties["line-translate"] as? [Double] }
        set { impl.layerProperties["line-translate"] = newValue }
    }

    /// Controls the frame of reference for `line-translate`.
    /// Default value: "map".
    public var lineTranslateAnchor: LineTranslateAnchor? {
        get { impl.layerProperties["line-translate-anchor"].flatMap { $0 as? String }.flatMap(LineTranslateAnchor.init(rawValue:)) }
        set { impl.layerProperties["line-translate-anchor"] = newValue?.rawValue }
    }

    /// The color to be used for rendering the trimmed line section that is defined by the `line-trim-offset` property.
    /// Default value: "transparent".
    @_documentation(visibility: public)
    @_spi(Experimental) public var lineTrimColor: StyleColor? {
        get { impl.layerProperties["line-trim-color"].flatMap { $0 as? String }.flatMap(StyleColor.init(rawValue:)) }
        set { impl.layerProperties["line-trim-color"] = newValue?.rawValue }
    }

    /// The fade range for the trim-start and trim-end points is defined by the `line-trim-offset` property. The first element of the array represents the fade range from the trim-start point toward the end of the line, while the second element defines the fade range from the trim-end point toward the beginning of the line. The fade result is achieved by interpolating between `line-trim-color` and the color specified by the `line-color` or the `line-gradient` property.
    /// Default value: [0,0]. Minimum value: [0,0]. Maximum value: [1,1].
    @_documentation(visibility: public)
    @_spi(Experimental) public var lineTrimFadeRange: [Double]? {
        get { impl.layerProperties["line-trim-fade-range"] as? [Double] }
        set { impl.layerProperties["line-trim-fade-range"] = newValue }
    }

    /// The line part between [trim-start, trim-end] will be painted using `line-trim-color,` which is transparent by default to produce a route vanishing effect. The line trim-off offset is based on the whole line range [0.0, 1.0].
    /// Default value: [0,0]. Minimum value: [0,0]. Maximum value: [1,1].
    public var lineTrimOffset: [Double]? {
        get { impl.layerProperties["line-trim-offset"] as? [Double] }
        set { impl.layerProperties["line-trim-offset"] = newValue }
    }

    /// Stroke thickness.
    /// Default value: 1. Minimum value: 0. The unit of lineWidth is in pixels.
    public var lineWidth: Double? {
        get { impl.layerProperties["line-width"] as? Double }
        set { impl.layerProperties["line-width"] = newValue }
    }

    /// Slot for the underlying layer.
    ///
    /// Use this property to position the annotations relative to other map features if you use Mapbox Standard Style.
    /// See <doc:Migrate-to-v11##21-The-Mapbox-Standard-Style> for more info.
    public var slot: String? {
        get { impl.layerProperties["slot"] as? String }
        set { impl.layerProperties["slot"] = newValue }
    }
}

// End of generated file.
