// This file is generated.
import Foundation
@_implementationOnly import MapboxCommon_Private

/// An instance of `PolygonAnnotationManager` is responsible for a collection of `PolygonAnnotation`s.
public class PolygonAnnotationManager: AnnotationManagerInternal {

    // MARK: - Annotations

    /// The collection of ``PolygonAnnotation`` being managed.
    public var annotations: [PolygonAnnotation] {
        get {
            let allAnnotations = mainAnnotations.merging(draggedAnnotations) { $1 }
            return Array(allAnnotations.values)
        }
        set {
            mainAnnotations = newValue.reduce(into: [:]) { partialResult, annotation in
                partialResult[annotation.id] = annotation
            }

            draggedAnnotations = [:]
            annotationBeingDragged = nil
            needsSyncDragSource = true
        }
    }

    /// The collection of ``PolygonAnnotation`` that has been dragged.
    private var draggedAnnotations: [String: PolygonAnnotation] = [:]
    /// The collection of ``PolygonAnnotation`` in the main source.
    private var mainAnnotations: [String: PolygonAnnotation] = [:] {
        didSet {
            needsSyncSourceAndLayer = true
        }
    }

    private var needsSyncSourceAndLayer = false
    private var needsSyncDragSource = false

    // MARK: - Interaction

    /// Set this delegate in order to be called back if a tap occurs on an annotation being managed by this manager.
    /// - NOTE: This annotation manager listens to tap events via the `GestureManager.singleTapGestureRecognizer`.
    public weak var delegate: AnnotationInteractionDelegate?

    // MARK: - AnnotationManager protocol conformance

    public let sourceId: String

    public let layerId: String

    public let id: String

    // MARK: - Setup / Lifecycle

    /// Dependency required to add sources/layers to the map
    private let style: StyleProtocol

    /// Storage for common layer properties
    private var layerProperties: [String: Any] = [:] {
        didSet {
            needsSyncSourceAndLayer = true
        }
    }

    /// The keys of the style properties that were set during the previous sync.
    /// Used to identify which styles need to be restored to their default values in
    /// the subsequent sync.
    private var previouslySetLayerPropertyKeys: Set<String> = []

    private let displayLinkParticipant = DelegatingDisplayLinkParticipant()

    private weak var displayLinkCoordinator: DisplayLinkCoordinator?

    private let offsetPolygonCalculator: OffsetPolygonCalculator

    private var annotationBeingDragged: PolygonAnnotation?

    private var isDestroyed = false
    private let dragLayerId: String
    private let dragSourceId: String

    var allLayerIds: [String] { [layerId, dragLayerId] }

    internal init(id: String,
                  style: StyleProtocol,
                  layerPosition: LayerPosition?,
                  displayLinkCoordinator: DisplayLinkCoordinator,
                  offsetPolygonCalculator: OffsetPolygonCalculator) {
        self.id = id
        self.sourceId = id
        self.layerId = id
        self.style = style
        self.displayLinkCoordinator = displayLinkCoordinator
        self.offsetPolygonCalculator = offsetPolygonCalculator
        self.dragLayerId = id + "_drag-layer"
        self.dragSourceId = id + "_drag-source"

        do {
            // Add the source with empty `data` property
            var source = GeoJSONSource()
            source.data = .empty
            try style.addSource(source, id: sourceId)

            // Add the correct backing layer for this annotation type
            var layer = FillLayer(id: layerId)
            layer.source = sourceId
            try style.addPersistentLayer(layer, layerPosition: layerPosition)
        } catch {
            Log.error(
                forMessage: "Failed to create source / layer in PolygonAnnotationManager. Error: \(error)",
                category: "Annotations")
        }

        self.displayLinkParticipant.delegate = self

        displayLinkCoordinator.add(displayLinkParticipant)
    }

    internal func destroy() {
        guard !isDestroyed else {
            return
        }
        isDestroyed = true

        removeDragSourceAndLayer()

        do {
            try style.removeLayer(withId: layerId)
        } catch {
            Log.warning(
                forMessage: "Failed to remove layer for PolygonAnnotationManager with id \(id) due to error: \(error)",
                category: "Annotations")
        }
        do {
            try style.removeSource(withId: sourceId)
        } catch {
            Log.warning(
                forMessage: "Failed to remove source for PolygonAnnotationManager with id \(id) due to error: \(error)",
                category: "Annotations")
        }
        displayLinkCoordinator?.remove(displayLinkParticipant)
    }

    // MARK: - Sync annotations to map

