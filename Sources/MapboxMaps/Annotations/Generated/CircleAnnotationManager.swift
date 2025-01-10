// This file is generated.

/// An instance of `CircleAnnotationManager` is responsible for a collection of `CircleAnnotation`s.
public class CircleAnnotationManager: AnnotationManager, AnnotationManagerInternal, AnnotationManagerImplDelegate {
    typealias Impl = AnnotationManagerImpl<CircleAnnotation>

    public var sourceId: String { impl.id }
    public var layerId: String { impl.id }
    public var id: String { impl.id }

    let impl: AnnotationManagerImpl<CircleAnnotation>

    /// The collection of ``CircleAnnotation`` being managed.
    ///
    /// Each annotation must have a unique identifier. Duplicate IDs will cause only the first annotation to be displayed, while the rest will be ignored.
    public var annotations: [CircleAnnotation] {
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

    /// Sorts features in ascending order based on this value. Features with a higher sort key will appear above features with a lower sort key.
    public var circleSortKey: Double? {
        get { impl.layerProperties["circle-sort-key"] as? Double }
        set { impl.layerProperties["circle-sort-key"] = newValue }
    }

    /// Amount to blur the circle. 1 blurs the circle such that only the centerpoint is full opacity. Setting a negative value renders the blur as an inner glow effect.
    /// Default value: 0.
    public var circleBlur: Double? {
        get { impl.layerProperties["circle-blur"] as? Double }
        set { impl.layerProperties["circle-blur"] = newValue }
    }

    /// The fill color of the circle.
    /// Default value: "#000000".
    public var circleColor: StyleColor? {
        get { impl.layerProperties["circle-color"].flatMap { $0 as? String }.flatMap(StyleColor.init(rawValue:)) }
        set { impl.layerProperties["circle-color"] = newValue?.rawValue }
    }

    /// Controls the intensity of light emitted on the source features.
    /// Default value: 0. Minimum value: 0. The unit of circleEmissiveStrength is in intensity.
    public var circleEmissiveStrength: Double? {
        get { impl.layerProperties["circle-emissive-strength"] as? Double }
        set { impl.layerProperties["circle-emissive-strength"] = newValue }
    }

    /// The opacity at which the circle will be drawn.
    /// Default value: 1. Value range: [0, 1]
    public var circleOpacity: Double? {
        get { impl.layerProperties["circle-opacity"] as? Double }
        set { impl.layerProperties["circle-opacity"] = newValue }
    }

    /// Orientation of circle when map is pitched.
    /// Default value: "viewport".
    public var circlePitchAlignment: CirclePitchAlignment? {
        get { impl.layerProperties["circle-pitch-alignment"].flatMap { $0 as? String }.flatMap(CirclePitchAlignment.init(rawValue:)) }
        set { impl.layerProperties["circle-pitch-alignment"] = newValue?.rawValue }
    }

    /// Controls the scaling behavior of the circle when the map is pitched.
    /// Default value: "map".
    public var circlePitchScale: CirclePitchScale? {
        get { impl.layerProperties["circle-pitch-scale"].flatMap { $0 as? String }.flatMap(CirclePitchScale.init(rawValue:)) }
        set { impl.layerProperties["circle-pitch-scale"] = newValue?.rawValue }
    }

    /// Circle radius.
    /// Default value: 5. Minimum value: 0. The unit of circleRadius is in pixels.
    public var circleRadius: Double? {
        get { impl.layerProperties["circle-radius"] as? Double }
        set { impl.layerProperties["circle-radius"] = newValue }
    }

    /// The stroke color of the circle.
    /// Default value: "#000000".
    public var circleStrokeColor: StyleColor? {
        get { impl.layerProperties["circle-stroke-color"].flatMap { $0 as? String }.flatMap(StyleColor.init(rawValue:)) }
        set { impl.layerProperties["circle-stroke-color"] = newValue?.rawValue }
    }

    /// The opacity of the circle's stroke.
    /// Default value: 1. Value range: [0, 1]
    public var circleStrokeOpacity: Double? {
        get { impl.layerProperties["circle-stroke-opacity"] as? Double }
        set { impl.layerProperties["circle-stroke-opacity"] = newValue }
    }

    /// The width of the circle's stroke. Strokes are placed outside of the `circle-radius`.
    /// Default value: 0. Minimum value: 0. The unit of circleStrokeWidth is in pixels.
    public var circleStrokeWidth: Double? {
        get { impl.layerProperties["circle-stroke-width"] as? Double }
        set { impl.layerProperties["circle-stroke-width"] = newValue }
    }

    /// The geometry's offset. Values are [x, y] where negatives indicate left and up, respectively.
    /// Default value: [0,0]. The unit of circleTranslate is in pixels.
    public var circleTranslate: [Double]? {
        get { impl.layerProperties["circle-translate"] as? [Double] }
        set { impl.layerProperties["circle-translate"] = newValue }
    }

    /// Controls the frame of reference for `circle-translate`.
    /// Default value: "map".
    public var circleTranslateAnchor: CircleTranslateAnchor? {
        get { impl.layerProperties["circle-translate-anchor"].flatMap { $0 as? String }.flatMap(CircleTranslateAnchor.init(rawValue:)) }
        set { impl.layerProperties["circle-translate-anchor"] = newValue?.rawValue }
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
