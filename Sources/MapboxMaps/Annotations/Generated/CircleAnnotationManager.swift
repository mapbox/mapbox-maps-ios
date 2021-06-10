// swiftlint:disable all
// This file is generated.
import Foundation
import Turf
@_implementationOnly import MapboxCommon_Private

/// An instance of `CircleAnnotationManager` is responsible for a collection of `CircleAnnotation`s. 
public class CircleAnnotationManager: AnnotationManager {

    // MARK: - Annotations -
    
    /// The collection of CircleAnnotations being managed
    public private(set) var annotations = [CircleAnnotation]() {
        didSet {
            syncAnnotations()
         }
    }

    /// Syncs `CircleAnnotation`s to the map
    /// NOTE: calling this repeatedly results in degraded performance
    public func syncAnnotations(_ annotations: [CircleAnnotation]) {
        self.annotations = annotations
    }

    // MARK: - AnnotationManager protocol conformance -
    
    public let sourceId: String
    
    public let layerId: String
    
    public let id: String

    // MARK:- Setup / Lifecycle -

    /// Dependency required to add sources/layers to the map
    private weak var style: Style?

    /// Dependency Required to query for rendered features on tap
    private weak var mapFeatureQueryable: MapFeatureQueryable?

    /// Dependency required to add gesture recognizer to the MapView
    private weak var view: UIView?

    internal init(id: String, style: Style, view: UIView, mapFeatureQueryable: MapFeatureQueryable, layerPosition: LayerPosition?) {
        self.id = id
        self.style = style
        self.sourceId = id + "-source"
        self.layerId = id + "-layer"
        self.view = view
        self.mapFeatureQueryable = mapFeatureQueryable

        do {
            try makeSourceAndLayer(layerPosition: layerPosition)
        } catch {
            Log.error(forMessage: "Failed to create source / layer in CircleAnnotationManager", category: "Annotations")
        }
    }

    deinit {
        removeBackingSourceAndLayer()
    }

    func removeBackingSourceAndLayer() {
        do {
            try style?.removeLayer(withId: layerId)
            try style?.removeSource(withId: layerId)
        } catch {
            Log.warning(forMessage: "Failed to remove source / layer from map for annotations due to error: \(error)",
                        category: "Annotations")
        }
    }

    internal func makeSourceAndLayer(layerPosition: LayerPosition?) throws {

        guard let style = style else { 
            Log.error(forMessage: "Style must exist when adding a source and layer for annotations", category: "Annotaitons")
            return
        }

        // Add the source with empty `data` property
        var source = GeoJSONSource()
        source.data = .empty
        try style.addSource(source, id: sourceId)

        // Add the correct backing layer for this annotation type
        var layer = CircleLayer(id: layerId)
        layer.source = sourceId
        try style.addLayer(layer, layerPosition: layerPosition)
    }

    // MARK: - Sync annotations to map -
    
    internal func syncAnnotations() {

        guard let style = style else { 
            Log.error(forMessage: "Style must exist when adding/removing annotations", category: "Annotations")
            return
        }

        let allDataDrivenPropertiesUsed = Set(annotations.flatMap(\.dataDrivenPropertiesUsedSet))
        for property in allDataDrivenPropertiesUsed {
            do {
                try style.setLayerProperty(for: layerId, property: property, value: ["get", property] )
            } catch {
                Log.error(forMessage: "Could not set layer property \(property) in CircleAnnotationManager",
                            category: "Annotations")
            }
        }
        
        let featureCollection = Turf.FeatureCollection(features: annotations.map(\.feature))
        do {
            let data = try JSONEncoder().encode(featureCollection)
            guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                Log.error(forMessage: "Could not convert annotation features to json object in CircleAnnotationManager", 
                            category: "Annotations")
                return
            }
            try style.setSourceProperty(for: sourceId, property: "data", value: jsonObject )
        } catch {
            Log.error(forMessage: "Could not update annotations in CircleAnnotationManager due to error: \(error)", 
                        category: "Annotations")
        }
    }

    // MARK: - Common layer properties -
        
    /// Orientation of circle when map is pitched.
    public var circlePitchAlignment: CirclePitchAlignment? {
        didSet {
            do {
                try style?.setLayerProperty(for: layerId, property: "circle-pitch-alignment", value: circlePitchAlignment?.rawValue as Any)
            } catch {
                Log.warning(forMessage: "Could not set CircleAnnotationManager.circlePitchAlignment due to error: \(error)",
                            category: "Annotations")
            }
        }
    }
        
    /// Controls the scaling behavior of the circle when the map is pitched.
    public var circlePitchScale: CirclePitchScale? {
        didSet {
            do {
                try style?.setLayerProperty(for: layerId, property: "circle-pitch-scale", value: circlePitchScale?.rawValue as Any)
            } catch {
                Log.warning(forMessage: "Could not set CircleAnnotationManager.circlePitchScale due to error: \(error)",
                            category: "Annotations")
            }
        }
    }
        
    /// The geometry's offset. Values are [x, y] where negatives indicate left and up, respectively.
    public var circleTranslate: [Double]? {
        didSet {
            do {
                try style?.setLayerProperty(for: layerId, property: "circle-translate", value: circleTranslate as Any)
            } catch {
                Log.warning(forMessage: "Could not set CircleAnnotationManager.circleTranslate due to error: \(error)",
                            category: "Annotations")
            }
        }
    }
        
    /// Controls the frame of reference for `circle-translate`.
    public var circleTranslateAnchor: CircleTranslateAnchor? {
        didSet {
            do {
                try style?.setLayerProperty(for: layerId, property: "circle-translate-anchor", value: circleTranslateAnchor?.rawValue as Any)
            } catch {
                Log.warning(forMessage: "Could not set CircleAnnotationManager.circleTranslateAnchor due to error: \(error)",
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
        mapFeatureQueryable?.queryRenderedFeatures(
            at: tap.location(in: view),
            options: options) { [weak self] (result) in
            
            guard let self = self else { return }
            
            switch result {
            
            case .success(let queriedFeatures):
                if let annotationIds = queriedFeatures.compactMap(\.feature.properties["annotation-id"]) as? [String] {

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
// End of generated file.
// swiftlint:enable all