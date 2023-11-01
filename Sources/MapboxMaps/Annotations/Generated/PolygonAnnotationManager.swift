// This file is generated.
import Foundation
import os
@_implementationOnly import MapboxCommon_Private

/// An instance of `PolygonAnnotationManager` is responsible for a collection of `PolygonAnnotation`s.
public class PolygonAnnotationManager: AnnotationManagerInternal {
    typealias OffsetCalculatorType = OffsetPolygonCalculator

    public var sourceId: String { id }

    public var layerId: String { id }

    public let id: String

    /// The collection of ``PolygonAnnotation`` being managed.
    public var annotations: [PolygonAnnotation] {
        get { mainAnnotations + draggedAnnotations }
        set {
            mainAnnotations = newValue
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
    private var displayedAnnotations: [PolygonAnnotation] = []

    /// Updated, non-moved annotations. On next display link they will be diffed with `displayedAnnotations` and updated.
    private var mainAnnotations = [PolygonAnnotation]() {
        didSet { syncSourceOnce.reset() }
    }

    /// When annotation is moved for the first time, it migrates to this array from mainAnnotations.
    private var draggedAnnotations = [PolygonAnnotation]() {
        didSet { syncDragSourceOnce.reset() }
    }

    /// Storage for common layer properties
    internal var layerProperties: [String: Any] = [:] {
        didSet {
            syncLayerOnce.reset()
        }
    }

    /// The keys of the style properties that were set during the previous sync.
    /// Used to identify which styles need to be restored to their default values in
    /// the subsequent sync.
    private var previouslySetLayerPropertyKeys: Set<String> = []

    private var draggedAnnotationIndex: Array<PolygonAnnotation>.Index?
    private var destroyOnce = Once()
    private var syncSourceOnce = Once(happened: true)
    private var syncDragSourceOnce = Once(happened: true)
    private var syncLayerOnce = Once(happened: true)
    private var insertDraggedLayerAndSourceOnce = Once()
    private var dragId: String { id + "_drag" }
    private var displayLinkToken: AnyCancelable?

    var allLayerIds: [String] { [layerId, dragId] }

    /// In SwiftUI isDraggable and isSelected are disabled.
    var isSwiftUI = false

    internal init(id: String,
                  style: StyleProtocol,
                  layerPosition: LayerPosition?,
                  displayLink: Signal<Void>,
                  offsetCalculator: OffsetCalculatorType) {
        self.id = id
        self.style = style
        self.offsetCalculator = offsetCalculator

        do {
            // Add the source with empty `data` property
            let source = GeoJSONSource(id: sourceId)
            try style.addSource(source)

            // Add the correct backing layer for this annotation type
            let layer = FillLayer(id: layerId, source: sourceId)
            try style.addPersistentLayer(layer, layerPosition: layerPosition)
        } catch {
            Log.error(
                forMessage: "Failed to create source / layer in PolygonAnnotationManager. Error: \(error)",
                category: "Annotations")
        }

        displayLinkToken = displayLink.observe { [weak self] in
            self?.syncSourceAndLayerIfNeeded()
        }
    }

    internal func destroy() {
        guard destroyOnce.continueOnce() else { return }

        displayLinkToken?.cancel()

        func wrapError(_ what: String, _ body: () throws -> Void) {
            do {
                try body()
            } catch {
                Log.warning(
                    forMessage: "Failed to remove \(what) for PolygonAnnotationManager with id \(id) due to error: \(error)",
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
            (key, StyleManager.layerPropertyDefaultValue(for: .fill, property: key).value)
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
                forMessage: "Could not set layer properties in PolygonAnnotationManager due to error \(error)",
                category: "Annotations")
        }
    }

    func syncSourceAndLayerIfNeeded() {
        guard !destroyOnce.happened else { return }

        OSLog.platform.withIntervalSignpost(SignpostName.mapViewDisplayLink, "Participant: PolygonAnnotationManager") {
            syncSource()
            syncDragSource()
            syncLayer()
        }
    }

    // MARK: - Common layer properties


    /// Whether or not the fill should be antialiased.
    public var fillAntialias: Bool? {
        get {
            return layerProperties["fill-antialias"] as? Bool
        }
        set {
            layerProperties["fill-antialias"] = newValue
        }
    }

    /// Controls the intensity of light emitted on the source features. This property works only with 3D light, i.e. when `lights` root property is defined.
    public var fillEmissiveStrength: Double? {
        get {
            return layerProperties["fill-emissive-strength"] as? Double
        }
        set {
            layerProperties["fill-emissive-strength"] = newValue
        }
    }

    /// The geometry's offset. Values are [x, y] where negatives indicate left and up, respectively.
    public var fillTranslate: [Double]? {
        get {
            return layerProperties["fill-translate"] as? [Double]
        }
        set {
            layerProperties["fill-translate"] = newValue
        }
    }

    /// Controls the frame of reference for `fill-translate`.
    public var fillTranslateAnchor: FillTranslateAnchor? {
        get {
            return layerProperties["fill-translate-anchor"].flatMap { $0 as? String }.flatMap(FillTranslateAnchor.init(rawValue:))
        }
        set {
            layerProperties["fill-translate-anchor"] = newValue?.rawValue
        }
    }

    /// 
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

    internal func handleTap(with featureId: String, context: MapContentGestureContext) -> Bool {
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

    func handleLongPress(with featureId: String, context: MapContentGestureContext) -> Bool {
        annotations.first {
            $0.id == featureId
        }?.longPressHandler?(context) ?? false
    }

    internal func handleDragBegin(with featureIdentifier: String, context: MapContentGestureContext) -> Bool {
        guard !isSwiftUI else { return false }

        let predicate = { (annotation: PolygonAnnotation) -> Bool in
            annotation.id == featureIdentifier && annotation.isDraggable
        }

        if let idx = draggedAnnotations.firstIndex(where: predicate) {
            draggedAnnotationIndex = idx
            return true
        }

        if let idx = mainAnnotations.lastIndex(where: predicate) {
            let annotation = mainAnnotations.remove(at: idx)
            draggedAnnotations.append(annotation)
            draggedAnnotationIndex = draggedAnnotations.endIndex - 1

            insertDraggedLayerAndSourceOnce {
                let source = GeoJSONSource(id: dragId)
                let layer = FillLayer(id: dragId, source: dragId)
                do {
                    try style.addSource(source)
                    try style.addPersistentLayer(layer, layerPosition: .above(layerId))
                } catch {
                    Log.error(forMessage: "Add drag source/layer \(error)", category: "Annotations")
                }
            }
            return true
        }
        return false
    }

    internal func handleDragChanged(with translation: CGPoint) {
        guard !isSwiftUI,
              let draggedAnnotationIndex,
              draggedAnnotationIndex < draggedAnnotations.endIndex,
              let polygon = offsetCalculator.geometry(for: translation, from: draggedAnnotations[draggedAnnotationIndex].polygon) else {
            return
        }

        draggedAnnotations[draggedAnnotationIndex].polygon = polygon
    }

    internal func handleDragEnded() {
        guard !isSwiftUI else { return }
        draggedAnnotationIndex = nil
    }
}

// End of generated file.
