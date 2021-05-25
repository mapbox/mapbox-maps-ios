// This file is generated.
import Foundation
import Turf
@_implementationOnly import MapboxCommon_Private

/// A delegate that is called when a tap is detected on an annotation (or on several of them).
public protocol PolygonAnnotationInteractionDelegate {

    /// This method is invoked when a tap gesture is detected
    /// - Parameters:
    ///   - manager: The `PolygonAnnotationManager` that detected this tap gesture
    ///   - annotations: A list of `PolygonAnnotations` that were tapped
    func annotationsTapped(forManager manager: PolygonAnnotationManager,
                           annotations: Set<PolygonAnnotation>)

}

/// An instance of `PolygonAnnotationManager` is responsible for a collection of `PolygonAnnotation`s. 
public class PolygonAnnotationManager: AnnotationManager {

    /// The collection of PolygonAnnotations being managed
    public var annotations = Set<PolygonAnnotation>() {
        didSet {
            guard annotations != oldValue else { return }
            syncAnnotations()
         }
    }

    /// Set this delegate in order to be called back if a tap occurs on an annotation being managed by this manager.
    public var delegate: PolygonAnnotationInteractionDelegate? {
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
        
    /// Whether or not the fill should be antialiased.
    public var fillAntialias: Bool? {
        didSet {
            do {
                guard let fillAntialias = fillAntialias else { return }
                try style?.setLayerProperty(for: layerId, property: "fill-antialias ", value: fillAntialias)
            } catch {
                Log.warning(forMessage: "Could not set PolygonAnnotationManager.fillAntialias",
                            category: "Annotations")
            }
        }
    }
        
    /// The geometry's offset. Values are [x, y] where negatives indicate left and up, respectively.
    public var fillTranslate: [Double]? {
        didSet {
            do {
                guard let fillTranslate = fillTranslate else { return }
                try style?.setLayerProperty(for: layerId, property: "fill-translate ", value: fillTranslate)
            } catch {
                Log.warning(forMessage: "Could not set PolygonAnnotationManager.fillTranslate",
                            category: "Annotations")
            }
        }
    }
        
    /// Controls the frame of reference for `fill-translate`.
    public var fillTranslateAnchor: FillTranslateAnchor? {
        didSet {
            do {
                guard let fillTranslateAnchor = fillTranslateAnchor else { return }
                try style?.setLayerProperty(for: layerId, property: "fill-translate-anchor ", value: fillTranslateAnchor.rawValue)
            } catch {
                Log.warning(forMessage: "Could not set PolygonAnnotationManager.fillTranslateAnchor",
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
            fatalError("Failed to create source / layer in PolygonAnnotationManager")
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
        var layer = FillLayer(id: layerId)
        layer.source = sourceId

        layer.fillSortKey = .expression( Exp(.get) { "fill-sort-key" } )
        layer.fillColor = .expression( Exp(.get) { "fill-color" } )
        layer.fillOpacity = .expression( Exp(.get) { "fill-opacity" } )
        layer.fillOutlineColor = .expression( Exp(.get) { "fill-outline-color" } )
        layer.fillPattern = .expression( Exp(.get) { "fill-pattern" } )

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
                fatalError("Could not convert annotation features to json object in PolygonAnnotationManager")
            }
            try style.setSourceProperty(for: sourceId, property: "data", value: jsonObject )
        } catch {
            fatalError("Could not update annotations in PolygonAnnotationManager")
        }
    }
} 
// End of generated file.