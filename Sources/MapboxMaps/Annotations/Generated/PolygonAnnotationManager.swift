
// This file is generated.
import Foundation
@_implementationOnly import MapboxCommon_Private

/// An instance of `PolygonAnnotationManager` is responsible for a collection of `PolygonAnnotation`s.
public class PolygonAnnotationManager: AnnotationManagerInternal {

    // MARK: - Annotations

    /// The collection of PolygonAnnotations being managed
    public var annotations = [PolygonAnnotation]() {
        didSet {
            needsSyncSourceAndLayer = true
        }
    }

    private var needsSyncSourceAndLayer = false

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

    private var moveDistancesObject = MoveDistancesObject()

    private var isDestroyed = false

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

        // Construct the properties dictionary from the annotations
        let dataDrivenLayerPropertyKeys = Set(annotations.flatMap { $0.layerProperties.keys })
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
        let featureCollection = FeatureCollection(features: annotations.map(\.feature))
        do {
            try style.updateGeoJSONSource(withId: sourceId, geoJSON: .featureCollection(featureCollection))
        } catch {
            Log.error(
                forMessage: "Could not update annotations in PolygonAnnotationManager due to error: \(error)",
                category: "Annotations")
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

    internal func handleQueriedFeatureIds(_ queriedFeatureIds: [String]) {
        // Find if any `queriedFeatureIds` match an annotation's `id`
        let tappedAnnotations = annotations.filter { queriedFeatureIds.contains($0.id) }

        // If `tappedAnnotations` is not empty, call delegate
        if !tappedAnnotations.isEmpty {
            delegate?.annotationManager(
                self,
                didDetectTappedAnnotations: tappedAnnotations)
            var selectedAnnotationIds = tappedAnnotations.map(\.id)
              let allAnnotations: [PolygonAnnotation] = self.annotations.map { annotation in
                var mutableAnnotation = annotation
                if selectedAnnotationIds.contains(annotation.id) {
                    if mutableAnnotation.isSelected == false {
                        mutableAnnotation.isSelected = true
                    } else {
                        mutableAnnotation.isSelected = false
                    }
                }
                selectedAnnotationIds.append(mutableAnnotation.id)
                return mutableAnnotation
            }

            self.annotations = allAnnotations

        }
    }

    internal func createDragSourceAndLayer() {
        var dragSource = GeoJSONSource()
        dragSource.data = .empty
        if style
        do {
            try style.addSource(dragSource, id: "dragSource")
        } catch {
            print("Failed to add the source to style. Error: \(error)")
        }

        let dragLayerId = "drag-layer"
        var dragLayer = FillLayer(id: dragLayerId)
        dragLayer.source = "dragSource"

        do {
            try style.addPersistentLayer(dragLayer, layerPosition: .default)
        } catch {
            print("Failed to add the layer to style. Error: \(error)")
        }
    }

    internal func handleDragBegin(at position: CGPoint, querriedFeatureIdentifiers: [String]) {
        guard let annotation = annotations.first(where: { querriedFeatureIdentifiers.contains($0.id) }) else { return }
        createDragSourceAndLayer()

        do {
            try style.updateLayer(withId: "drag-layer", type: FillLayer.self) { layer in
                layer.fillColor = annotation.fillColor.map(Value.constant)
                layer.fillOutlineColor = annotation.fillOutlineColor.map(Value.constant)
                layer.fillOpacity = annotation.fillOpacity.map(Value.constant)
                guard let fillPattern = annotation.fillPattern else { return }
                layer.fillPattern = Value.constant(ResolvedImage.name(fillPattern))
            })
        } catch {
            print("Failed to update drag layer. Error: \(error)")
        }

        self.annotationBeingDragged = annotation
        self.annotations.removeAll(where: { $0.id == annotation.id })

        let previousPosition = position
        let moveObject = moveDistancesObject
        moveObject.prevX = previousPosition.x
        moveObject.prevY = previousPosition.y
        moveObject.distanceXSinceLast = 0.0
        moveObject.distanceYSinceLast = 0.0

        guard let annotationBeingDragged = annotationBeingDragged else { return }
        guard let offsetPoint = offsetPolygonCalculator.geometry(at: moveObject, from: annotationBeingDragged.polygon) else { return }
        self.annotationBeingDragged?.polygon = offsetPoint
        do {
            try style.updateGeoJSONSource(withId: "dragSource", geoJSON: offsetPoint.geometry.geoJSONObject)
        } catch {
            print("Failed to update drag source. Error: \(error)")
        }
    }

    internal func handleDragChanged(to position: CGPoint) {
        let moveObject = moveDistancesObject
        moveObject.distanceXSinceLast = moveObject.prevX - position.x
        moveObject.distanceYSinceLast = moveObject.prevY - position.y
        moveObject.prevX = position.x
        moveObject.prevY = position.y

        guard let annotationBeingDragged = annotationBeingDragged else { return }
        guard let offsetPoint = offsetPolygonCalculator.geometry(at: moveObject, from: annotationBeingDragged.polygon) else { return }
        self.annotationBeingDragged?.polygon = offsetPoint
        do {
            try style.updateGeoJSONSource(withId: "dragSource", geoJSON: offsetPoint.geometry.geoJSONObject)
        } catch {
            print("Failed to update drag source. Error: \(error)")
        }
    }

    internal func handleDragEnded() {
        guard let annotationBeingDragged = annotationBeingDragged else { return }
        self.annotations.append(annotationBeingDragged)
        self.annotationBeingDragged = nil

        // avoid blinking annotation by waiting
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            do {
                try self.style.removeLayer(withId: "drag-layer")
            } catch {
                print("Failed to remove drag layer. Error: \(error)")
            }
        }
    }
}

extension PolygonAnnotationManager: DelegatingDisplayLinkParticipantDelegate {
    func participate(for participant: DelegatingDisplayLinkParticipant) {
        syncSourceAndLayerIfNeeded()
    }
}

// End of generated file.
