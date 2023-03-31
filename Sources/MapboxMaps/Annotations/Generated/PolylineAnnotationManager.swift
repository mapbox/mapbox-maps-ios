// This file is generated.
import Foundation
@_implementationOnly import MapboxCommon_Private

/// An instance of `PolylineAnnotationManager` is responsible for a collection of `PolylineAnnotation`s.
public class PolylineAnnotationManager: AnnotationManagerInternal {

    // MARK: - Annotations

    /// The collection of ``PolylineAnnotation`` being managed.
    public var annotations: [PolylineAnnotation] {
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

    /// The collection of ``PolylineAnnotation`` that has been dragged.
    private var draggedAnnotations: [String: PolylineAnnotation] = [:]
    /// The collection of ``PolylineAnnotation`` in the main source.
    private var mainAnnotations: [String: PolylineAnnotation] = [:] {
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

    private let offsetLineStringCalculator: OffsetLineStringCalculator

    private var annotationBeingDragged: PolylineAnnotation?

    private var isDestroyed = false
    private let dragLayerId: String
    private let dragSourceId: String

    var allLayerIds: [String] { [layerId, dragLayerId] }

    internal init(id: String,
                  style: StyleProtocol,
                  layerPosition: LayerPosition?,
                  displayLinkCoordinator: DisplayLinkCoordinator,
                  offsetLineStringCalculator: OffsetLineStringCalculator) {
        self.id = id
        self.sourceId = id
        self.layerId = id
        self.style = style
        self.displayLinkCoordinator = displayLinkCoordinator
        self.offsetLineStringCalculator = offsetLineStringCalculator
        self.dragLayerId = id + "_drag-layer"
        self.dragSourceId = id + "_drag-source"

        do {
            // Add the source with empty `data` property
            var source = GeoJSONSource()
            source.data = .empty
            try style.addSource(source, id: sourceId)

            // Add the correct backing layer for this annotation type
            var layer = LineLayer(id: layerId)
            layer.source = sourceId
            try style.addPersistentLayer(layer, layerPosition: layerPosition)
        } catch {
            Log.error(
                forMessage: "Failed to create source / layer in PolylineAnnotationManager. Error: \(error)",
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
                forMessage: "Failed to remove layer for PolylineAnnotationManager with id \(id) due to error: \(error)",
                category: "Annotations")
        }
        do {
            try style.removeSource(withId: sourceId)
        } catch {
            Log.warning(
                forMessage: "Failed to remove source for PolylineAnnotationManager with id \(id) due to error: \(error)",
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
            (key, Style.layerPropertyDefaultValue(for: .line, property: key).value)
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
                forMessage: "Could not set layer properties in PolylineAnnotationManager due to error \(error)",
                category: "Annotations")
        }

        // build and update the source data
        do {
            let featureCollection = FeatureCollection(features: mainAnnotations.values.map(\.feature))
            try style.updateGeoJSONSource(withId: sourceId, geoJSON: .featureCollection(featureCollection))
        } catch {
            Log.error(
                forMessage: "Could not update annotations in PolylineAnnotationManager due to error: \(error)",
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

    /// The display of line endings.
    public var lineCap: LineCap? {
        get {
            return layerProperties["line-cap"].flatMap { $0 as? String }.flatMap(LineCap.init(rawValue:))
        }
        set {
            layerProperties["line-cap"] = newValue?.rawValue
        }
    }

    /// Used to automatically convert miter joins to bevel joins for sharp angles.
    public var lineMiterLimit: Double? {
        get {
            return layerProperties["line-miter-limit"] as? Double
        }
        set {
            layerProperties["line-miter-limit"] = newValue
        }
    }

    /// Used to automatically convert round joins to miter joins for shallow angles.
    public var lineRoundLimit: Double? {
        get {
            return layerProperties["line-round-limit"] as? Double
        }
        set {
            layerProperties["line-round-limit"] = newValue
        }
    }

    /// Specifies the lengths of the alternating dashes and gaps that form the dash pattern. The lengths are later scaled by the line width. To convert a dash length to pixels, multiply the length by the current line width. Note that GeoJSON sources with `lineMetrics: true` specified won't render dashed lines to the expected scale. Also note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    public var lineDasharray: [Double]? {
        get {
            return layerProperties["line-dasharray"] as? [Double]
        }
        set {
            layerProperties["line-dasharray"] = newValue
        }
    }

    /// The geometry's offset. Values are [x, y] where negatives indicate left and up, respectively.
    public var lineTranslate: [Double]? {
        get {
            return layerProperties["line-translate"] as? [Double]
        }
        set {
            layerProperties["line-translate"] = newValue
        }
    }

    /// Controls the frame of reference for `line-translate`.
    public var lineTranslateAnchor: LineTranslateAnchor? {
        get {
            return layerProperties["line-translate-anchor"].flatMap { $0 as? String }.flatMap(LineTranslateAnchor.init(rawValue:))
        }
        set {
            layerProperties["line-translate-anchor"] = newValue?.rawValue
        }
    }

    /// The line part between [trim-start, trim-end] will be marked as transparent to make a route vanishing effect. The line trim-off offset is based on the whole line range [0.0, 1.0].
    public var lineTrimOffset: [Double]? {
        get {
            return layerProperties["line-trim-offset"] as? [Double]
        }
        set {
            layerProperties["line-trim-offset"] = newValue
        }
    }

    // MARK: - User interaction handling

    /// Returns the first annotation matching the set of given `featureIdentifiers`.
    private func findAnnotation(from featureIdentifiers: [String], where predicate: (PolylineAnnotation) -> Bool) -> PolylineAnnotation? {
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

        var tappedAnnotations: [PolylineAnnotation] = []
        var annotations: [PolylineAnnotation] = []

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
        let offsetPoint = offsetLineStringCalculator.geometry(for: translation, from: annotationBeingDragged.lineString) else {
            return
        }

        self.annotationBeingDragged?.lineString = offsetPoint
        updateDragSource()
    }

    internal func handleDragEnded() {
        annotationBeingDragged = nil
    }
}

extension PolylineAnnotationManager: DelegatingDisplayLinkParticipantDelegate {
    func participate(for participant: DelegatingDisplayLinkParticipant) {
        syncSourceAndLayerIfNeeded()
        syncDragSourceIfNeeded()
    }
}

// End of generated file.
