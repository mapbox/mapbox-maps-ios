// This file is generated.
import Foundation
import Turf
@_implementationOnly import MapboxCommon_Private

/// A delegate that is called when a tap is detected on an annotation (or on several of them).
public protocol CircleAnnotationInteractionDelegate {

    /// This method is invoked when a tap gesture is detected
    /// - Parameters:
    ///   - manager: The `CircleAnnotationManager` that detected this tap gesture
    ///   - annotations: A list of `CircleAnnotations` that were tapped
    func annotationsTapped(forManager manager: CircleAnnotationManager,
                           annotations: Set<CircleAnnotation>)

}

/// An instance of `CircleAnnotationManager` is responsible for a collection of `CircleAnnotation`s. 
public class CircleAnnotationManager: AnnotationManager {

    /// The collection of CircleAnnotations being managed
    public var annotations = Set<CircleAnnotation>() {
        didSet {
            guard annotations != oldValue else { return }
            syncAnnotations()
         }
    }

    /// Set this delegate in order to be called back if a tap occurs on an annotation being managed by this manager.
    public var delegate: CircleAnnotationInteractionDelegate? {
        didSet {
            if delegate != nil {
                setupTapRecognizer()
            } else {
                guard let view = view, let recognizer = tapRecognizer else { return }
                view.removeGestureRecognizer(recognizer)
                tapRecognizer = nil
            }
        }
    }

    /// The `UITapGestureRecognizer` that's listening to touch events on the map
    private var tapRecognizer: UITapGestureRecognizer?

    internal func setupTapRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.numberOfTouchesRequired = 1
        view?.addGestureRecognizer(tapGestureRecognizer)
        tapRecognizer = tapGestureRecognizer
    }
    
    @objc internal func handleTap(_ tap: UITapGestureRecognizer) {
        let options = RenderedQueryOptions(layerIds: [layerId], filter: nil)
        mapFeatureQueryable?.queryRenderedFeatures(
            at: tap.location(in: view),
            options: options) { [weak self] (result) in
            guard let self = self else { return }
            
            switch result {
            case .success(let queriedFeatures):
                if let annotationIds = queriedFeatures.compactMap(\.feature.properties["annotation-id"]) as? [String]{

                    let tappedAnnotations = self.annotations.filter { annotationIds.contains($0.id)}
                    if !tappedAnnotations.isEmpty {
                        self.delegate?.annotationsTapped(
                            forManager: self,
                            annotations: tappedAnnotations)
                    }
                }
            case .failure(let error):
                Log.warning(forMessage: "Failed to query map for annotations due to error: \(error)", 
                            category: "Annotations")
            }
        }
    }
        
    /// Orientation of circle when map is pitched.
    public var circlePitchAlignment: CirclePitchAlignment? {
        didSet {
            do {
                guard let circlePitchAlignment = circlePitchAlignment else { return }
                try style?.setLayerProperty(for: layerId, property: "circle-pitch-alignment ", value: circlePitchAlignment.rawValue)
            } catch {
                Log.warning(forMessage: "Could not set CircleAnnotationManager.circlePitchAlignment",
                            category: "Annotations")
            }
        }
    }
        
    /// Controls the scaling behavior of the circle when the map is pitched.
    public var circlePitchScale: CirclePitchScale? {
        didSet {
            do {
                guard let circlePitchScale = circlePitchScale else { return }
                try style?.setLayerProperty(for: layerId, property: "circle-pitch-scale ", value: circlePitchScale.rawValue)
            } catch {
                Log.warning(forMessage: "Could not set CircleAnnotationManager.circlePitchScale",
                            category: "Annotations")
            }
        }
    }
        
    /// The geometry's offset. Values are [x, y] where negatives indicate left and up, respectively.
    public var circleTranslate: [Double]? {
        didSet {
            do {
                guard let circleTranslate = circleTranslate else { return }
                try style?.setLayerProperty(for: layerId, property: "circle-translate ", value: circleTranslate)
            } catch {
                Log.warning(forMessage: "Could not set CircleAnnotationManager.circleTranslate",
                            category: "Annotations")
            }
        }
    }
        
    /// Controls the frame of reference for `circle-translate`.
    public var circleTranslateAnchor: CircleTranslateAnchor? {
        didSet {
            do {
                guard let circleTranslateAnchor = circleTranslateAnchor else { return }
                try style?.setLayerProperty(for: layerId, property: "circle-translate-anchor ", value: circleTranslateAnchor.rawValue)
            } catch {
                Log.warning(forMessage: "Could not set CircleAnnotationManager.circleTranslateAnchor",
                            category: "Annotations")
            }
        }
    }
    
    public let id: String
    private weak var style: Style?
    public let sourceId: String
    public let layerId: String
    private weak var mapFeatureQueryable: MapFeatureQueryable?
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
            fatalError("Failed to create source / layer in CircleAnnotationManager")
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
            fatalError("Style must exist when adding a source and layer for annotations")
        }

        // Add the source with empty `data` property
        var source = GeoJSONSource()
        source.data = .empty
        try style.addSource(source, id: sourceId)

        // Add the correct backing layer for this annotation type
        var layer = CircleLayer(id: layerId)
        layer.source = sourceId

        layer.circleSortKey = .expression( Exp(.get) { "circle-sort-key" } )
        layer.circleBlur = .expression( Exp(.get) { "circle-blur" } )
        layer.circleColor = .expression( Exp(.get) { "circle-color" } )
        layer.circleOpacity = .expression( Exp(.get) { "circle-opacity" } )
        layer.circleRadius = .expression( Exp(.get) { "circle-radius" } )
        layer.circleStrokeColor = .expression( Exp(.get) { "circle-stroke-color" } )
        layer.circleStrokeOpacity = .expression( Exp(.get) { "circle-stroke-opacity" } )
        layer.circleStrokeWidth = .expression( Exp(.get) { "circle-stroke-width" } )

        try style.addLayer(layer, layerPosition: layerPosition)
    }

    internal func syncAnnotations() {

        guard let style = style else { 
            fatalError("Style must exist when adding/removing annotations")
        }

        let featureCollection = Turf.FeatureCollection(features: annotations.map(\.feature))
        do {
            let data = try JSONEncoder().encode(featureCollection)
            guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                fatalError("Could not convert annotation features to json object in CircleAnnotationManager")
            }
            try style.setSourceProperty(for: sourceId, property: "data", value: jsonObject )
        } catch {
            fatalError("Could not update annotations in CircleAnnotationManager")
        }
    }
} 
// End of generated file.