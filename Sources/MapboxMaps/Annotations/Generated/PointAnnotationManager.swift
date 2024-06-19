// This file is generated.
import Foundation
import os
@_implementationOnly import MapboxCommon_Private
/// An instance of `PointAnnotationManager` is responsible for a collection of `PointAnnotation`s.
public class PointAnnotationManager: AnnotationManagerInternal {
    typealias OffsetCalculatorType = OffsetPointCalculator

    public var sourceId: String { id }

    public var layerId: String { id }

    private var dragId: String { "\(id)_drag" }

    private var clusterId: String { "mapbox-iOS-cluster-circle-layer-manager-\(id)" }

    public let id: String

    var layerPosition: LayerPosition? {
        didSet {
            do {
                try style.moveLayer(withId: layerId, to: layerPosition ?? .default)
            } catch {
                Log.error(forMessage: "Failed to mover layer to a new position. Error: \(error)", category: "Annotations")
            }
        }
    }

    /// The collection of ``PointAnnotation`` being managed.
    ///
    /// Each annotation must have a unique identifier. Duplicate IDs will cause only the first annotation to be displayed, while the rest will be ignored.
    public var annotations: [PointAnnotation] {
        get { mainAnnotations + draggedAnnotations }
        set {
            mainAnnotations = newValue
            mainAnnotations.removeDuplicates()
            draggedAnnotations.removeAll(keepingCapacity: true)
            draggedAnnotationIndex = nil
        }
    }

    /// Set this delegate in order to be called back if a tap occurs on an annotation being managed by this manager.
    /// - NOTE: This annotation manager listens to tap events via the `GestureManager.singleTapGestureRecognizer`.
    @available(*, deprecated, message: "Use tapHandler property of Annotation")
    public weak var delegate: AnnotationInteractionDelegate? {
        get { _delegate }
        set { _delegate = newValue }
    }
    private weak var _delegate: AnnotationInteractionDelegate?

    // Deps
    private let style: StyleProtocol
    private let offsetCalculator: OffsetCalculatorType

    // Private state

    /// Currently displayed (synced) annotations.
    private var displayedAnnotations: [PointAnnotation] = []

    /// Updated, non-moved annotations. On next display link they will be diffed with `displayedAnnotations` and updated.
    private var mainAnnotations = [PointAnnotation]() {
        didSet { syncSourceOnce.reset() }
    }

    /// When annotation is moved for the first time, it migrates to this array from mainAnnotations.
    private var draggedAnnotations = [PointAnnotation]() {
        didSet {
            if insertDraggedLayerAndSourceOnce.happened {
                // Update dragged annotation only when the drag layer is created.
                syncDragSourceOnce.reset()
            }
        }
    }

    /// Storage for common layer properties
    var layerProperties: [String: Any] = [:] {
        didSet {
            syncLayerOnce.reset()
        }
    }

    /// The keys of the style properties that were set during the previous sync.
    /// Used to identify which styles need to be restored to their default values in
    /// the subsequent sync.
    private var previouslySetLayerPropertyKeys: Set<String> = []

    private var draggedAnnotationIndex: Array<PointAnnotation>.Index?
    private var destroyOnce = Once()
    private var syncSourceOnce = Once(happened: true)
    private var syncDragSourceOnce = Once(happened: true)
    private var syncLayerOnce = Once(happened: true)
    private var insertDraggedLayerAndSourceOnce = Once()
    private var displayLinkToken: AnyCancelable?

    /// List of images used by this ``PointAnnotationManager``.
    private(set) internal var allImages = Set<String>()
    private let imagesManager: AnnotationImagesManagerProtocol
    private var clusterOptions: ClusterOptions?
    private let mapFeatureQueryable: MapFeatureQueryable

    public var onClusterTap: ((AnnotationClusterGestureContext) -> Void)?
    public var onClusterLongPress: ((AnnotationClusterGestureContext) -> Void)?
    var allLayerIds: [String] { [layerId, dragId, clusterId] }

    /// In SwiftUI isDraggable and isSelected are disabled.
    var isSwiftUI = false

