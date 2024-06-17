// This file is generated.
import Foundation
import os
@_implementationOnly import MapboxCommon_Private
/// An instance of `CircleAnnotationManager` is responsible for a collection of `CircleAnnotation`s.
public class CircleAnnotationManager: AnnotationManagerInternal {
    typealias OffsetCalculatorType = OffsetPointCalculator

    public var sourceId: String { id }

    public var layerId: String { id }

    private var dragId: String { "\(id)_drag" }

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

    /// The collection of ``CircleAnnotation`` being managed.
    ///
    /// Each annotation must have a unique identifier. Duplicate IDs will cause only the first annotation to be displayed, while the rest will be ignored.
    public var annotations: [CircleAnnotation] {
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
    private var displayedAnnotations: [CircleAnnotation] = []

    /// Updated, non-moved annotations. On next display link they will be diffed with `displayedAnnotations` and updated.
    private var mainAnnotations = [CircleAnnotation]() {
        didSet { syncSourceOnce.reset() }
    }

    /// When annotation is moved for the first time, it migrates to this array from mainAnnotations.
    private var draggedAnnotations = [CircleAnnotation]() {
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

    private var draggedAnnotationIndex: Array<CircleAnnotation>.Index?
    private var destroyOnce = Once()
    private var syncSourceOnce = Once(happened: true)
    private var syncDragSourceOnce = Once(happened: true)
    private var syncLayerOnce = Once(happened: true)
    private var insertDraggedLayerAndSourceOnce = Once()
    private var displayLinkToken: AnyCancelable?

    var allLayerIds: [String] { [layerId, dragId] }

    /// In SwiftUI isDraggable and isSelected are disabled.
    var isSwiftUI = false

    init(id: String,
         style: StyleProtocol,
         layerPosition: LayerPosition?,
         displayLink: Signal<Void>,
         offsetCalculator: OffsetCalculatorType
    ) {
        self.id = id
        self.style = style
        self.offsetCalculator = offsetCalculator

        do {
            // Add the source with empty `data` property
            let source = GeoJSONSource(id: sourceId)
            try style.addSource(source)

            // Add the correct backing layer for this annotation type
            let layer = CircleLayer(id: layerId, source: sourceId)
            try style.addPersistentLayer(layer, layerPosition: layerPosition)
        } catch {
            Log.error(
                forMessage: "Failed to create source / layer in CircleAnnotationManager. Error: \(error)",
                category: "Annotations")
        }

        displayLinkToken = displayLink.observe { [weak self] in
            self?.syncSourceAndLayerIfNeeded()
        }
    }

    var idsMap = [AnyHashable: String]()

    func set(newAnnotations: [(AnyHashable, CircleAnnotation)]) {
        var resolvedAnnotations = [CircleAnnotation]()
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

        func wrapError(_ what: String, _ body: () throws -> Void) {
            do {
                try body()
            } catch {
                Log.warning(
                    forMessage: "Failed to remove \(what) for CircleAnnotationManager with id \(id) due to error: \(error)",
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
            (key, StyleManager.layerPropertyDefaultValue(for: .circle, property: key).value)
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
                forMessage: "Could not set layer properties in CircleAnnotationManager due to error \(error)",
                category: "Annotations")
        }
    }

    func syncSourceAndLayerIfNeeded() {
        guard !destroyOnce.happened else { return }

        OSLog.platform.withIntervalSignpost(SignpostName.mapViewDisplayLink, "Participant: CircleAnnotationManager") {
            syncSource()
            syncDragSource()
            syncLayer()
        }
    }

    // MARK: - Common layer properties

    /// Controls the intensity of light emitted on the source features.
    /// Default value: 0. Minimum value: 0.
    public var circleEmissiveStrength: Double? {
        get {
            return layerProperties["circle-emissive-strength"] as? Double
        }
        set {
            layerProperties["circle-emissive-strength"] = newValue
        }
    }

    /// Orientation of circle when map is pitched.
    /// Default value: "viewport".
    public var circlePitchAlignment: CirclePitchAlignment? {
        get {
            return layerProperties["circle-pitch-alignment"].flatMap { $0 as? String }.flatMap(CirclePitchAlignment.init(rawValue:))
        }
        set {
            layerProperties["circle-pitch-alignment"] = newValue?.rawValue
        }
    }

    /// Controls the scaling behavior of the circle when the map is pitched.
    /// Default value: "map".
    public var circlePitchScale: CirclePitchScale? {
        get {
            return layerProperties["circle-pitch-scale"].flatMap { $0 as? String }.flatMap(CirclePitchScale.init(rawValue:))
        }
        set {
            layerProperties["circle-pitch-scale"] = newValue?.rawValue
        }
    }

    /// The geometry's offset. Values are [x, y] where negatives indicate left and up, respectively.
    /// Default value: [0,0].
    public var circleTranslate: [Double]? {
        get {
            return layerProperties["circle-translate"] as? [Double]
        }
        set {
            layerProperties["circle-translate"] = newValue
        }
    }

    /// Controls the frame of reference for `circle-translate`.
    /// Default value: "map".
    public var circleTranslateAnchor: CircleTranslateAnchor? {
        get {
            return layerProperties["circle-translate-anchor"].flatMap { $0 as? String }.flatMap(CircleTranslateAnchor.init(rawValue:))
        }
        set {
            layerProperties["circle-translate-anchor"] = newValue?.rawValue
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

    // MARK: - User interaction handling

    func handleTap(layerId: String, feature: Feature, context: MapContentGestureContext) -> Bool {

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
        guard let featureId = feature.identifier?.string else { return false }

        return annotations.first { $0.id == featureId }?.longPressHandler?(context) ?? false
    }

    func handleDragBegin(with featureId: String, context: MapContentGestureContext) -> Bool {
        guard !isSwiftUI else { return false }

        func predicate(annotation: CircleAnnotation) -> Bool {
            annotation.id == featureId && annotation.isDraggable
        }

        func tryBeginDragging(_ annotations: inout [CircleAnnotation], idx: Int) -> Bool {
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
            let layer = CircleLayer(id: dragId, source: dragId)
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
        _ keyPath: KeyPath<CircleAnnotation, ((inout CircleAnnotation, MapContentGestureContext) -> Void)?>,
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

// End of generated file.
