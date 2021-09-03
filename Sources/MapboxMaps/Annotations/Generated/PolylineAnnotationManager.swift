// This file is generated.
import Foundation
@_implementationOnly import MapboxCommon_Private

/// An instance of `PolylineAnnotationManager` is responsible for a collection of `PolylineAnnotation`s.
public class PolylineAnnotationManager: AnnotationManager {

    // MARK: - Annotations -

    /// The collection of PolylineAnnotations being managed
    public var annotations = [PolylineAnnotation]() {
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

    /// Dependency required to add gesture recognizer to the MapView
    private weak var view: UIView?

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
                  view: UIView,
                  mapFeatureQueryable: MapFeatureQueryable,
                  shouldPersist: Bool,
                  layerPosition: LayerPosition?,
                  displayLinkCoordinator: DisplayLinkCoordinator) {
        self.id = id
        self.style = style
        self.sourceId = id + "-source"
        self.layerId = id + "-layer"
        self.view = view
        self.mapFeatureQueryable = mapFeatureQueryable
        self.shouldPersist = shouldPersist

        do {
            try makeSourceAndLayer(layerPosition: layerPosition)
        } catch {
            Log.error(forMessage: "Failed to create source / layer in PolylineAnnotationManager", category: "Annotations")
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
        var layer = LineLayer(id: layerId)
        layer.source = sourceId
        if shouldPersist {
            try style._addPersistentLayer(layer, layerPosition: layerPosition)
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
        let unusedProperties = Dictionary(uniqueKeysWithValues: unusedPropertyKeys.compactMap { (key) -> (String, Any)? in
            if key == "text-field" {
                // default value for text-field is currently `{ kind: constant, value: ["format"] }`.
                // Attempting to set `text-field` to `["format"]` yields:
                //
                //     "Cannot set layer property: text-field error: Expected at least one argument."
                //
                Log.warning(forMessage: "There is a known issue with resetting text-field to its default value.",
                            category: "Annotations")
                return (key, ["format", ""])
            } else if key == "line-gradient" {
                // default value for line-gradient is currently `{ kind: undefined, value: NSNull }`,
                // but `style.setLayerProperties(for:properties:)` requires all values to be non-nil,
                // and doesn't accept NSNull, so for now, this property cannot be reset to its default.
                Log.error(forMessage: "line-gradient cannot currently be reset to its default value.",
                          category: "Annotations")
                return nil
            } else {
                return (key, Style._layerPropertyDefaultValue(for: .line, property: key).value)
            }
        })

        // Store the new set of property keys
        previouslySetLayerPropertyKeys = Set(newLayerProperties.keys)

        // Merge the new and unused properties
        let allLayerProperties = newLayerProperties.merging(unusedProperties, uniquingKeysWith: { $1 })

        // make a single call into MapboxCoreMaps to set layer properties
        do {
            try style.setLayerProperties(for: layerId, properties: allLayerProperties)
        } catch {
            Log.error(forMessage: "Could not set layer properties in PolylineAnnotationManager due to error \(error)",
                      category: "Annotations")
        }

        // build and update the source data
        let featureCollection = Turf.FeatureCollection(features: annotations.map(\.feature))
        do {
            let data = try JSONEncoder().encode(featureCollection)
            let jsonObject = try JSONSerialization.jsonObject(with: data) as! [String: Any]
            try style.setSourceProperty(for: sourceId, property: "data", value: jsonObject)
        } catch {
            Log.error(forMessage: "Could not update annotations in PolylineAnnotationManager due to error: \(error)",
                        category: "Annotations")
        }
    }

    // MARK: - Common layer properties -

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

    /// Defines a gradient with which to color a line feature. Can only be used with GeoJSON sources that specify `"lineMetrics": true`.
    public var lineGradient: StyleColor? {
        get {
            return layerProperties["line-gradient"].flatMap { $0 as? String }.flatMap(StyleColor.init(rgbaString:))
        }
        set {
            layerProperties["line-gradient"] = newValue?.rgbaString
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

    // MARK: - Selection Handling -

    /// Set this delegate in order to be called back if a tap occurs on an annotation being managed by this manager.
    public weak var delegate: AnnotationInteractionDelegate? {
        didSet {
            if delegate != nil {
                setupTapRecognizer()
            } else {
                guard let view = view, let recognizer = tapGestureRecognizer else { return }
                view.removeGestureRecognizer(recognizer)
                tapGestureRecognizer = nil
            }
        }
    }

    /// The `UITapGestureRecognizer` that's listening to touch events on the map for the annotations present in this manager
    public var tapGestureRecognizer: UITapGestureRecognizer?

    internal func setupTapRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.numberOfTouchesRequired = 1
        view?.addGestureRecognizer(tapRecognizer)
        tapGestureRecognizer = tapRecognizer
    }

    @objc internal func handleTap(_ tap: UITapGestureRecognizer) {
        let options = RenderedQueryOptions(layerIds: [layerId], filter: nil)
        mapFeatureQueryable.queryRenderedFeatures(
            at: tap.location(in: view),
            options: options) { [weak self] (result) in

            guard let self = self else { return }

            switch result {

            case .success(let queriedFeatures):
                if let annotationIds = queriedFeatures.compactMap({ $0.feature?.properties?["annotation-id"] }) as? [String] {

                    let tappedAnnotations = self.annotations.filter { annotationIds.contains($0.id) }
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

extension PolylineAnnotationManager: DelegatingDisplayLinkParticipantDelegate {
    func participate(for participant: DelegatingDisplayLinkParticipant) {
        syncSourceAndLayerIfNeeded()
    }
}

// End of generated file.