    init(id: String,
         style: StyleProtocol,
         layerPosition: LayerPosition?,
         displayLink: Signal<Void>,
         clusterOptions: ClusterOptions? = nil,
         mapFeatureQueryable: MapFeatureQueryable,
         imagesManager: AnnotationImagesManagerProtocol,
         offsetCalculator: OffsetCalculatorType
    ) {
        self.id = id
        self.style = style
        self.offsetCalculator = offsetCalculator

        self.clusterOptions = clusterOptions
        self.imagesManager = imagesManager
        self.mapFeatureQueryable = mapFeatureQueryable
        imagesManager.register(imagesConsumer: self)
        do {
            // Add the source with empty `data` property
            var source = GeoJSONSource(id: sourceId)

            // Set cluster options and create clusters if clustering is enabled
            if let clusterOptions = clusterOptions {
                source.cluster = true
                source.clusterRadius = clusterOptions.clusterRadius
                source.clusterProperties = clusterOptions.clusterProperties
                source.clusterMaxZoom = clusterOptions.clusterMaxZoom
                source.clusterMinPoints = clusterOptions.clusterMinPoints
            }

            try style.addSource(source)

            if let clusterOptions = clusterOptions {
                createClusterLayers(clusterOptions: clusterOptions)
            }

            // Add the correct backing layer for this annotation type
            var layer = SymbolLayer(id: layerId, source: sourceId)

            // Show all icons and texts by default in point annotations.
            layer.iconAllowOverlap = .constant(true)
            layer.textAllowOverlap = .constant(true)
            layer.iconIgnorePlacement = .constant(true)
            layer.textIgnorePlacement = .constant(true)
            try style.addPersistentLayer(layer, layerPosition: layerPosition)
        } catch {
            Log.error(
                forMessage: "Failed to create source / layer in PointAnnotationManager. Error: \(error)",
                category: "Annotations")
        }

        displayLinkToken = displayLink.observe { [weak self] in
            self?.syncSourceAndLayerIfNeeded()
        }
    }

    private func createClusterLayers(clusterOptions: ClusterOptions) {
        let clusterLevelLayer = createClusterLevelLayer(clusterOptions: clusterOptions)
        let clusterTextLayer = createClusterTextLayer(clusterOptions: clusterOptions)
        do {
            try addClusterLayer(clusterLayer: clusterLevelLayer)
            try addClusterLayer(clusterLayer: clusterTextLayer)
        } catch {
            Log.error(
                forMessage: "Failed to add cluster layer in PointAnnotationManager. Error: \(error)",
                category: "Annotations")
        }
    }

    private func addClusterLayer(clusterLayer: Layer) throws {
        guard style.layerExists(withId: clusterLayer.id) else {
            try style.addPersistentLayer(clusterLayer, layerPosition: .default)
            return
        }
    }

    private func createClusterLevelLayer(clusterOptions: ClusterOptions) -> CircleLayer {
        let layedID = "mapbox-iOS-cluster-circle-layer-manager-" + id
        var circleLayer = CircleLayer(id: layedID, source: sourceId)
        circleLayer.circleColor = clusterOptions.circleColor
        circleLayer.circleRadius = clusterOptions.circleRadius
        circleLayer.filter = Exp(.has) { "point_count" }
        return circleLayer
    }

    private func createClusterTextLayer(clusterOptions: ClusterOptions) -> SymbolLayer {
        let layerID = "mapbox-iOS-cluster-text-layer-manager-" + id
        var symbolLayer = SymbolLayer(id: layerID, source: sourceId)
        symbolLayer.textField = clusterOptions.textField
        symbolLayer.textSize = clusterOptions.textSize
        symbolLayer.textColor = clusterOptions.textColor
        return symbolLayer
    }

    private func destroyClusterLayers() {
        do {
            try style.removeLayer(withId: "mapbox-iOS-cluster-circle-layer-manager-" + id)
            try style.removeLayer(withId: "mapbox-iOS-cluster-text-layer-manager-" + id)
        } catch {
            Log.error(
                forMessage: "Failed to remove cluster layer in PointAnnotationManager. Error: \(error)",
                category: "Annotations")
        }
    }

    var idsMap = [AnyHashable: String]()

    func set(newAnnotations: [(AnyHashable, PointAnnotation)]) {
        var resolvedAnnotations = [PointAnnotation]()
        newAnnotations.forEach { elementId, annotation in
            var annotation = annotation
            let stringId = idsMap[elementId] ?? annotation.id
            idsMap[elementId] = stringId
            annotation.id = stringId
            annotation.isDraggable = false
            annotation.isSelected = false
            resolvedAnnotations.append(annotation)
        }
        annotations = resolvedAnnotations
    }

