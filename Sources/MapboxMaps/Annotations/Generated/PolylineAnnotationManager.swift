
// This file is generated.
import Foundation
@_implementationOnly import MapboxCommon_Private

/// An instance of `PolylineAnnotationManager` is responsible for a collection of `PolylineAnnotation`s.
public class PolylineAnnotationManager: AnnotationManagerInternal {

    // MARK: - Annotations

    /// The collection of PolylineAnnotations being managed
    public var annotations = [PolylineAnnotation]() {
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

    private let offsetLineStringCalculator: OffsetLineStringCalculator

    private var annotationBeingDragged: PolylineAnnotation?

    private var moveDistancesObject = MoveDistancesObject()

    private var isDestroyed = false

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
        let featureCollection = FeatureCollection(features: annotations.map(\.feature))
        do {
            try style.updateGeoJSONSource(withId: sourceId, geoJSON: .featureCollection(featureCollection))
        } catch {
            Log.error(
                forMessage: "Could not update annotations in PolylineAnnotationManager due to error: \(error)",
                category: "Annotations")
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

    internal func handleQueriedFeatureIds(_ queriedFeatureIds: [String]) {
        // Find if any `queriedFeatureIds` match an annotation's `id`
        let tappedAnnotations = annotations.filter { queriedFeatureIds.contains($0.id) }

        // If `tappedAnnotations` is not empty, call delegate
        if !tappedAnnotations.isEmpty {
            delegate?.annotationManager(
                self,
                didDetectTappedAnnotations: tappedAnnotations)
            var selectedAnnotationIds = tappedAnnotations.map(\.id)
              let allAnnotations: [PolylineAnnotation] = self.annotations.map { annotation in
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
        try? style.addSource(dragSource, id: "dragSource")

        let dragLayerId = "drag-layer"
        var dragLayer = LineLayer(id: dragLayerId)
        dragLayer.source = "dragSource"
        try? style.addLayer(dragLayer, layerPosition: .default)
    }

    internal func handleDragBegin(at position: CGPoint, querriedFeatureIdentifiers: [String]) {
        guard let annotation = annotations.first(where: { querriedFeatureIdentifiers.contains($0.id) }) else { return }
        createDragSourceAndLayer()

        try? style.updateLayer(withId: "drag-layer", type: LineLayer.self, update: { layer in
            layer.lineColor = annotation.lineColor.map(Value.constant)
            layer.lineOpacity = annotation.lineOpacity.map(Value.constant)
            layer.lineWidth = annotation.lineWidth.map(Value.constant)
            guard let linePattern = annotation.linePattern else { return }
            layer.linePattern = Value.constant(ResolvedImage.name(linePattern))
        })

        self.annotationBeingDragged = annotation
        self.annotations.removeAll(where: { $0.id == annotation.id })

        let previousPosition = position
        var moveObject = moveDistancesObject
        moveObject.prevX = previousPosition.x
        moveObject.prevY = previousPosition.y
        moveObject.distanceXSinceLast = 0
        moveObject.distanceYSinceLast = 0

        guard let annotationBeingDragged = annotationBeingDragged else { return }
        guard let offsetPoint = offsetLineStringCalculator.geometry(at: moveObject, from: annotationBeingDragged.lineString) else { return }
        self.annotationBeingDragged?.lineString = offsetPoint
        try? style.updateGeoJSONSource(withId: "dragSource", geoJSON: offsetPoint.geometry.geoJSONObject)
    }

    internal func handleDragChanged(to position: CGPoint) {
        var moveObject = moveDistancesObject
        moveObject.distanceXSinceLast = moveObject.prevX - position.x
        moveObject.distanceYSinceLast = moveObject.prevY - position.y
        moveObject.prevX = position.x
        moveObject.prevY = position.y

        guard let annotationBeingDragged = annotationBeingDragged else { return }
        guard let offsetPoint = offsetLineStringCalculator.geometry(at: moveObject, from: annotationBeingDragged.lineString) else { return }
        self.annotationBeingDragged?.lineString = offsetPoint
        try? style.updateGeoJSONSource(withId: "dragSource", geoJSON: offsetPoint.geometry.geoJSONObject)
    }

    internal func handleDragEnded() {
        guard let annotationBeingDragged = annotationBeingDragged else { return }
        self.annotations.append(annotationBeingDragged)
        self.annotationBeingDragged = nil

        // avoid blinking annotation by waiting
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            try? self.style.removeLayer(withId: "drag-layer")
        }
    }
}

extension PolylineAnnotationManager: DelegatingDisplayLinkParticipantDelegate {
    func participate(for participant: DelegatingDisplayLinkParticipant) {
        syncSourceAndLayerIfNeeded()
    }
}

// End of generated file.
