// This file is generated.

/// An instance of `PointAnnotationManager` is responsible for a collection of `PointAnnotation`s.
public class PointAnnotationManager: AnnotationManager, AnnotationManagerInternal, AnnotationManagerImplDelegate {
    typealias Impl = AnnotationManagerImpl<PointAnnotationManagerTraits>

    public var sourceId: String { impl.id }
    public var layerId: String { impl.id }
    public var id: String { impl.id }

    let impl: AnnotationManagerImpl<PointAnnotationManagerTraits>

    /// The collection of ``PointAnnotation`` being managed.
    ///
    /// Each annotation must have a unique identifier. Duplicate IDs will cause only the first annotation to be displayed, while the rest will be ignored.
    public var annotations: [PointAnnotation] {
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
        self.imagesManager = deps.imagesManager

        impl.delegate = self
        imagesManager.register(imagesConsumer: self)
    }

    func didTap(_ annotations: [Annotation]) {
        _delegate?.annotationManager(self, didDetectTappedAnnotations: annotations)
    }

    /// Handles tap gesture on cluster.
    public var onClusterTap: ((AnnotationClusterGestureContext) -> Void)? {
        get { impl.onClusterTap }
        set { impl.onClusterTap = newValue }
    }

    /// Handles long press gesture on cluster.
    public var onClusterLongPress: ((AnnotationClusterGestureContext) -> Void)? {
        get { impl.onClusterLongPress }
        set { impl.onClusterLongPress = newValue }
    }

    /// List of images used by this ``PointAnnotationManager``.
    private(set) internal var allImages = Set<String>()
    private let imagesManager: AnnotationImagesManagerProtocol

    func syncImages() {
        let newImages = Set(annotations.compactMap(\.image))
        let newImageNames = Set(newImages.map(\.name))
        let unusedImages = allImages.subtracting(newImageNames)

        addImages(newImages)
        allImages = newImageNames

        removeImages(unusedImages)
    }

    func addImages(_ images: Set<PointAnnotation.Image>) {
        for image in images {
            imagesManager.addImage(image.image, id: image.name, sdf: false, contentInsets: .zero)
        }
    }

    func removeImages(_ names: Set<String>) {
        for imageName in names {
            imagesManager.removeImage(imageName)
        }
    }

    func removeAllImages() {
        let imagesToRemove = allImages
        allImages.removeAll()
        removeImages(imagesToRemove)
    }

    // MARK: - Common layer properties

    /// If true, the icon will be visible even if it collides with other previously drawn symbols.
    /// Default value: false.
    public var iconAllowOverlap: Bool? {
        get { impl.layerProperties["icon-allow-overlap"] as? Bool }
        set { impl.layerProperties["icon-allow-overlap"] = newValue }
    }

    /// If true, other symbols can be visible even if they collide with the icon.
    /// Default value: false.
    public var iconIgnorePlacement: Bool? {
        get { impl.layerProperties["icon-ignore-placement"] as? Bool }
        set { impl.layerProperties["icon-ignore-placement"] = newValue }
    }

    /// If true, the icon may be flipped to prevent it from being rendered upside-down.
    /// Default value: false.
    public var iconKeepUpright: Bool? {
        get { impl.layerProperties["icon-keep-upright"] as? Bool }
        set { impl.layerProperties["icon-keep-upright"] = newValue }
    }

    /// If true, text will display without their corresponding icons when the icon collides with other symbols and the text does not.
    /// Default value: false.
    public var iconOptional: Bool? {
        get { impl.layerProperties["icon-optional"] as? Bool }
        set { impl.layerProperties["icon-optional"] = newValue }
    }

    /// Size of the additional area around the icon bounding box used for detecting symbol collisions.
    /// Default value: 2. Minimum value: 0.
    public var iconPadding: Double? {
        get { impl.layerProperties["icon-padding"] as? Double }
        set { impl.layerProperties["icon-padding"] = newValue }
    }