    func destroy() {
        guard destroyOnce.continueOnce() else { return }

        displayLinkToken?.cancel()

        if clusterOptions != nil {
            destroyClusterLayers()
        }

        func wrapError(_ what: String, _ body: () throws -> Void) {
            do {
                try body()
            } catch {
                Log.warning(
                    forMessage: "Failed to remove \(what) for PointAnnotationManager with id \(id) due to error: \(error)",
                    category: "Annotations")
            }
        }

        wrapError("layer") {
            try style.removeLayer(withId: layerId)
        }

        wrapError("source") {
            try style.removeSource(withId: sourceId)
        }

        if insertDraggedLayerAndSourceOnce.happened {
            wrapError("drag source and layer") {
                try style.removeLayer(withId: dragId)
                try style.removeSource(withId: dragId)
            }
        }

        removeAllImages()
    }

    // MARK: - Sync annotations to map

    private func syncSource() {
        guard syncSourceOnce.continueOnce() else { return }

        let diff = mainAnnotations.diff(from: displayedAnnotations, id: \.id)
        syncLayerOnce.reset(if: !diff.isEmpty)
        style.apply(annotationsDiff: diff, sourceId: sourceId, feature: \.feature)
        displayedAnnotations = mainAnnotations
    }

    private func syncDragSource() {
        guard syncDragSourceOnce.continueOnce() else { return }

        let fc = FeatureCollection(features: draggedAnnotations.map(\.feature))
        style.updateGeoJSONSource(withId: dragId, geoJSON: .featureCollection(fc))
    }

    private func syncLayer() {
        guard syncLayerOnce.continueOnce() else { return }

        let newImages = Set(annotations.compactMap(\.image))
        let newImageNames = Set(newImages.map(\.name))
        let unusedImages = allImages.subtracting(newImageNames)

        addImages(newImages)
        allImages = newImageNames

        removeImages(unusedImages)

        // Construct the properties dictionary from the annotations
        let dataDrivenLayerPropertyKeys = Set(annotations.flatMap(\.layerProperties.keys))
        let dataDrivenProperties = Dictionary(
            uniqueKeysWithValues: dataDrivenLayerPropertyKeys
                .map { (key) -> (String, Any) in
                    (key, ["get", key, ["get", "layerProperties"]] as [Any])
                })

        // Merge the common layer properties
        let newLayerProperties = dataDrivenProperties.merging(layerProperties, uniquingKeysWith: { $1 })

        // Construct the properties dictionary to reset any properties that are no longer used
        let unusedPropertyKeys = previouslySetLayerPropertyKeys.subtracting(newLayerProperties.keys)
        let unusedProperties = Dictionary(uniqueKeysWithValues: unusedPropertyKeys.map { (key) -> (String, Any) in
            (key, StyleManager.layerPropertyDefaultValue(for: .symbol, property: key).value)
        })

        // Store the new set of property keys
        previouslySetLayerPropertyKeys = Set(newLayerProperties.keys)

        // Merge the new and unused properties
        let allLayerProperties = newLayerProperties.merging(unusedProperties, uniquingKeysWith: { $1 })

        // make a single call into MapboxCoreMaps to set layer properties
        do {
            try style.setLayerProperties(for: layerId, properties: allLayerProperties)
            if !draggedAnnotations.isEmpty {
                try style.setLayerProperties(for: dragId, properties: allLayerProperties)
            }
        } catch {
            Log.error(
                forMessage: "Could not set layer properties in PointAnnotationManager due to error \(error)",
                category: "Annotations")
        }
    }

    func syncSourceAndLayerIfNeeded() {
        guard !destroyOnce.happened else { return }

        OSLog.platform.withIntervalSignpost(SignpostName.mapViewDisplayLink, "Participant: PointAnnotationManager") {
            syncSource()
            syncDragSource()
            syncLayer()
        }
    }

    // MARK: - Common layer properties

    /// If true, the icon will be visible even if it collides with other previously drawn symbols.
    /// Default value: false.
    public var iconAllowOverlap: Bool? {
        get {
            return layerProperties["icon-allow-overlap"] as? Bool
        }
        set {
            layerProperties["icon-allow-overlap"] = newValue
        }
    }

    /// If true, other symbols can be visible even if they collide with the icon.
    /// Default value: false.
    public var iconIgnorePlacement: Bool? {
        get {
            return layerProperties["icon-ignore-placement"] as? Bool
        }
        set {
            layerProperties["icon-ignore-placement"] = newValue
        }
    }