    /// Synchronizes the backing source and layer with the current `annotations`
    /// and common layer properties. This method is called automatically with
    /// each display link, but it may also be called manually in situations
    /// where the backing source and layer need to be updated earlier.
    public func syncSourceAndLayerIfNeeded() {
        guard needsSyncSourceAndLayer, !isDestroyed else {
            return
        }
        needsSyncSourceAndLayer = false
        let allAnnotations = annotations

        // Construct the properties dictionary from the annotations
        let dataDrivenLayerPropertyKeys = Set(allAnnotations.flatMap(\.layerProperties.keys))
        let dataDrivenProperties = Dictionary(
            uniqueKeysWithValues: dataDrivenLayerPropertyKeys
                .map { (key) -> (String, Any) in
                    (key, ["get", key, ["get", "layerProperties"]])
                })

        // Merge the common layer properties
        let newLayerProperties = dataDrivenProperties.merging(layerProperties, uniquingKeysWith: { $1 })

        // Construct the properties dictionary to reset any properties that are no longer used
        let unusedPropertyKeys = previouslySetLayerPropertyKeys.subtracting(newLayerProperties.keys)
        let unusedProperties = Dictionary(uniqueKeysWithValues: unusedPropertyKeys.map { (key) -> (String, Any) in
            (key, Style.layerPropertyDefaultValue(for: .fill, property: key).value)
        })

        // Store the new set of property keys
        previouslySetLayerPropertyKeys = Set(newLayerProperties.keys)

        // Merge the new and unused properties
        let allLayerProperties = newLayerProperties.merging(unusedProperties, uniquingKeysWith: { $1 })

        // make a single call into MapboxCoreMaps to set layer properties
        do {
            try style.setLayerProperties(for: layerId, properties: allLayerProperties)
        } catch {
            Log.error(
                forMessage: "Could not set layer properties in PolygonAnnotationManager due to error \(error)",
                category: "Annotations")
        }

        // build and update the source data
        do {
            let featureCollection = FeatureCollection(features: mainAnnotations.values.map(\.feature))
            try style.updateGeoJSONSource(withId: sourceId, geoJSON: .featureCollection(featureCollection))
        } catch {
            Log.error(
                forMessage: "Could not update annotations in PolygonAnnotationManager due to error: \(error)",
                category: "Annotations")
        }
    }

    private func syncDragSourceIfNeeded() {
        guard !isDestroyed, needsSyncDragSource else { return }

        needsSyncDragSource = false
        if style.sourceExists(withId: dragSourceId) {
            updateDragSource()
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

    // MARK: - User interaction handling

    /// Returns the first annotation matching the set of given `featureIdentifiers`.
    private func findAnnotation(from featureIdentifiers: [String], where predicate: (PolygonAnnotation) -> Bool) -> PolygonAnnotation? {
        for featureIdentifier in featureIdentifiers {
            if let annotation = mainAnnotations[featureIdentifier] ?? draggedAnnotations[featureIdentifier], predicate(annotation) {
                return annotation
            }
        }
        return nil
    }

    internal func handleQueriedFeatureIds(_ queriedFeatureIds: [String]) {
        guard annotations.map(\.id).contains(where: queriedFeatureIds.contains(_:)) else {
            return
        }

        var tappedAnnotations: [PolygonAnnotation] = []
        var annotations: [PolygonAnnotation] = []

        for var annotation in self.annotations {
            if queriedFeatureIds.contains(annotation.id) {
                annotation.isSelected.toggle()
                tappedAnnotations.append(annotation)
            }
            annotations.append(annotation)
        }

        self.annotations = annotations

        delegate?.annotationManager(
            self,
            didDetectTappedAnnotations: tappedAnnotations)
    }

    private func updateDragSource() {
        do {
            if let annotationBeingDragged = annotationBeingDragged {
                draggedAnnotations[annotationBeingDragged.id] = annotationBeingDragged
            }
            try style.updateGeoJSONSource(withId: dragSourceId, geoJSON: .featureCollection(.init(features: draggedAnnotations.values.map(\.feature))))
        } catch {
            Log.error(forMessage: "Failed to update drag source. Error: \(error)")
        }
    }

    private func updateDragLayer() {
        do {
            // copy the existing layer as the drag layer
            var properties = try style.layerProperties(for: layerId)
            properties[SymbolLayer.RootCodingKeys.id.rawValue] = dragLayerId
            properties[SymbolLayer.RootCodingKeys.source.rawValue] = dragSourceId

            if style.layerExists(withId: dragLayerId) {
                try style.setLayerProperties(for: dragLayerId, properties: properties)
            } else {
                try style.addPersistentLayer(with: properties, layerPosition: .above(layerId))
            }
        } catch {
            Log.error(forMessage: "Failed to update the layer to style. Error: \(error)")
        }
    }

    private func removeDragSourceAndLayer() {
        do {
            try style.removeLayer(withId: dragLayerId)
            try style.removeSource(withId: dragSourceId)
        } catch {
            Log.error(forMessage: "Failed to remove drag layer. Error: \(error)")
        }
    }

    internal func handleDragBegin(with featureIdentifiers: [String]) {
        guard let annotation = findAnnotation(from: featureIdentifiers, where: { $0.isDraggable }) else { return }

        do {
            if !style.sourceExists(withId: dragSourceId) {
                var dragSource = GeoJSONSource()
                dragSource.data = .empty
                try style.addSource(dragSource, id: dragSourceId)
            }

            annotationBeingDragged = annotation
            mainAnnotations[annotation.id] = nil

            updateDragSource()
            updateDragLayer()
        } catch {
            Log.error(forMessage: "Failed to create the drag source to style. Error: \(error)")
        }
    }

    internal func handleDragChanged(with translation: CGPoint) {
        guard let annotationBeingDragged = annotationBeingDragged,
        let offsetPoint = offsetPolygonCalculator.geometry(for: translation, from: annotationBeingDragged.polygon) else {
            return
        }

        self.annotationBeingDragged?.polygon = offsetPoint
        updateDragSource()
    }

    internal func handleDragEnded() {
        annotationBeingDragged = nil
    }
}

extension PolygonAnnotationManager: DelegatingDisplayLinkParticipantDelegate {
    func participate(for participant: DelegatingDisplayLinkParticipant) {
        syncSourceAndLayerIfNeeded()
        syncDragSourceIfNeeded()
    }
}

// End of generated file.
