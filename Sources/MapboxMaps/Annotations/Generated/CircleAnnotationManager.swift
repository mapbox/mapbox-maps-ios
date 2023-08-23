// This file is generated.
import Foundation
import os
@_implementationOnly import MapboxCommon_Private

/// An instance of `CircleAnnotationManager` is responsible for a collection of `CircleAnnotation`s.
public class CircleAnnotationManager: AnnotationManagerInternal {
    typealias OffsetCalculatorType = OffsetPointCalculator

    public var sourceId: String { id }

    public var layerId: String { id }

    public let id: String

    /// The collection of ``CircleAnnotation`` being managed.
    public var annotations: [CircleAnnotation] {
        get { mainAnnotations + draggedAnnotations }
        set {
            mainAnnotations = newValue
            draggedAnnotations.removeAll(keepingCapacity: true)
            draggedAnnotationIndex = nil
        }
    }

    /// Set this delegate in order to be called back if a tap occurs on an annotation being managed by this manager.
    /// - NOTE: This annotation manager listens to tap events via the `GestureManager.singleTapGestureRecognizer`.
    public weak var delegate: AnnotationInteractionDelegate?

    // Deps
    private let style: StyleProtocol
    private let offsetCalculator: OffsetCalculatorType
    private let displayLinkParticipant = DelegatingDisplayLinkParticipant()
    private weak var displayLinkCoordinator: DisplayLinkCoordinator?

    // Private state

    /// Currently displayed (synced) annotations.
    private var displayedAnnotations: [CircleAnnotation] = []

    /// Updated, non-moved annotations. On next display link they will be diffed with `displayedAnnotations` and updated.
    private var mainAnnotations = [CircleAnnotation]() {
        didSet { syncSourceOnce.reset() }
    }