    /// If true, the icon may be flipped to prevent it from being rendered upside-down.
    /// Default value: false.
    public var iconKeepUpright: Bool? {
        get {
            return layerProperties["icon-keep-upright"] as? Bool
        }
        set {
            layerProperties["icon-keep-upright"] = newValue
        }
    }

    /// If true, text will display without their corresponding icons when the icon collides with other symbols and the text does not.
    /// Default value: false.
    public var iconOptional: Bool? {
        get {
            return layerProperties["icon-optional"] as? Bool
        }
        set {
            layerProperties["icon-optional"] = newValue
        }
    }

    /// Size of the additional area around the icon bounding box used for detecting symbol collisions.
    /// Default value: 2. Minimum value: 0.
    public var iconPadding: Double? {
        get {
            return layerProperties["icon-padding"] as? Double
        }
        set {
            layerProperties["icon-padding"] = newValue
        }
    }

    /// Orientation of icon when map is pitched.
    /// Default value: "auto".
    public var iconPitchAlignment: IconPitchAlignment? {
        get {
            return layerProperties["icon-pitch-alignment"].flatMap { $0 as? String }.flatMap(IconPitchAlignment.init(rawValue:))
        }
        set {
            layerProperties["icon-pitch-alignment"] = newValue?.rawValue
        }
    }

    /// In combination with `symbol-placement`, determines the rotation behavior of icons.
    /// Default value: "auto".
    public var iconRotationAlignment: IconRotationAlignment? {
        get {
            return layerProperties["icon-rotation-alignment"].flatMap { $0 as? String }.flatMap(IconRotationAlignment.init(rawValue:))
        }
        set {
            layerProperties["icon-rotation-alignment"] = newValue?.rawValue
        }
    }

    /// If true, the symbols will not cross tile edges to avoid mutual collisions. Recommended in layers that don't have enough padding in the vector tile to prevent collisions, or if it is a point symbol layer placed after a line symbol layer. When using a client that supports global collision detection, like Mapbox GL JS version 0.42.0 or greater, enabling this property is not needed to prevent clipped labels at tile boundaries.
    /// Default value: false.
    public var symbolAvoidEdges: Bool? {
        get {
            return layerProperties["symbol-avoid-edges"] as? Bool
        }
        set {
            layerProperties["symbol-avoid-edges"] = newValue
        }
    }

    /// Label placement relative to its geometry.
    /// Default value: "point".
    public var symbolPlacement: SymbolPlacement? {
        get {
            return layerProperties["symbol-placement"].flatMap { $0 as? String }.flatMap(SymbolPlacement.init(rawValue:))
        }
        set {
            layerProperties["symbol-placement"] = newValue?.rawValue
        }
    }

    /// Distance between two symbol anchors.
    /// Default value: 250. Minimum value: 1.
    public var symbolSpacing: Double? {
        get {
            return layerProperties["symbol-spacing"] as? Double
        }
        set {
            layerProperties["symbol-spacing"] = newValue
        }
    }

    /// Position symbol on buildings (both fill extrusions and models) rooftops. In order to have minimal impact on performance, this is supported only when `fill-extrusion-height` is not zoom-dependent and remains unchanged. For fading in buildings when zooming in, fill-extrusion-vertical-scale should be used and symbols would raise with building rooftops. Symbols are sorted by elevation, except in cases when `viewport-y` sorting or `symbol-sort-key` are applied.
    /// Default value: false.
    public var symbolZElevate: Bool? {
        get {
            return layerProperties["symbol-z-elevate"] as? Bool
        }
        set {
            layerProperties["symbol-z-elevate"] = newValue
        }
    }

    /// Determines whether overlapping symbols in the same layer are rendered in the order that they appear in the data source or by their y-position relative to the viewport. To control the order and prioritization of symbols otherwise, use `symbol-sort-key`.
    /// Default value: "auto".
    public var symbolZOrder: SymbolZOrder? {
        get {
            return layerProperties["symbol-z-order"].flatMap { $0 as? String }.flatMap(SymbolZOrder.init(rawValue:))
        }
        set {
            layerProperties["symbol-z-order"] = newValue?.rawValue
        }
    }

    /// If true, the text will be visible even if it collides with other previously drawn symbols.
    /// Default value: false.
    public var textAllowOverlap: Bool? {
        get {
            return layerProperties["text-allow-overlap"] as? Bool
        }
        set {
            layerProperties["text-allow-overlap"] = newValue
        }
    }

