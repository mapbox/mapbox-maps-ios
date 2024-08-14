import os

protocol AnnotationManagerImplDelegate: AnyObject {
    func didTap(_ annotations: [Annotation])
    func syncImages()
    func removeAllImages()
}

protocol AnnotationManagerImplProtocol {
    var allLayerIds: [String] { get }

    func destroy()

    func handleTap(layerId: String, feature: Feature, context: MapContentGestureContext) -> Bool
    func handleLongPress(layerId: String, feature: Feature, context: MapContentGestureContext) -> Bool
    func handleDragBegin(with featureId: String, context: MapContentGestureContext) -> Bool
    func handleDragChange(with translation: CGPoint, context: MapContentGestureContext)
    func handleDragEnd(context: MapContentGestureContext)
}

final class AnnotationManagerImpl<AnnotationType: Annotation & AnnotationInternal & Equatable>: AnnotationManagerImplProtocol {
    let id: String

    weak var delegate: AnnotationManagerImplDelegate?

    var annotations: [AnnotationType] {
        get { mainAnnotations + draggedAnnotations }
        set {
            mainAnnotations = newValue
            mainAnnotations.removeDuplicates()
            draggedAnnotations.removeAll(keepingCapacity: true)
            draggedAnnotationIndex = nil
        }
    }

    var onClusterTap: ((AnnotationClusterGestureContext) -> Void)?
    var onClusterLongPress: ((AnnotationClusterGestureContext) -> Void)?

    // Deps
    private let style: StyleProtocol
    private let mapFeatureQueryable: MapFeatureQueryable
    private let mapboxMap: MapboxMapProtocol
    private let clusterOptions: ClusterOptions?
    private let layerType: LayerType

    private var dragId: String { "\(id)_drag" }
    private var clusterId: String?
    var allLayerIds: [String] { [id, dragId, clusterId].compactMap { $0 } }

    // Private state

    private weak var _delegate: AnnotationInteractionDelegate?

    /// Currently displayed (synced) annotations.
    private var displayedAnnotations: [AnnotationType] = []

    /// Updated, non-moved annotations. On next display link they will be diffed with `displayedAnnotations` and updated.
    private var mainAnnotations = [AnnotationType]() {
        didSet { syncSourceOnce.reset() }
    }

    /// When annotation is moved for the first time, it migrates to this array from mainAnnotations.
    private var draggedAnnotations = [AnnotationType]() {
        didSet {
            if insertDraggedLayerAndSourceOnce.happened {
                // Update dragged annotation only when the drag layer is created.
                syncDragSourceOnce.reset()
            }
        }
    }

    private var idsMap = [AnyHashable: String]()

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

    /// In SwiftUI isDraggable and isSelected are disabled.
    var isSwiftUI = false

    var layerPosition: LayerPosition? {
        didSet {
            do {
                try style.moveLayer(withId: id, to: layerPosition ?? .default)
            } catch {
                Log.error(forMessage: "Failed to mover layer to a new position. Error: \(error)", category: "Annotations")
            }
        }
    }