    /// Orientation of icon when map is pitched.
    /// Default value: "auto".
    public var iconPitchAlignment: IconPitchAlignment? {
        get { impl.layerProperties["icon-pitch-alignment"].flatMap { $0 as? String }.flatMap(IconPitchAlignment.init(rawValue:)) }
        set { impl.layerProperties["icon-pitch-alignment"] = newValue?.rawValue }
    }

    /// In combination with `symbol-placement`, determines the rotation behavior of icons.
    /// Default value: "auto".
    public var iconRotationAlignment: IconRotationAlignment? {
        get { impl.layerProperties["icon-rotation-alignment"].flatMap { $0 as? String }.flatMap(IconRotationAlignment.init(rawValue:)) }
        set { impl.layerProperties["icon-rotation-alignment"] = newValue?.rawValue }
    }

    /// If true, the symbols will not cross tile edges to avoid mutual collisions. Recommended in layers that don't have enough padding in the vector tile to prevent collisions, or if it is a point symbol layer placed after a line symbol layer. When using a client that supports global collision detection, like Mapbox GL JS version 0.42.0 or greater, enabling this property is not needed to prevent clipped labels at tile boundaries.
    /// Default value: false.
    public var symbolAvoidEdges: Bool? {
        get { impl.layerProperties["symbol-avoid-edges"] as? Bool }
        set { impl.layerProperties["symbol-avoid-edges"] = newValue }
    }

    /// Label placement relative to its geometry.
    /// Default value: "point".
    public var symbolPlacement: SymbolPlacement? {
        get { impl.layerProperties["symbol-placement"].flatMap { $0 as? String }.flatMap(SymbolPlacement.init(rawValue:)) }
        set { impl.layerProperties["symbol-placement"] = newValue?.rawValue }
    }

    /// Distance between two symbol anchors.
    /// Default value: 250. Minimum value: 1.
    public var symbolSpacing: Double? {
        get { impl.layerProperties["symbol-spacing"] as? Double }
        set { impl.layerProperties["symbol-spacing"] = newValue }
    }

    /// Position symbol on buildings (both fill extrusions and models) rooftops. In order to have minimal impact on performance, this is supported only when `fill-extrusion-height` is not zoom-dependent and remains unchanged. For fading in buildings when zooming in, fill-extrusion-vertical-scale should be used and symbols would raise with building rooftops. Symbols are sorted by elevation, except in cases when `viewport-y` sorting or `symbol-sort-key` are applied.
    /// Default value: false.
    public var symbolZElevate: Bool? {
        get { impl.layerProperties["symbol-z-elevate"] as? Bool }
        set { impl.layerProperties["symbol-z-elevate"] = newValue }
    }

    /// Determines whether overlapping symbols in the same layer are rendered in the order that they appear in the data source or by their y-position relative to the viewport. To control the order and prioritization of symbols otherwise, use `symbol-sort-key`.
    /// Default value: "auto".
    public var symbolZOrder: SymbolZOrder? {
        get { impl.layerProperties["symbol-z-order"].flatMap { $0 as? String }.flatMap(SymbolZOrder.init(rawValue:)) }
        set { impl.layerProperties["symbol-z-order"] = newValue?.rawValue }
    }

    /// If true, the text will be visible even if it collides with other previously drawn symbols.
    /// Default value: false.
    public var textAllowOverlap: Bool? {
        get { impl.layerProperties["text-allow-overlap"] as? Bool }
        set { impl.layerProperties["text-allow-overlap"] = newValue }
    }

    /// Font stack to use for displaying text.
    public var textFont: [String]? {
        get { (impl.layerProperties["text-font"] as? [Any])?[1] as? [String] }
        set { impl.layerProperties["text-font"] = newValue.map { ["literal", $0] as [Any] } }
    }

