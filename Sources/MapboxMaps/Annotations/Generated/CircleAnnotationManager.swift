// This file is generated.
import Foundation
@_implementationOnly import MapboxCommon_Private

/// An instance of `CircleAnnotationManager` is responsible for a collection of `CircleAnnotation`s.
public class CircleAnnotationManager: AnnotationManager {

    // MARK: - Annotations -

    /// The collection of CircleAnnotations being managed
    public var annotations = [CircleAnnotation]() {
        didSet {
            needsSyncSourceAndLayer = true
        }
    }

    private var needsSyncSourceAndLayer = false

    // MARK: - AnnotationManager protocol conformance -

    public let sourceId: String

    public let layerId: String

    public let id: String

    // MARK: - Setup / Lifecycle -

    /// Dependency required to add sources/layers to the map
    private let style: Style

    /// Dependency Required to query for rendered features on tap
    private let mapFeatureQueryable: MapFeatureQueryable

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

    /// Indicates whether the style layer exists after style changes. Default value is `true`.
    internal let shouldPersist: Bool

    private let displayLinkParticipant = DelegatingDisplayLinkParticipant()

    internal init(id: String,
                  style: Style,
                  singleTapGestureRecognizer: UIGestureRecognizer,
                  mapFeatureQueryable: MapFeatureQueryable,
                  shouldPersist: Bool,
                  layerPosition: LayerPosition?,
                  displayLinkCoordinator: DisplayLinkCoordinator) {
        self.id = id
        self.style = style
        self.sourceId = id + "-source"
        self.layerId = id + "-layer"
        self.mapFeatureQueryable = mapFeatureQueryable
        self.shouldPersist = shouldPersist

        // Add target-action for tap handling
        singleTapGestureRecognizer.addTarget(self, action: #selector(handleTap(_:)))

        do {
            try makeSourceAndLayer(layerPosition: layerPosition)
        } catch {
            Log.error(forMessage: "Failed to create source / layer in CircleAnnotationManager", category: "Annotations")
        }

        self.displayLinkParticipant.delegate = self

        displayLinkCoordinator.add(displayLinkParticipant)
    }

    deinit {
        removeBackingSourceAndLayer()
    }

    func removeBackingSourceAndLayer() {
        do {
            try style.removeLayer(withId: layerId)
            try style.removeSource(withId: sourceId)
        } catch {
            Log.warning(forMessage: "Failed to remove source / layer from map for annotations due to error: \(error)",
                        category: "Annotations")
        }
    }

    internal func makeSourceAndLayer(layerPosition: LayerPosition?) throws {

        // Add the source with empty `data` property
        var source = GeoJSONSource()
        source.data = .empty
        try style.addSource(source, id: sourceId)

        // Add the correct backing layer for this annotation type
        var layer = CircleLayer(id: layerId)
        layer.source = sourceId
        if shouldPersist {
            try style.addPersistentLayer(layer, layerPosition: layerPosition)
        } else {
            try style.addLayer(layer, layerPosition: layerPosition)
        }
    }

    // MARK: - Sync annotations to map -

    /// Synchronizes the backing source and layer with the current `annotations`
    /// and common layer properties. This method is called automatically with
    /// each display link, but it may also be called manually in situations
    /// where the backing source and layer need to be updated earlier.
    public func syncSourceAndLayerIfNeeded() {
        guard needsSyncSourceAndLayer else {
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
            (key, Style.layerPropertyDefaultValue(for: .circle, property: key).value)
        })

        // Store the new set of property keys
        previouslySetLayerPropertyKeys = Set(newLayerProperties.keys)

        // Merge the new and unused properties
        let allLayerProperties = newLayerProperties.merging(unusedProperties, uniquingKeysWith: { $1 })

        // make a single call into MapboxCoreMaps to set layer properties
        do {
            try style.setLayerProperties(for: layerId, properties: allLayerProperties)
        } catch {
            Log.error(forMessage: "Could not set layer properties in CircleAnnotationManager due to error \(error)",
                      category: "Annotations")
        }

        // build and update the source data
        let featureCollection = Turf.FeatureCollection(features: annotations.map(\.feature))
        do {
            let data = try JSONEncoder().encode(featureCollection)
            let jsonObject = try JSONSerialization.jsonObject(with: data) as! [String: Any]
            try style.setSourceProperty(for: sourceId, property: "data", value: jsonObject)
        } catch {
            Log.error(forMessage: "Could not update annotations in CircleAnnotationManager due to error: \(error)",
                        category: "Annotations")
        }
    }

    // MARK: - Common layer properties -

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

    // MARK: - Tap Handling -

    /// Set this delegate in order to be called back if a tap occurs on an annotation being managed by this manager.
    public weak var delegate: AnnotationInteractionDelegate?

    @objc internal func handleTap(_ tap: UITapGestureRecognizer) {

        guard let delegate = delegate else { return }

        let options = RenderedQueryOptions(layerIds: [layerId], filter: nil)
        mapFeatureQueryable.queryRenderedFeatures(
            at: tap.location(in: tap.view),
            options: options) { [weak self] (result) in

            guard let self = self else { return }

            switch result {

            case .success(let queriedFeatures):

                // Get the identifiers of all the queried features
                let queriedFeatureIds: [String] = queriedFeatures.compactMap {
                    guard let feature = $0.feature,
                          let identifier = feature.identifier,
                          case let FeatureIdentifier.string(featureId) = identifier else {

                        return nil
                    }

                    return featureId
                }

                // Find if any `queriedFeatureIds` match an annotation's `id`
                let tappedAnnotations = self.annotations.filter { queriedFeatureIds.contains($0.id) }

                // If `tappedAnnotations` is not empty, call delegate
                if !tappedAnnotations.isEmpty {
                    self.delegate?.annotationManager(
                        self,
                        didDetectTappedAnnotations: tappedAnnotations)
                }

            case .failure(let error):
                Log.warning(forMessage: "Failed to query map for annotations due to error: \(error)",
                            category: "Annotations")
            }
        }
    }
}

extension CircleAnnotationManager: DelegatingDisplayLinkParticipantDelegate {
    func participate(for participant: DelegatingDisplayLinkParticipant) {
        syncSourceAndLayerIfNeeded()
    }
}

// End of generated file.