    /// When annotation is moved for the first time, it migrates to this array from mainAnnotations.
    private var draggedAnnotations = [CircleAnnotation]() {
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

    private var draggedAnnotationIndex: Array<CircleAnnotation>.Index?
    private var destroyOnce = Once()
    private var syncSourceOnce = Once(happened: true)
    private var syncDragSourceOnce = Once(happened: true)
    private var syncLayerOnce = Once(happened: true)
    private var insertDraggedLayerAndSourceOnce = Once()
    private var dragId: String { id + "_drag" }

    var allLayerIds: [String] { [layerId, dragId] }

    /// In SwiftUI isDraggable and isSelected are disabled.
    var isSwiftUI = false

    internal init(id: String,
                  style: StyleProtocol,
                  layerPosition: LayerPosition?,
                  displayLinkCoordinator: DisplayLinkCoordinator?,
                  offsetCalculator: OffsetCalculatorType) {
        self.id = id
        self.style = style
        self.displayLinkCoordinator = displayLinkCoordinator
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

        self.displayLinkParticipant.delegate = self

        assert(displayLinkCoordinator != nil, "DisplayLinkCoordinator must be present")
        displayLinkCoordinator?.add(displayLinkParticipant)
    }

    internal func destroy() {
        guard destroyOnce.continueOnce() else { return }

        displayLinkCoordinator?.remove(displayLinkParticipant)

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

    /// Synchronizes the backing source and layer with the current `annotations`
    /// and common layer properties. This method is called automatically with
    /// each display link, but it may also be called manually in situations
    /// where the backing source and layer need to be updated earlier.
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

    /// Synchronizes the backing source and layer with the current `annotations`
    /// and common layer properties. This method is called automatically with
    /// each display link, but it may also be called manually in situations
    /// where the backing source and layer need to be updated earlier.
    public func syncSourceAndLayerIfNeeded() {
        guard !destroyOnce.happened else { return }

        syncSource()
        syncDragSource()
        syncLayer()
    }

    // MARK: - Common layer properties

    /// Emission strength
    public var circleEmissiveStrength: Double? {
        get {
            return layerProperties["circle-emissive-strength"] as? Double
        }
        set {
            layerProperties["circle-emissive-strength"] = newValue
        }
    }

    /// Orientation of circle when map is pitched.
    public var circlePitchAlignment: CirclePitchAlignment? {
        get {
            return layerProperties["circle-pitch-alignment"].flatMap { $0 as? String }.flatMap(CirclePitchAlignment.init(rawValue:))
        }
        set {
            layerProperties["circle-pitch-alignment"] = newValue?.rawValue
        }
    }

    /// Controls the scaling behavior of the circle when the map is pitched.
    public var circlePitchScale: CirclePitchScale? {
        get {
            return layerProperties["circle-pitch-scale"].flatMap { $0 as? String }.flatMap(CirclePitchScale.init(rawValue:))
        }
        set {
            layerProperties["circle-pitch-scale"] = newValue?.rawValue
        }
    }

    /// The geometry's offset. Values are [x, y] where negatives indicate left and up, respectively.
    public var circleTranslate: [Double]? {
        get {
            return layerProperties["circle-translate"] as? [Double]
        }
        set {
            layerProperties["circle-translate"] = newValue
        }
    }

    /// Controls the frame of reference for `circle-translate`.
    public var circleTranslateAnchor: CircleTranslateAnchor? {
        get {
            return layerProperties["circle-translate-anchor"].flatMap { $0 as? String }.flatMap(CircleTranslateAnchor.init(rawValue:))
        }
        set {
            layerProperties["circle-translate-anchor"] = newValue?.rawValue
        }
    }

    // MARK: - User interaction handling

    internal func handleQueriedFeatureIds(_ queriedFeatureIds: [String]) {
        guard annotations.map(\.id).contains(where: queriedFeatureIds.contains(_:)) else {
            return
        }

        var tappedAnnotations: [CircleAnnotation] = []
        var annotations: [CircleAnnotation] = []

        for var annotation in self.annotations {
            if queriedFeatureIds.contains(annotation.id) {
                annotation.isSelected.toggle()
                tappedAnnotations.append(annotation)
            }
            annotations.append(annotation)
        }

        if !isSwiftUI {
            self.annotations = annotations
        }

        delegate?.annotationManager(
            self,
            didDetectTappedAnnotations: tappedAnnotations)

        for annotation in tappedAnnotations {
            annotation.tapHandler?.value()
        }
    }

    internal func handleDragBegin(with featureIdentifiers: [String]) {
        guard !isSwiftUI else { return }
        let ids = Set(featureIdentifiers)

        let predicate = { (annotation: CircleAnnotation) -> Bool in
            ids.contains(annotation.id) && annotation.isDraggable
        }

        if let idx = draggedAnnotations.lastIndex(where: predicate) {
            draggedAnnotationIndex = idx
            return
        }

        if let idx = mainAnnotations.lastIndex(where: predicate) {
            let annotation = mainAnnotations.remove(at: idx)
            draggedAnnotations.append(annotation)
            draggedAnnotationIndex = draggedAnnotations.endIndex - 1

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
    }

    internal func handleDragChanged(with translation: CGPoint) {
        guard !isSwiftUI,
              let draggedAnnotationIndex,
              draggedAnnotationIndex < draggedAnnotations.endIndex,
              let point = offsetCalculator.geometry(for: translation, from: draggedAnnotations[draggedAnnotationIndex].point) else {
            return
        }

        draggedAnnotations[draggedAnnotationIndex].point = point
    }

    internal func handleDragEnded() {
        guard !isSwiftUI else { return }
        draggedAnnotationIndex = nil
    }
}

extension CircleAnnotationManager: DelegatingDisplayLinkParticipantDelegate {
    func participate(for participant: DelegatingDisplayLinkParticipant) {
        OSLog.platform.withIntervalSignpost(SignpostName.mapViewDisplayLink,
                                            "Participant: CircleAnnotationManager") {
            syncSourceAndLayerIfNeeded()
        }
    }
}

// End of generated file.