    /// Font stack to use for displaying text.
    public var textFont: [String]? {
        get {
            return (layerProperties["text-font"] as? [Any])?[1] as? [String]
        }
        set {
            layerProperties["text-font"] = newValue.map { ["literal", $0] as [Any] }
        }
    }

    /// If true, other symbols can be visible even if they collide with the text.
    /// Default value: false.
    public var textIgnorePlacement: Bool? {
        get {
            return layerProperties["text-ignore-placement"] as? Bool
        }
        set {
            layerProperties["text-ignore-placement"] = newValue
        }
    }

    /// If true, the text may be flipped vertically to prevent it from being rendered upside-down.
    /// Default value: true.
    public var textKeepUpright: Bool? {
        get {
            return layerProperties["text-keep-upright"] as? Bool
        }
        set {
            layerProperties["text-keep-upright"] = newValue
        }
    }

    /// Maximum angle change between adjacent characters.
    /// Default value: 45.
    public var textMaxAngle: Double? {
        get {
            return layerProperties["text-max-angle"] as? Double
        }
        set {
            layerProperties["text-max-angle"] = newValue
        }
    }

    /// If true, icons will display without their corresponding text when the text collides with other symbols and the icon does not.
    /// Default value: false.
    public var textOptional: Bool? {
        get {
            return layerProperties["text-optional"] as? Bool
        }
        set {
            layerProperties["text-optional"] = newValue
        }
    }

    /// Size of the additional area around the text bounding box used for detecting symbol collisions.
    /// Default value: 2. Minimum value: 0.
    public var textPadding: Double? {
        get {
            return layerProperties["text-padding"] as? Double
        }
        set {
            layerProperties["text-padding"] = newValue
        }
    }

    /// Orientation of text when map is pitched.
    /// Default value: "auto".
    public var textPitchAlignment: TextPitchAlignment? {
        get {
            return layerProperties["text-pitch-alignment"].flatMap { $0 as? String }.flatMap(TextPitchAlignment.init(rawValue:))
        }
        set {
            layerProperties["text-pitch-alignment"] = newValue?.rawValue
        }
    }

    /// In combination with `symbol-placement`, determines the rotation behavior of the individual glyphs forming the text.
    /// Default value: "auto".
    public var textRotationAlignment: TextRotationAlignment? {
        get {
            return layerProperties["text-rotation-alignment"].flatMap { $0 as? String }.flatMap(TextRotationAlignment.init(rawValue:))
        }
        set {
            layerProperties["text-rotation-alignment"] = newValue?.rawValue
        }
    }

    /// To increase the chance of placing high-priority labels on the map, you can provide an array of `text-anchor` locations: the renderer will attempt to place the label at each location, in order, before moving onto the next label. Use `text-justify: auto` to choose justification based on anchor position. To apply an offset, use the `text-radial-offset` or the two-dimensional `text-offset`.
    public var textVariableAnchor: [TextAnchor]? {
        get {
            return layerProperties["text-variable-anchor"].flatMap { $0 as? [String] }.flatMap { $0.compactMap(TextAnchor.init(rawValue:)) }
        }
        set {
            layerProperties["text-variable-anchor"] = newValue?.map(\.rawValue)
        }
    }

    /// The property allows control over a symbol's orientation. Note that the property values act as a hint, so that a symbol whose language doesn’t support the provided orientation will be laid out in its natural orientation. Example: English point symbol will be rendered horizontally even if array value contains single 'vertical' enum value. For symbol with point placement, the order of elements in an array define priority order for the placement of an orientation variant. For symbol with line placement, the default text writing mode is either ['horizontal', 'vertical'] or ['vertical', 'horizontal'], the order doesn't affect the placement.
    public var textWritingMode: [TextWritingMode]? {
        get {
            return layerProperties["text-writing-mode"].flatMap { $0 as? [String] }.flatMap { $0.compactMap(TextWritingMode.init(rawValue:)) }
        }
        set {
            layerProperties["text-writing-mode"] = newValue?.map(\.rawValue)
        }
    }

    /// Increase or reduce the saturation of the symbol icon.
    /// Default value: 0. Value range: [-1, 1]
    public var iconColorSaturation: Double? {
        get {
            return layerProperties["icon-color-saturation"] as? Double
        }
        set {
            layerProperties["icon-color-saturation"] = newValue
        }
    }

