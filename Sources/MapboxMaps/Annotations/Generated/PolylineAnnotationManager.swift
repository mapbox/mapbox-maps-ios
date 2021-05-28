// swiftlint:disable all
// This file is generated.
import Foundation
import Turf
@_implementationOnly import MapboxCommon_Private

/// An instance of `PolylineAnnotationManager` is responsible for a collection of `PolylineAnnotation`s. 
public class PolylineAnnotationManager: AnnotationManager {

    // MARK: - Annotations -
    
    /// The collection of PolylineAnnotations being managed
    public private(set) var annotations = [PolylineAnnotation]() {
        didSet {
            syncAnnotations()
         }
    }

    /// Syncs `PolylineAnnotation`s to the map
    /// NOTE: calling this repeatedly results in degraded performance
    public func syncAnnotations(_ annotations: [PolylineAnnotation]) {
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
            Log.error(forMessage: "Failed to create source / layer in PolylineAnnotationManager", category: "Annotations")
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
        var layer = LineLayer(id: layerId)
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
                try style?.setLayerProperty(for: layerId, property: "line-cap", value: lineCap?.rawValue as Any)
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
                try style?.setLayerProperty(for: layerId, property: "line-miter-limit", value: lineMiterLimit as Any)
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
                try style?.setLayerProperty(for: layerId, property: "line-round-limit", value: lineRoundLimit as Any)
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
                try style?.setLayerProperty(for: layerId, property: "line-dasharray", value: lineDasharray as Any)
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
                try style?.setLayerProperty(for: layerId, property: "line-gradient", value: lineGradient?.rgbaDescription as Any)
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
                try style?.setLayerProperty(for: layerId, property: "line-translate", value: lineTranslate as Any)
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
                try style?.setLayerProperty(for: layerId, property: "line-translate-anchor", value: lineTranslateAnchor?.rawValue as Any)
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