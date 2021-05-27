// swiftlint:disable all
// This file is generated.
import Foundation
import Turf
@_implementationOnly import MapboxCommon_Private

/// A delegate that is called when a tap is detected on an annotation (or on several of them).
public protocol PolylineAnnotationInteractionDelegate {

    /// This method is invoked when a tap gesture is detected
    /// - Parameters:
    ///   - manager: The `PolylineAnnotationManager` that detected this tap gesture
    ///   - annotations: A list of `PolylineAnnotations` that were tapped
    func annotationsTapped(forManager manager: PolylineAnnotationManager,
                           annotations: [PolylineAnnotation])

}

/// An instance of `PolylineAnnotationManager` is responsible for a collection of `PolylineAnnotation`s. 
public class PolylineAnnotationManager: AnnotationManager {

    // MARK: - Annotations -
    
    /// The collection of PolylineAnnotations being managed
    public var annotations = [PolylineAnnotation]() {
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
            fatalError("Failed to create source / layer in PolylineAnnotationManager")
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
        var layer = LineLayer(id: layerId)
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
                Log.warning(forMessage: "Could not set layer property \(property) in PolylineAnnotationManager",
                            category: "Annotations")
            }
        }
        
        let featureCollection = Turf.FeatureCollection(features: annotations.map(\.feature))
        do {
            let data = try JSONEncoder().encode(featureCollection)
            guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                fatalError("Could not convert annotation features to json object in PolylineAnnotationManager")
            }
            try style.setSourceProperty(for: sourceId, property: "data", value: jsonObject )
        } catch {
            fatalError("Could not update annotations in PolylineAnnotationManager")
        }
    }

    // MARK: - Common layer properties -
        
    /// The display of line endings.
    public var lineCap: LineCap? {
        didSet {
            do {
                guard let lineCap = lineCap else { return }
                try style?.setLayerProperty(for: layerId, property: "line-cap", value: lineCap.rawValue)
            } catch {
                Log.warning(forMessage: "Could not set PolylineAnnotationManager.lineCap",
                            category: "Annotations")
            }
        }
    }
        
    /// Used to automatically convert miter joins to bevel joins for sharp angles.
    public var lineMiterLimit: Double? {
        didSet {
            do {
                guard let lineMiterLimit = lineMiterLimit else { return }
                try style?.setLayerProperty(for: layerId, property: "line-miter-limit", value: lineMiterLimit)
            } catch {
                Log.warning(forMessage: "Could not set PolylineAnnotationManager.lineMiterLimit",
                            category: "Annotations")
            }
        }
    }
        
    /// Used to automatically convert round joins to miter joins for shallow angles.
    public var lineRoundLimit: Double? {
        didSet {
            do {
                guard let lineRoundLimit = lineRoundLimit else { return }
                try style?.setLayerProperty(for: layerId, property: "line-round-limit", value: lineRoundLimit)
            } catch {
                Log.warning(forMessage: "Could not set PolylineAnnotationManager.lineRoundLimit",
                            category: "Annotations")
            }
        }
    }
        
    /// Specifies the lengths of the alternating dashes and gaps that form the dash pattern. The lengths are later scaled by the line width. To convert a dash length to pixels, multiply the length by the current line width. Note that GeoJSON sources with `lineMetrics: true` specified won't render dashed lines to the expected scale. Also note that zoom-dependent expressions will be evaluated only at integer zoom levels.
    public var lineDasharray: [Double]? {
        didSet {
            do {
                guard let lineDasharray = lineDasharray else { return }
                try style?.setLayerProperty(for: layerId, property: "line-dasharray", value: lineDasharray)
            } catch {
                Log.warning(forMessage: "Could not set PolylineAnnotationManager.lineDasharray",
                            category: "Annotations")
            }
        }
    }
        
    /// Defines a gradient with which to color a line feature. Can only be used with GeoJSON sources that specify `"lineMetrics": true`.
    public var lineGradient: ColorRepresentable? {
        didSet {
            do {
                guard let lineGradient = lineGradient else { return }
                try style?.setLayerProperty(for: layerId, property: "line-gradient", value: lineGradient.rgbaDescription)
            } catch {
                Log.warning(forMessage: "Could not set PolylineAnnotationManager.lineGradient",
                            category: "Annotations")
            }
        }
    }
        
    /// The geometry's offset. Values are [x, y] where negatives indicate left and up, respectively.
    public var lineTranslate: [Double]? {
        didSet {
            do {
                guard let lineTranslate = lineTranslate else { return }
                try style?.setLayerProperty(for: layerId, property: "line-translate", value: lineTranslate)
            } catch {
                Log.warning(forMessage: "Could not set PolylineAnnotationManager.lineTranslate",
                            category: "Annotations")
            }
        }
    }
        
    /// Controls the frame of reference for `line-translate`.
    public var lineTranslateAnchor: LineTranslateAnchor? {
        didSet {
            do {
                guard let lineTranslateAnchor = lineTranslateAnchor else { return }
                try style?.setLayerProperty(for: layerId, property: "line-translate-anchor", value: lineTranslateAnchor.rawValue)
            } catch {
                Log.warning(forMessage: "Could not set PolylineAnnotationManager.lineTranslateAnchor",
                            category: "Annotations")
            }
        }
    }
    
    // MARK: - Selection Handling -

    /// Set this delegate in order to be called back if a tap occurs on an annotation being managed by this manager.
    public weak var delegate: PolylineAnnotationInteractionDelegate? {
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

    internal func handleAnnotationSelection(annotationIds: [String]) -> [PolylineAnnotation] {
        
        var updates: [(index: Int, annotation: PolylineAnnotation)] = []
        
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