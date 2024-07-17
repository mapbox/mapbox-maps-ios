// This file is generated.

/// An instance of `CircleAnnotationManager` is responsible for a collection of `CircleAnnotation`s.
public class CircleAnnotationManager: AnnotationManager, AnnotationManagerInternal, AnnotationManagerImplDelegate {
    typealias Impl = AnnotationManagerImpl<CircleAnnotationManagerTraits>

    public var sourceId: String { impl.id }
    public var layerId: String { impl.id }
    public var id: String { impl.id }

    let impl: AnnotationManagerImpl<CircleAnnotationManagerTraits>

    /// The collection of ``CircleAnnotation`` being managed.
    ///
    /// Each annotation must have a unique identifier. Duplicate IDs will cause only the first annotation to be displayed, while the rest will be ignored.
    public var annotations: [CircleAnnotation] {
        get { impl.annotations }
        set { impl.annotations = newValue }
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

    /// Controls the intensity of light emitted on the source features.
    /// Default value: 0. Minimum value: 0.
    public var circleEmissiveStrength: Double? {
        get { impl.layerProperties["circle-emissive-strength"] as? Double }
        set { impl.layerProperties["circle-emissive-strength"] = newValue }
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

    /// The geometry's offset. Values are [x, y] where negatives indicate left and up, respectively.
    /// Default value: [0,0].
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
