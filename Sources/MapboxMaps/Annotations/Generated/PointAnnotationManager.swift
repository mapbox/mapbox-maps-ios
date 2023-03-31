// This file is generated.
import Foundation
@_implementationOnly import MapboxCommon_Private

/// An instance of `PointAnnotationManager` is responsible for a collection of `PointAnnotation`s.
public class PointAnnotationManager: AnnotationManagerInternal {

    // MARK: - Annotations

    /// The collection of ``PointAnnotation`` being managed.
    public var annotations: [PointAnnotation] {
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

    /// The collection of ``PointAnnotation`` that has been dragged.
    private var draggedAnnotations: [String: PointAnnotation] = [:]
    /// The collection of ``PointAnnotation`` in the main source.
    private var mainAnnotations: [String: PointAnnotation] = [:] {
        didSet {
            needsSyncSourceAndLayer = true
        }
    }

    private var needsSyncSourceAndLayer = false
    private var needsSyncDragSource = false
    /// List of images used by this ``PointAnnotationManager``.
    private(set) internal var allImages = Set<String>()
    private let imagesManager: AnnotationImagesManagerProtocol
    private var clusterOptions: ClusterOptions?

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

    private let offsetPointCalculator: OffsetPointCalculator

    private var annotationBeingDragged: PointAnnotation?

    private var isDestroyed = false
    private let dragLayerId: String
    private let dragSourceId: String

    var allLayerIds: [String] { [layerId, dragLayerId] }

    internal init(id: String,
                  style: StyleProtocol,
                  layerPosition: LayerPosition?,
                  displayLinkCoordinator: DisplayLinkCoordinator,
                  clusterOptions: ClusterOptions? = nil,
                  imagesManager: AnnotationImagesManagerProtocol,
                  offsetPointCalculator: OffsetPointCalculator) {
        self.id = id
        self.sourceId = id
        self.layerId = id
        self.style = style
        self.clusterOptions = clusterOptions
        self.imagesManager = imagesManager
        self.displayLinkCoordinator = displayLinkCoordinator
        self.offsetPointCalculator = offsetPointCalculator
        self.dragLayerId = id + "_drag-layer"
        self.dragSourceId = id + "_drag-source"

        imagesManager.register(imagesConsumer: self)

        do {
            // Add the source with empty `data` property
            var source = GeoJSONSource()
            source.data = .empty

            // Set cluster options and create clusters if clustering is enabled
            if let clusterOptions = clusterOptions {
                source.cluster = true
                source.clusterRadius = clusterOptions.clusterRadius
                source.clusterProperties = clusterOptions.clusterProperties
                source.clusterMaxZoom = clusterOptions.clusterMaxZoom
            }

            try style.addSource(source, id: sourceId)

            if let clusterOptions = clusterOptions {
                createClusterLayers(clusterOptions: clusterOptions)
            }

            // Add the correct backing layer for this annotation type
            var layer = SymbolLayer(id: layerId)
            layer.source = sourceId

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

        self.displayLinkParticipant.delegate = self

        displayLinkCoordinator.add(displayLinkParticipant)
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
        var circleLayer = CircleLayer(id: layedID)
        circleLayer.source = sourceId
        circleLayer.circleColor = clusterOptions.circleColor
        circleLayer.circleRadius = clusterOptions.circleRadius
        circleLayer.filter = Exp(.has) { "point_count" }
        return circleLayer
    }

    private func createClusterTextLayer(clusterOptions: ClusterOptions) -> SymbolLayer {
        let layerID = "mapbox-iOS-cluster-text-layer-manager-" + id
        var symbolLayer = SymbolLayer(id: layerID)
        symbolLayer.source = sourceId
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

    internal func destroy() {
        guard !isDestroyed else {
            return
        }
        isDestroyed = true

        if clusterOptions != nil {
            destroyClusterLayers()
        }

        removeDragSourceAndLayer()

        do {
            try style.removeLayer(withId: layerId)
        } catch {
            Log.warning(
                forMessage: "Failed to remove layer for PointAnnotationManager with id \(id) due to error: \(error)",
                category: "Annotations")
        }
        do {
            try style.removeSource(withId: sourceId)
        } catch {
            Log.warning(
                forMessage: "Failed to remove source for PointAnnotationManager with id \(id) due to error: \(error)",
                category: "Annotations")
        }
        removeAllImages()
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

        let newImages = Set(allAnnotations.compactMap(\.image))
        let newImageNames = Set(newImages.map(\.name))
        let unusedImages = allImages.subtracting(newImageNames)

        addImages(newImages)
        allImages = newImageNames

        removeImages(unusedImages)

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
            (key, Style.layerPropertyDefaultValue(for: .symbol, property: key).value)
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
                forMessage: "Could not set layer properties in PointAnnotationManager due to error \(error)",
                category: "Annotations")
        }

        // build and update the source data
        do {
            let featureCollection = FeatureCollection(features: mainAnnotations.values.map(\.feature))
            try style.updateGeoJSONSource(withId: sourceId, geoJSON: .featureCollection(featureCollection))
        } catch {
            Log.error(
                forMessage: "Could not update annotations in PointAnnotationManager due to error: \(error)",
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

    /// If true, the icon will be visible even if it collides with other previously drawn symbols.
    public var iconAllowOverlap: Bool? {
        get {
            return layerProperties["icon-allow-overlap"] as? Bool
        }
        set {
            layerProperties["icon-allow-overlap"] = newValue
        }
    }

    /// If true, other symbols can be visible even if they collide with the icon.
    public var iconIgnorePlacement: Bool? {
        get {
            return layerProperties["icon-ignore-placement"] as? Bool
        }
        set {
            layerProperties["icon-ignore-placement"] = newValue
        }
    }

    /// If true, the icon may be flipped to prevent it from being rendered upside-down.
    public var iconKeepUpright: Bool? {
        get {
            return layerProperties["icon-keep-upright"] as? Bool
        }
        set {
            layerProperties["icon-keep-upright"] = newValue
        }
    }

    /// If true, text will display without their corresponding icons when the icon collides with other symbols and the text does not.
    public var iconOptional: Bool? {
        get {
            return layerProperties["icon-optional"] as? Bool
        }
        set {
            layerProperties["icon-optional"] = newValue
        }
    }

    /// Size of the additional area around the icon bounding box used for detecting symbol collisions.
    public var iconPadding: Double? {
        get {
            return layerProperties["icon-padding"] as? Double
        }
        set {
            layerProperties["icon-padding"] = newValue
        }
    }

    /// Orientation of icon when map is pitched.
    public var iconPitchAlignment: IconPitchAlignment? {
        get {
            return layerProperties["icon-pitch-alignment"].flatMap { $0 as? String }.flatMap(IconPitchAlignment.init(rawValue:))
        }
        set {
            layerProperties["icon-pitch-alignment"] = newValue?.rawValue
        }
    }

    /// In combination with `symbol-placement`, determines the rotation behavior of icons.
    public var iconRotationAlignment: IconRotationAlignment? {
        get {
            return layerProperties["icon-rotation-alignment"].flatMap { $0 as? String }.flatMap(IconRotationAlignment.init(rawValue:))
        }
        set {
            layerProperties["icon-rotation-alignment"] = newValue?.rawValue
        }
    }

    /// Scales the icon to fit around the associated text.
    public var iconTextFit: IconTextFit? {
        get {
            return layerProperties["icon-text-fit"].flatMap { $0 as? String }.flatMap(IconTextFit.init(rawValue:))
        }
        set {
            layerProperties["icon-text-fit"] = newValue?.rawValue
        }
    }

    /// Size of the additional area added to dimensions determined by `icon-text-fit`, in clockwise order: top, right, bottom, left.
    public var iconTextFitPadding: [Double]? {
        get {
            return layerProperties["icon-text-fit-padding"] as? [Double]
        }
        set {
            layerProperties["icon-text-fit-padding"] = newValue
        }
    }

    /// If true, the symbols will not cross tile edges to avoid mutual collisions. Recommended in layers that don't have enough padding in the vector tile to prevent collisions, or if it is a point symbol layer placed after a line symbol layer. When using a client that supports global collision detection, like Mapbox GL JS version 0.42.0 or greater, enabling this property is not needed to prevent clipped labels at tile boundaries.
    public var symbolAvoidEdges: Bool? {
        get {
            return layerProperties["symbol-avoid-edges"] as? Bool
        }
        set {
            layerProperties["symbol-avoid-edges"] = newValue
        }
    }

    /// Label placement relative to its geometry.
    public var symbolPlacement: SymbolPlacement? {
        get {
            return layerProperties["symbol-placement"].flatMap { $0 as? String }.flatMap(SymbolPlacement.init(rawValue:))
        }
        set {
            layerProperties["symbol-placement"] = newValue?.rawValue
        }
    }

    /// Distance between two symbol anchors.
    public var symbolSpacing: Double? {
        get {
            return layerProperties["symbol-spacing"] as? Double
        }
        set {
            layerProperties["symbol-spacing"] = newValue
        }
    }

    /// Determines whether overlapping symbols in the same layer are rendered in the order that they appear in the data source or by their y-position relative to the viewport. To control the order and prioritization of symbols otherwise, use `symbol-sort-key`.
    public var symbolZOrder: SymbolZOrder? {
        get {
            return layerProperties["symbol-z-order"].flatMap { $0 as? String }.flatMap(SymbolZOrder.init(rawValue:))
        }
        set {
            layerProperties["symbol-z-order"] = newValue?.rawValue
        }
    }

    /// If true, the text will be visible even if it collides with other previously drawn symbols.
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
            layerProperties["text-font"] = newValue.map { ["literal", $0] }
        }
    }

    /// If true, other symbols can be visible even if they collide with the text.
    public var textIgnorePlacement: Bool? {
        get {
            return layerProperties["text-ignore-placement"] as? Bool
        }
        set {
            layerProperties["text-ignore-placement"] = newValue
        }
    }

    /// If true, the text may be flipped vertically to prevent it from being rendered upside-down.
    public var textKeepUpright: Bool? {
        get {
            return layerProperties["text-keep-upright"] as? Bool
        }
        set {
            layerProperties["text-keep-upright"] = newValue
        }
    }

    /// Maximum angle change between adjacent characters.
    public var textMaxAngle: Double? {
        get {
            return layerProperties["text-max-angle"] as? Double
        }
        set {
            layerProperties["text-max-angle"] = newValue
        }
    }

    /// If true, icons will display without their corresponding text when the text collides with other symbols and the icon does not.
    public var textOptional: Bool? {
        get {
            return layerProperties["text-optional"] as? Bool
        }
        set {
            layerProperties["text-optional"] = newValue
        }
    }

    /// Size of the additional area around the text bounding box used for detecting symbol collisions.
    public var textPadding: Double? {
        get {
            return layerProperties["text-padding"] as? Double
        }
        set {
            layerProperties["text-padding"] = newValue
        }
    }

    /// Orientation of text when map is pitched.
    public var textPitchAlignment: TextPitchAlignment? {
        get {
            return layerProperties["text-pitch-alignment"].flatMap { $0 as? String }.flatMap(TextPitchAlignment.init(rawValue:))
        }
        set {
            layerProperties["text-pitch-alignment"] = newValue?.rawValue
        }
    }

    /// In combination with `symbol-placement`, determines the rotation behavior of the individual glyphs forming the text.
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

    /// Distance that the icon's anchor is moved from its original placement. Positive values indicate right and down, while negative values indicate left and up.
    public var iconTranslate: [Double]? {
        get {
            return layerProperties["icon-translate"] as? [Double]
        }
        set {
            layerProperties["icon-translate"] = newValue
        }
    }

    /// Controls the frame of reference for `icon-translate`.
    public var iconTranslateAnchor: IconTranslateAnchor? {
        get {
            return layerProperties["icon-translate-anchor"].flatMap { $0 as? String }.flatMap(IconTranslateAnchor.init(rawValue:))
        }
        set {
            layerProperties["icon-translate-anchor"] = newValue?.rawValue
        }
    }

    /// Distance that the text's anchor is moved from its original placement. Positive values indicate right and down, while negative values indicate left and up.
    public var textTranslate: [Double]? {
        get {
            return layerProperties["text-translate"] as? [Double]
        }
        set {
            layerProperties["text-translate"] = newValue
        }
    }

    /// Controls the frame of reference for `text-translate`.
    public var textTranslateAnchor: TextTranslateAnchor? {
        get {
            return layerProperties["text-translate-anchor"].flatMap { $0 as? String }.flatMap(TextTranslateAnchor.init(rawValue:))
        }
        set {
            layerProperties["text-translate-anchor"] = newValue?.rawValue
        }
    }

    /// Text leading value for multi-line text.
    @available(*, deprecated, message: "text-line-height property is now data driven, use `PointAnnotation.textLineHeight` instead.")
    public var textLineHeight: Double? {
        get {
            return layerProperties["text-line-height"] as? Double
        }
        set {
            layerProperties["text-line-height"] = newValue
        }
    }

    // MARK: - User interaction handling

    /// Returns the first annotation matching the set of given `featureIdentifiers`.
    private func findAnnotation(from featureIdentifiers: [String], where predicate: (PointAnnotation) -> Bool) -> PointAnnotation? {
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

        var tappedAnnotations: [PointAnnotation] = []
        var annotations: [PointAnnotation] = []

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
              let offsetPoint = offsetPointCalculator.geometry(for: translation, from: annotationBeingDragged.point) else {
            return
        }

        self.annotationBeingDragged?.point = offsetPoint
        updateDragSource()
    }

    internal func handleDragEnded() {
        annotationBeingDragged = nil
    }
}

extension PointAnnotationManager: DelegatingDisplayLinkParticipantDelegate {
    func participate(for participant: DelegatingDisplayLinkParticipant) {
        syncSourceAndLayerIfNeeded()
        syncDragSourceIfNeeded()
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