    /// If true, other symbols can be visible even if they collide with the text.
    /// Default value: false.
    public var textIgnorePlacement: Bool? {
        get { impl.layerProperties["text-ignore-placement"] as? Bool }
        set { impl.layerProperties["text-ignore-placement"] = newValue }
    }

    /// If true, the text may be flipped vertically to prevent it from being rendered upside-down.
    /// Default value: true.
    public var textKeepUpright: Bool? {
        get { impl.layerProperties["text-keep-upright"] as? Bool }
        set { impl.layerProperties["text-keep-upright"] = newValue }
    }

    /// Maximum angle change between adjacent characters.
    /// Default value: 45.
    public var textMaxAngle: Double? {
        get { impl.layerProperties["text-max-angle"] as? Double }
        set { impl.layerProperties["text-max-angle"] = newValue }
    }

    /// If true, icons will display without their corresponding text when the text collides with other symbols and the icon does not.
    /// Default value: false.
    public var textOptional: Bool? {
        get { impl.layerProperties["text-optional"] as? Bool }
        set { impl.layerProperties["text-optional"] = newValue }
    }

    /// Size of the additional area around the text bounding box used for detecting symbol collisions.
    /// Default value: 2. Minimum value: 0.
    public var textPadding: Double? {
        get { impl.layerProperties["text-padding"] as? Double }
        set { impl.layerProperties["text-padding"] = newValue }
    }

    /// Orientation of text when map is pitched.
    /// Default value: "auto".
    public var textPitchAlignment: TextPitchAlignment? {
        get { impl.layerProperties["text-pitch-alignment"].flatMap { $0 as? String }.flatMap(TextPitchAlignment.init(rawValue:)) }
        set { impl.layerProperties["text-pitch-alignment"] = newValue?.rawValue }
    }

    /// In combination with `symbol-placement`, determines the rotation behavior of the individual glyphs forming the text.
    /// Default value: "auto".
    public var textRotationAlignment: TextRotationAlignment? {
        get { impl.layerProperties["text-rotation-alignment"].flatMap { $0 as? String }.flatMap(TextRotationAlignment.init(rawValue:)) }
        set { impl.layerProperties["text-rotation-alignment"] = newValue?.rawValue }
    }

    /// To increase the chance of placing high-priority labels on the map, you can provide an array of `text-anchor` locations: the renderer will attempt to place the label at each location, in order, before moving onto the next label. Use `text-justify: auto` to choose justification based on anchor position. To apply an offset, use the `text-radial-offset` or the two-dimensional `text-offset`.
    public var textVariableAnchor: [TextAnchor]? {
        get { impl.layerProperties["text-variable-anchor"].flatMap { $0 as? [String] }.flatMap { $0.compactMap(TextAnchor.init(rawValue:)) } }
        set { impl.layerProperties["text-variable-anchor"] = newValue?.map(\.rawValue) }
    }

    /// The property allows control over a symbol's orientation. Note that the property values act as a hint, so that a symbol whose language doesn’t support the provided orientation will be laid out in its natural orientation. Example: English point symbol will be rendered horizontally even if array value contains single 'vertical' enum value. For symbol with point placement, the order of elements in an array define priority order for the placement of an orientation variant. For symbol with line placement, the default text writing mode is either ['horizontal', 'vertical'] or ['vertical', 'horizontal'], the order doesn't affect the placement.
    public var textWritingMode: [TextWritingMode]? {
        get { impl.layerProperties["text-writing-mode"].flatMap { $0 as? [String] }.flatMap { $0.compactMap(TextWritingMode.init(rawValue:)) } }
        set { impl.layerProperties["text-writing-mode"] = newValue?.map(\.rawValue) }
    }

    /// Increase or reduce the saturation of the symbol icon.
    /// Default value: 0. Value range: [-1, 1]
    public var iconColorSaturation: Double? {
        get { impl.layerProperties["icon-color-saturation"] as? Double }
        set { impl.layerProperties["icon-color-saturation"] = newValue }
    }

