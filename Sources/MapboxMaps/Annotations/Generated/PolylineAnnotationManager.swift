// swiftlint:disable all
// This file is generated.
import Foundation
@_implementationOnly import MapboxCommon_Private

/// An instance of `PolylineAnnotationManager` is responsible for a collection of `PolylineAnnotation`s.
public class PolylineAnnotationManager: AnnotationManager {

    // MARK: - Annotations -

    /// The collection of PolylineAnnotations being managed
    public var annotations = [PolylineAnnotation]() {
        didSet {
            needsSyncAnnotations = true
        }
    }

    private var needsSyncAnnotations = false

    // MARK: - AnnotationManager protocol conformance -

    public let sourceId: String

    public let layerId: String

    public let id: String

    // MARK:- Setup / Lifecycle -

    /// Dependency required to add sources/layers to the map
    private let style: Style

    /// Dependency Required to query for rendered features on tap
    private let mapFeatureQueryable: MapFeatureQueryable

    /// Dependency required to add gesture recognizer to the MapView
    private weak var view: UIView?

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
            try style.removeSource(withId: layerId)
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

    /// Synchronizes the backing source and layer with the current set of annotations.
    /// This method is called automatically with each display link, but it may also be
    /// called manually in situations where the backing source and layer need to be
    /// updated earlier.
    public func syncAnnotationsIfNeeded() {
        guard needsSyncAnnotations else {
            return
        }
        needsSyncAnnotations = false

        let allDataDrivenPropertiesUsed = Set(annotations.flatMap { $0.styles.keys })
        for property in allDataDrivenPropertiesUsed {
            do {
                try style.setLayerProperty(for: layerId, property: property, value: ["get", property, ["get", "styles"]] )
            } catch {
                Log.error(forMessage: "Could not set layer property \(property) in PolylineAnnotationManager",
                            category: "Annotations")
            }
        }

        let featureCollection = Turf.FeatureCollection(features: annotations.map(\.feature))
        do {
            let data = try JSONEncoder().encode(featureCollection)
            guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                Log.error(forMessage: "Could not convert annotation features to json object in PolylineAnnotationManager",
                            category: "Annotations")
                return
            }
            try style.setSourceProperty(for: sourceId, property: "data", value: jsonObject )
        } catch {
            Log.error(forMessage: "Could not update annotations in PolylineAnnotationManager due to error: \(error)",
                        category: "Annotations")
        }
    }

    // MARK: - Common layer properties -

    /// The display of line endings.
    public var lineCap: LineCap? {
        didSet {
            do {
                try style.setLayerProperty(for: layerId, property: "line-cap", value: lineCap?.rawValue as Any)
            } catch {
                Log.warning(forMessage: "Could not set PolylineAnnotationManager.lineCap due to error: \(error)",
                            category: "Annotations")
            }
        }
    }

    /// Used to automatically convert miter joins to bevel joins for sharp angles.
    public var lineMiterLimit: Double? {
        didSet {
            do {
                try style.setLayerProperty(for: layerId, property: "line-miter-limit", value: lineMiterLimit as Any)
            } catch {
                Log.warning(forMessage: "Could not set PolylineAnnotationManager.lineMiterLimit due to error: \(error)",
                            category: "Annotations")
            }
        }
    }

    /// Used to automatically convert round joins to miter joins for shallow angles.
    public var lineRoundLimit: Double? {
        didSet {
            do {
                try style.setLayerProperty(for: layerId, property: "line-round-limit", value: lineRoundLimit as Any)
            } catch {
                Log.warning(forMessage: "Could not set PolylineAnnotationManager.lineRoundLimit due to error: \(error)",
                            category: "Annotations")
            }
        }
    }

    /// Specifies the lengths of the alternating dashes and gaps that form the dash pattern. The lengths are later scaled by the line width. To convert a dash length to pixels, multiply the length by the current line width. Note that GeoJSON sources with `lineMetrics: true` specified won't render dashed lines to the expected scale. Also note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    public var lineDasharray: [Double]? {
        didSet {
            do {
                try style.setLayerProperty(for: layerId, property: "line-dasharray", value: lineDasharray as Any)
            } catch {
                Log.warning(forMessage: "Could not set PolylineAnnotationManager.lineDasharray due to error: \(error)",
                            category: "Annotations")
            }
        }
    }

    /// Defines a gradient with which to color a line feature. Can only be used with GeoJSON sources that specify `"lineMetrics": true`.
    public var lineGradient: ColorRepresentable? {
        didSet {
            do {
                try style.setLayerProperty(for: layerId, property: "line-gradient", value: lineGradient?.rgbaDescription as Any)
            } catch {
                Log.warning(forMessage: "Could not set PolylineAnnotationManager.lineGradient due to error: \(error)",
                            category: "Annotations")
            }
        }
    }

    /// The geometry's offset. Values are [x, y] where negatives indicate left and up, respectively.
    public var lineTranslate: [Double]? {
        didSet {
            do {
                try style.setLayerProperty(for: layerId, property: "line-translate", value: lineTranslate as Any)
            } catch {
                Log.warning(forMessage: "Could not set PolylineAnnotationManager.lineTranslate due to error: \(error)",
                            category: "Annotations")
            }
        }
    }

    /// Controls the frame of reference for `line-translate`.
    public var lineTranslateAnchor: LineTranslateAnchor? {
        didSet {
            do {
                try style.setLayerProperty(for: layerId, property: "line-translate-anchor", value: lineTranslateAnchor?.rawValue as Any)
            } catch {
                Log.warning(forMessage: "Could not set PolylineAnnotationManager.lineTranslateAnchor due to error: \(error)",
                            category: "Annotations")
            }
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
        syncAnnotationsIfNeeded()
    }
}

// End of generated file.
// swiftlint:enable all
