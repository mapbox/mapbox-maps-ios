// This file is generated.

/// An instance of `PolygonAnnotationManager` is responsible for a collection of `PolygonAnnotation`s.
public class PolygonAnnotationManager: AnnotationManager, AnnotationManagerInternal, AnnotationManagerImplDelegate {
    typealias Impl = AnnotationManagerImpl<PolygonAnnotation>

    public var sourceId: String { impl.id }
    public var layerId: String { impl.id }
    public var id: String { impl.id }

    let impl: AnnotationManagerImpl<PolygonAnnotation>

    /// The collection of ``PolygonAnnotation`` being managed.
    ///
    /// Each annotation must have a unique identifier. Duplicate IDs will cause only the first annotation to be displayed, while the rest will be ignored.
    public var annotations: [PolygonAnnotation] {
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

    /// Selects the base of fill-elevation. Some modes might require precomputed elevation data in the tileset.
    /// Default value: "none".
    @_documentation(visibility: public)
    @_spi(Experimental) public var fillElevationReference: FillElevationReference? {
        get { impl.layerProperties["fill-elevation-reference"].flatMap { $0 as? String }.flatMap(FillElevationReference.init(rawValue:)) }
        set { impl.layerProperties["fill-elevation-reference"] = newValue?.rawValue }
    }

    /// Sorts features in ascending order based on this value. Features with a higher sort key will appear above features with a lower sort key.
    public var fillSortKey: Double? {
        get { impl.layerProperties["fill-sort-key"] as? Double }
        set { impl.layerProperties["fill-sort-key"] = newValue }
    }

    /// Whether or not the fill should be antialiased.
    /// Default value: true.
    public var fillAntialias: Bool? {
        get { impl.layerProperties["fill-antialias"] as? Bool }
        set { impl.layerProperties["fill-antialias"] = newValue }
    }

    /// The color of the filled part of this layer. This color can be specified as `rgba` with an alpha component and the color's opacity will not affect the opacity of the 1px stroke, if it is used.
    /// Default value: "#000000".
    public var fillColor: StyleColor? {
        get { impl.layerProperties["fill-color"].flatMap { $0 as? String }.flatMap(StyleColor.init(rawValue:)) }
        set { impl.layerProperties["fill-color"] = newValue?.rawValue }
    }

    /// Controls the intensity of light emitted on the source features.
    /// Default value: 0. Minimum value: 0. The unit of fillEmissiveStrength is in intensity.
    public var fillEmissiveStrength: Double? {
        get { impl.layerProperties["fill-emissive-strength"] as? Double }
        set { impl.layerProperties["fill-emissive-strength"] = newValue }
    }

    /// The opacity of the entire fill layer. In contrast to the `fill-color`, this value will also affect the 1px stroke around the fill, if the stroke is used.
    /// Default value: 1. Value range: [0, 1]
    public var fillOpacity: Double? {
        get { impl.layerProperties["fill-opacity"] as? Double }
        set { impl.layerProperties["fill-opacity"] = newValue }
    }

    /// The outline color of the fill. Matches the value of `fill-color` if unspecified.
    public var fillOutlineColor: StyleColor? {
        get { impl.layerProperties["fill-outline-color"].flatMap { $0 as? String }.flatMap(StyleColor.init(rawValue:)) }
        set { impl.layerProperties["fill-outline-color"] = newValue?.rawValue }
    }

    /// Name of image in sprite to use for drawing image fills. For seamless patterns, image width and height must be a factor of two (2, 4, 8, ..., 512). Note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    public var fillPattern: String? {
        get { impl.layerProperties["fill-pattern"] as? String }
        set { impl.layerProperties["fill-pattern"] = newValue }
    }

    /// The geometry's offset. Values are [x, y] where negatives indicate left and up, respectively.
    /// Default value: [0,0]. The unit of fillTranslate is in pixels.
    public var fillTranslate: [Double]? {
        get { impl.layerProperties["fill-translate"] as? [Double] }
        set { impl.layerProperties["fill-translate"] = newValue }
    }

    /// Controls the frame of reference for `fill-translate`.
    /// Default value: "map".
    public var fillTranslateAnchor: FillTranslateAnchor? {
        get { impl.layerProperties["fill-translate-anchor"].flatMap { $0 as? String }.flatMap(FillTranslateAnchor.init(rawValue:)) }
        set { impl.layerProperties["fill-translate-anchor"] = newValue?.rawValue }
    }

    /// Specifies an uniform elevation in meters. Note: If the value is zero, the layer will be rendered on the ground. Non-zero values will elevate the layer from the sea level, which can cause it to be rendered below the terrain.
    /// Default value: 0. Minimum value: 0.
    @_documentation(visibility: public)
    @_spi(Experimental) public var fillZOffset: Double? {
        get { impl.layerProperties["fill-z-offset"] as? Double }
        set { impl.layerProperties["fill-z-offset"] = newValue }
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