    /// Distance that the icon's anchor is moved from its original placement. Positive values indicate right and down, while negative values indicate left and up.
    /// Default value: [0,0].
    public var iconTranslate: [Double]? {
        get { impl.layerProperties["icon-translate"] as? [Double] }
        set { impl.layerProperties["icon-translate"] = newValue }
    }

    /// Controls the frame of reference for `icon-translate`.
    /// Default value: "map".
    public var iconTranslateAnchor: IconTranslateAnchor? {
        get { impl.layerProperties["icon-translate-anchor"].flatMap { $0 as? String }.flatMap(IconTranslateAnchor.init(rawValue:)) }
        set { impl.layerProperties["icon-translate-anchor"] = newValue?.rawValue }
    }

    /// Distance that the text's anchor is moved from its original placement. Positive values indicate right and down, while negative values indicate left and up.
    /// Default value: [0,0].
    public var textTranslate: [Double]? {
        get { impl.layerProperties["text-translate"] as? [Double] }
        set { impl.layerProperties["text-translate"] = newValue }
    }

    /// Controls the frame of reference for `text-translate`.
    /// Default value: "map".
    public var textTranslateAnchor: TextTranslateAnchor? {
        get { impl.layerProperties["text-translate-anchor"].flatMap { $0 as? String }.flatMap(TextTranslateAnchor.init(rawValue:)) }
        set { impl.layerProperties["text-translate-anchor"] = newValue?.rawValue }
    }

    /// Slot for the underlying layer.
    ///
    /// Use this property to position the annotations relative to other map features if you use Mapbox Standard Style.
    /// See <doc:Migrate-to-v11##21-The-Mapbox-Standard-Style> for more info.
    public var slot: String? {
        get { impl.layerProperties["slot"] as? String }
        set { impl.layerProperties["slot"] = newValue }
    }

    /// Scales the icon to fit around the associated text.
    @available(*, deprecated, message: "icon-text-fit property is now data driven, use `PointAnnotation.iconTextFit` instead.")
    public var iconTextFit: IconTextFit? {
        get { impl.layerProperties["icon-text-fit"].flatMap { $0 as? String }.flatMap(IconTextFit.init(rawValue:)) }
        set { impl.layerProperties["icon-text-fit"] = newValue?.rawValue }
    }

    /// Size of the additional area added to dimensions determined by `icon-text-fit`, in clockwise order: top, right, bottom, left.
    @available(*, deprecated, message: "icon-text-fit-padding property is now data driven, use `PointAnnotation.iconTextFitPadding` instead.")
    public var iconTextFitPadding: [Double]? {
        get {impl.layerProperties["icon-text-fit-padding"] as? [Double] }
        set { impl.layerProperties["icon-text-fit-padding"] = newValue }
    }

    /// The opacity at which the icon will be drawn in case of being depth occluded. Absent value means full occlusion against terrain only.
    /// Default value: 0. Value range: [0, 1]
    @available(*, deprecated, message: "icon-occlusion-opacity property is now data driven, use `PointAnnotation.iconOcclusionOpacity` instead.")
    public var iconOcclusionOpacity: Double? {
        get { impl.layerProperties["icon-occlusion-opacity"] as? Double }
        set { impl.layerProperties["icon-occlusion-opacity"] = newValue }
    }
    /// The opacity at which the text will be drawn in case of being depth occluded. Absent value means full occlusion against terrain only.
    /// Default value: 0. Value range: [0, 1]
    @available(*, deprecated, message: "text-occlusion-opacity property is now data driven, use `PointAnnotation.textOcclusionOpacity` instead.")
    public var textOcclusionOpacity: Double? {
        get { impl.layerProperties["text-occlusion-opacity"] as? Double }
        set { impl.layerProperties["text-occlusion-opacity"] = newValue }
    }
}

// End of generated file.
