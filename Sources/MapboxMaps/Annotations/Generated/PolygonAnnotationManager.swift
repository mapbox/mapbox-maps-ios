// swiftlint:disable all
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
                           annotations: [PolygonAnnotation])

}

/// An instance of `PolygonAnnotationManager` is responsible for a collection of `PolygonAnnotation`s. 
public class PolygonAnnotationManager: AnnotationManager {

    // MARK: - Annotations -
    
    /// The collection of PolygonAnnotations being managed
    public var annotations = [PolygonAnnotation]() {
        didSet {
            syncAnnotations()
         }
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
        try style.addLayer(layer, layerPosition: layerPosition)
    }

    // MARK: - Sync annotations to map -
    
    internal func syncAnnotations() {

        guard let style = style else { 
            fatalError("Style must exist when adding/removing annotations")
        }

        let allDataDrivenPropertiesUsed = Set(annotations.flatMap(\.dataDrivenPropertiesUsedSet))
        for property in allDataDrivenPropertiesUsed {
            do {
                try style.setLayerProperty(for: layerId, property: property, value: ["get", property] )
            } catch {
                Log.warning(forMessage: "Could not set layer property \(property) in PolygonAnnotationManager",
                            category: "Annotations")
            }
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

    // MARK: - Common layer properties -
        
    /// Whether or not the fill should be antialiased.
    public var fillAntialias: Bool? {
        didSet {
            do {
                guard let fillAntialias = fillAntialias else { return }
                try style?.setLayerProperty(for: layerId, property: "fill-antialias", value: fillAntialias)
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
                try style?.setLayerProperty(for: layerId, property: "fill-translate", value: fillTranslate)
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
                try style?.setLayerProperty(for: layerId, property: "fill-translate-anchor", value: fillTranslateAnchor.rawValue)
            } catch {
                Log.warning(forMessage: "Could not set PolygonAnnotationManager.fillTranslateAnchor",
                            category: "Annotations")
            }
        }
    }
    
    // MARK: - Selection Handling -

    /// Set this delegate in order to be called back if a tap occurs on an annotation being managed by this manager.
    public weak var delegate: PolygonAnnotationInteractionDelegate? {
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
                    
                    let selectedAnnotations = self.handleAnnotationSelection(annotationIds: annotationIds)
                    
                    if !selectedAnnotations.isEmpty {
                        self.delegate?.annotationsTapped(
                            forManager: self,
                            annotations: selectedAnnotations)
                    }
                }
            case .failure(let error):
                Log.warning(forMessage: "Failed to query map for annotations due to error: \(error)", 
                            category: "Annotations")
            }
        }
    }

    internal func handleAnnotationSelection(annotationIds: [String]) -> [PolygonAnnotation] {
        
        var updates: [(index: Int, annotation: PolygonAnnotation)] = []
        
        for (index, annotation) in annotations.enumerated() where annotationIds.contains(annotation.id) {
            var updatedAnnotation = annotation
            updatedAnnotation.isSelected.toggle()
            updates.append((index: index, annotation: updatedAnnotation))
        }
        
        var tempAnnotations = annotations
        
        for update in updates {
            tempAnnotations[update.index] = update.annotation
        }
        
        annotations = tempAnnotations
        return updates.map { $0.annotation }
    }

} 
// End of generated file.
// swiftlint:enable all