    /// The opacity at which the icon will be drawn in case of being depth occluded. Not supported on globe zoom levels.
    /// Default value: 1. Value range: [0, 1]
    public var iconOcclusionOpacity: Double? {
        get {
            return layerProperties["icon-occlusion-opacity"] as? Double
        }
        set {
            layerProperties["icon-occlusion-opacity"] = newValue
        }
    }

    /// Distance that the icon's anchor is moved from its original placement. Positive values indicate right and down, while negative values indicate left and up.
    /// Default value: [0,0].
    public var iconTranslate: [Double]? {
        get {
            return layerProperties["icon-translate"] as? [Double]
        }
        set {
            layerProperties["icon-translate"] = newValue
        }
    }

    /// Controls the frame of reference for `icon-translate`.
    /// Default value: "map".
    public var iconTranslateAnchor: IconTranslateAnchor? {
        get {
            return layerProperties["icon-translate-anchor"].flatMap { $0 as? String }.flatMap(IconTranslateAnchor.init(rawValue:))
        }
        set {
            layerProperties["icon-translate-anchor"] = newValue?.rawValue
        }
    }

    /// The opacity at which the text will be drawn in case of being depth occluded. Not supported on globe zoom levels.
    /// Default value: 1. Value range: [0, 1]
    public var textOcclusionOpacity: Double? {
        get {
            return layerProperties["text-occlusion-opacity"] as? Double
        }
        set {
            layerProperties["text-occlusion-opacity"] = newValue
        }
    }

    /// Distance that the text's anchor is moved from its original placement. Positive values indicate right and down, while negative values indicate left and up.
    /// Default value: [0,0].
    public var textTranslate: [Double]? {
        get {
            return layerProperties["text-translate"] as? [Double]
        }
        set {
            layerProperties["text-translate"] = newValue
        }
    }

    /// Controls the frame of reference for `text-translate`.
    /// Default value: "map".
    public var textTranslateAnchor: TextTranslateAnchor? {
        get {
            return layerProperties["text-translate-anchor"].flatMap { $0 as? String }.flatMap(TextTranslateAnchor.init(rawValue:))
        }
        set {
            layerProperties["text-translate-anchor"] = newValue?.rawValue
        }
    }

    /// Slot for the underlying layer.
    ///
    /// Use this property to position the annotations relative to other map features if you use Mapbox Standard Style.
    /// See <doc:Migrate-to-v11##21-The-Mapbox-Standard-Style> for more info.
    public var slot: String? {
        get {
            return layerProperties["slot"] as? String
        }
        set {
            layerProperties["slot"] = newValue
        }
    }

    /// Scales the icon to fit around the associated text.
    @available(*, deprecated, message: "icon-text-fit property is now data driven, use `PointAnnotation.iconTextFit` instead.")
    public var iconTextFit: IconTextFit? {
        get {
            return layerProperties["icon-text-fit"].flatMap { $0 as? String }.flatMap(IconTextFit.init(rawValue:))
        }
        set {
            layerProperties["icon-text-fit"] = newValue?.rawValue
        }
    }

    /// Size of the additional area added to dimensions determined by `icon-text-fit`, in clockwise order: top, right, bottom, left.
    @available(*, deprecated, message: "icon-text-fit-padding property is now data driven, use `PointAnnotation.iconTextFitPadding` instead.")
    public var iconTextFitPadding: [Double]? {
        get {
            return layerProperties["icon-text-fit-padding"] as? [Double]
        }
        set {
            layerProperties["icon-text-fit-padding"] = newValue
        }
    }

    // MARK: - User interaction handling

    private var queryToken: AnyCancelable?
    private func queryAnnotationClusterContext(
        feature: Feature,
        context: MapContentGestureContext,
        completion: @escaping (Result<AnnotationClusterGestureContext, Error>) -> Void
    ) {
        queryToken = mapFeatureQueryable
            .getAnnotationClusterContext(layerId: id, feature: feature, context: context, completion: completion)
            .erased
    }

