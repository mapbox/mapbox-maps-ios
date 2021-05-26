// swiftlint:disable all
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
                           annotations: [CircleAnnotation])

}

/// An instance of `CircleAnnotationManager` is responsible for a collection of `CircleAnnotation`s. 
public class CircleAnnotationManager: AnnotationManager {

    // MARK: - Annotations -
    
    /// The collection of CircleAnnotations being managed
    public var annotations = [CircleAnnotation]() {
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
                Log.warning(forMessage: "Could not set layer property \(property) in CircleAnnotationManager",
                            category: "Annotations")
            }
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

    // MARK: - Common layer properties -
        
    /// Orientation of circle when map is pitched.
    public var circlePitchAlignment: CirclePitchAlignment? {
        didSet {
            do {
                guard let circlePitchAlignment = circlePitchAlignment else { return }
                try style?.setLayerProperty(for: layerId, property: "circle-pitch-alignment", value: circlePitchAlignment.rawValue)
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
                try style?.setLayerProperty(for: layerId, property: "circle-pitch-scale", value: circlePitchScale.rawValue)
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
                try style?.setLayerProperty(for: layerId, property: "circle-translate", value: circleTranslate)
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
                try style?.setLayerProperty(for: layerId, property: "circle-translate-anchor", value: circleTranslateAnchor.rawValue)
            } catch {
                Log.warning(forMessage: "Could not set CircleAnnotationManager.circleTranslateAnchor",
                            category: "Annotations")
            }
        }
    }
    
    // MARK: - Selection Handling -

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

    internal func handleAnnotationSelection(annotationIds: [String]) -> [CircleAnnotation] {
        
        var updates: [(index: Int, annotation: CircleAnnotation)] = []
        
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