    init(params: AnnotationManagerParams, deps: AnnotationManagerDeps) {
        self.id = params.id
        self.style = deps.style
        self.mapboxMap = deps.map
        self.layerPosition = params.layerPosition

        self.clusterOptions = params.clusterOptions
        self.mapFeatureQueryable = deps.queryable

        // Add the source with empty `data` property
        var source = GeoJSONSource(id: id)

        // Set cluster options and create clusters if clustering is enabled
        if let clusterOptions {
            source.cluster = true
            source.clusterRadius = clusterOptions.clusterRadius
            source.clusterProperties = clusterOptions.clusterProperties
            source.clusterMaxZoom = clusterOptions.clusterMaxZoom
            source.clusterMinPoints = clusterOptions.clusterMinPoints
        }

        let layer = AnnotationType.makeLayer(id: id)
        self.layerType = layer.type

        if let clusterOptions {
            clusterId = "mapbox-iOS-cluster-circle-layer-manager-\(id)"
            createClusterLayers(clusterOptions: clusterOptions)
        }

        do {
            try style.addPersistentLayer(layer, layerPosition: layerPosition)
            try style.addSource(source)
        } catch {
            Log.error(
                forMessage: "Failed to create source / layer in \(implementationName). Error: \(error)",
                category: "Annotations")
        }

        displayLinkToken = deps.displayLink.observe { [weak self] in
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
                forMessage: "Failed to add cluster layer in \(implementationName). Error: \(error)",
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
        var circleLayer = CircleLayer(id: layedID, source: id)
        circleLayer.circleColor = clusterOptions.circleColor
        circleLayer.circleRadius = clusterOptions.circleRadius
        circleLayer.filter = Exp(.has) { "point_count" }
        return circleLayer
    }

    private func createClusterTextLayer(clusterOptions: ClusterOptions) -> SymbolLayer {
        let layerID = "mapbox-iOS-cluster-text-layer-manager-" + id
        var symbolLayer = SymbolLayer(id: layerID, source: id)
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
                forMessage: "Failed to remove cluster layer in \(implementationName). Error: \(error)",
                category: "Annotations")
        }
    }

    // For SwiftUI
    func set(newAnnotations: [(AnyHashable, AnnotationType)]) {
        var resolvedAnnotations = [AnnotationType]()
        newAnnotations.forEach { elementId, annotation in
            var annotation = annotation
            let stringId = idsMap[elementId] ?? annotation.id
            idsMap[elementId] = stringId
            annotation.id = stringId
            annotation.isDraggable = false
            annotation.isSelected = false
            resolvedAnnotations.append(annotation)
        }
        // TODO: evict old ids
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
                    forMessage: "Failed to remove \(what) for \(implementationName) with id \(id) due to error: \(error)",
                    category: "Annotations")
            }
        }

        wrapError("layer") {
            try style.removeLayer(withId: id)
        }

        wrapError("source") {
            try style.removeSource(withId: id)
        }

        if insertDraggedLayerAndSourceOnce.happened {
            wrapError("drag source and layer") {
                try style.removeLayer(withId: dragId)
                try style.removeSource(withId: dragId)
            }
        }

        delegate?.removeAllImages()
    }

    // MARK: - Sync annotations to map

    // internal for tests
    func syncSourceAndLayerIfNeeded() {
        guard !destroyOnce.happened else { return }

        OSLog.platform.withIntervalSignpost(SignpostName.mapViewDisplayLink, "Participant: \(implementationName)") {
            syncSource()
            syncDragSource()
            syncLayer()
        }
    }

    private func syncSource() {
        guard syncSourceOnce.continueOnce() else { return }

        let diff = mainAnnotations.diff(from: displayedAnnotations, id: \.id)
        syncLayerOnce.reset(if: !diff.isEmpty)
        style.apply(annotationsDiff: diff, sourceId: id, feature: \.feature)
        displayedAnnotations = mainAnnotations
    }

    private func syncDragSource() {
        guard syncDragSourceOnce.continueOnce() else { return }

        let fc = FeatureCollection(features: draggedAnnotations.map(\.feature))
        style.updateGeoJSONSource(withId: dragId, geoJSON: .featureCollection(fc))
    }

    private func syncLayer() {
        guard syncLayerOnce.continueOnce() else { return }

        delegate?.syncImages()

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
            (key, StyleManager.layerPropertyDefaultValue(for: self.layerType, property: key).value)
        })

        // Store the new set of property keys
        previouslySetLayerPropertyKeys = Set(newLayerProperties.keys)

        // Merge the new and unused properties
        let allLayerProperties = newLayerProperties.merging(unusedProperties, uniquingKeysWith: { $1 })

        // make a single call into MapboxCoreMaps to set layer properties
        do {
            try style.setLayerProperties(for: id, properties: allLayerProperties)
            if !draggedAnnotations.isEmpty {
                try style.setLayerProperties(for: dragId, properties: allLayerProperties)
            }
        } catch {
            Log.error(
                forMessage: "Could not set layer properties in PointAnnotationManager due to error \(error)",
                category: "Annotations")
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

        delegate?.didTap([tappedAnnotation])

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

        func predicate(annotation: AnnotationType) -> Bool {
            annotation.id == featureId && annotation.isDraggable
        }

        func tryBeginDragging(_ annotations: inout [AnnotationType], idx: Int) -> Bool {
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
            syncLayerOnce.reset()
            return true
        }

        return false
    }

    private func insertDraggedLayerAndSource() {
        insertDraggedLayerAndSourceOnce {
            do {
                try style.addSource(GeoJSONSource(id: dragId))
                try style.addPersistentLayer(AnnotationType.makeLayer(id: dragId), layerPosition: .above(id))
            } catch {
                Log.error(forMessage: "Add drag source/layer \(error)", category: "Annotations")
            }
        }
    }

    func handleDragChange(with translation: CGPoint, context: MapContentGestureContext) {
        guard !isSwiftUI,
              let draggedAnnotationIndex,
              draggedAnnotationIndex < draggedAnnotations.endIndex
        else {
            return
        }

        draggedAnnotations[draggedAnnotationIndex].drag(translation: translation, in: mapboxMap)
        callDragHandler(\.dragChangeHandler, context: context)
    }

    func handleDragEnd(context: MapContentGestureContext) {
        guard !isSwiftUI else { return }
        callDragHandler(\.dragEndHandler, context: context)
        draggedAnnotationIndex = nil
    }

    private func callDragHandler(
        _ keyPath: KeyPath<AnnotationType, ((inout AnnotationType, MapContentGestureContext) -> Void)?>,
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

private extension AnnotationManagerImpl {
    var implementationName: String { "\(String(describing: AnnotationType.self))Manager" }
}