    func handleTap(layerId: String, feature: Feature, context: MapContentGestureContext) -> Bool {
        if layerId == clusterId, let onClusterTap {
            queryAnnotationClusterContext(feature: feature, context: context) { result in
                if case let .success(clusterContext) = result {
                    onClusterTap(clusterContext)
                }
            }
            return true
        }

        guard let featureId = feature.identifier?.string else { return false }

        let tappedIndex = annotations.firstIndex { $0.id == featureId }
        guard let tappedIndex else { return false }
        var tappedAnnotation = annotations[tappedIndex]

        tappedAnnotation.isSelected.toggle()

        if !isSwiftUI {
            // In-place update of annotations is not supported in SwiftUI.
            // Use the .onTapGesture {} to update annotations on call side.
            self.annotations[tappedIndex] = tappedAnnotation
        }

        _delegate?.annotationManager(
            self,
            didDetectTappedAnnotations: [tappedAnnotation])

        return tappedAnnotation.tapHandler?(context) ?? false
    }

    func handleLongPress(layerId: String, feature: Feature, context: MapContentGestureContext) -> Bool {
        if layerId == clusterId, let onClusterLongPress {
            queryAnnotationClusterContext(feature: feature, context: context) { result in
                if case let .success(clusterContext) = result {
                    onClusterLongPress(clusterContext)
                }
            }
            return true
        }
        guard let featureId = feature.identifier?.string else { return false }

        return annotations.first { $0.id == featureId }?.longPressHandler?(context) ?? false
    }

    func handleDragBegin(with featureId: String, context: MapContentGestureContext) -> Bool {
        guard !isSwiftUI else { return false }

        func predicate(annotation: PointAnnotation) -> Bool {
            annotation.id == featureId && annotation.isDraggable
        }

        func tryBeginDragging(_ annotations: inout [PointAnnotation], idx: Int) -> Bool {
            var annotation = annotations[idx]
            // If no drag handler set, the dragging is allowed
            let dragAllowed = annotation.dragBeginHandler?(&annotation, context) ?? true
            annotations[idx] = annotation
            return dragAllowed
        }

        /// First, try to drag annotations that are already on the dragging layer.
        if let idx = draggedAnnotations.firstIndex(where: predicate) {
            let dragAllowed = tryBeginDragging(&draggedAnnotations, idx: idx)
            guard dragAllowed else {
                return false
            }

            draggedAnnotationIndex = idx
            return true
        }

        /// Then, try to start dragging from the main set of annotations.
        if let idx = mainAnnotations.lastIndex(where: predicate) {
            let dragAllowed = tryBeginDragging(&mainAnnotations, idx: idx)
            guard dragAllowed else {
                return false
            }

            insertDraggedLayerAndSource()

            let annotation = mainAnnotations.remove(at: idx)
            draggedAnnotations.append(annotation)
            draggedAnnotationIndex = draggedAnnotations.endIndex - 1
            return true
        }

        return false
    }

    private func insertDraggedLayerAndSource() {
        insertDraggedLayerAndSourceOnce {
            let source = GeoJSONSource(id: dragId)
            let layer = SymbolLayer(id: dragId, source: dragId)
            do {
                try style.addSource(source)
                try style.addPersistentLayer(layer, layerPosition: .above(layerId))
            } catch {
                Log.error(forMessage: "Add drag source/layer \(error)", category: "Annotations")
            }
        }
    }

    func handleDragChange(with translation: CGPoint, context: MapContentGestureContext) {
        guard !isSwiftUI,
              let draggedAnnotationIndex,
              draggedAnnotationIndex < draggedAnnotations.endIndex,
              let point = offsetCalculator.geometry(for: translation, from: draggedAnnotations[draggedAnnotationIndex].point) else {
            return
        }

        draggedAnnotations[draggedAnnotationIndex].point = point

        callDragHandler(\.dragChangeHandler, context: context)
    }

    func handleDragEnd(context: MapContentGestureContext) {
        guard !isSwiftUI else { return }
        callDragHandler(\.dragEndHandler, context: context)
        draggedAnnotationIndex = nil
    }

    private func callDragHandler(
        _ keyPath: KeyPath<PointAnnotation, ((inout PointAnnotation, MapContentGestureContext) -> Void)?>,
        context: MapContentGestureContext
    ) {
        guard let draggedAnnotationIndex, draggedAnnotationIndex < draggedAnnotations.endIndex else {
            return
        }

        if let handler = draggedAnnotations[draggedAnnotationIndex][keyPath: keyPath] {
            var copy = draggedAnnotations[draggedAnnotationIndex]
            handler(&copy, context)
            draggedAnnotations[draggedAnnotationIndex] = copy
        }
    }
}

private extension PointAnnotationManager {

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
}

// End of generated file.
