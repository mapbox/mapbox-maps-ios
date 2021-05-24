// This file is generated.
import Foundation
import Turf

public struct PolygonAnnotationManager {

    public var annotations = Set<PolygonAnnotation>() {
        didSet {
            guard annotations != oldValue else { return }
            syncAnnotations()
         }
    }

    public struct Options: Codable, Equatable {
        
        /// Whether or not the fill should be antialiased.
        public var fillAntialias: Value<Bool>? 
        
        /// The geometry's offset. Values are [x, y] where negatives indicate left and up, respectively.
        public var fillTranslate: Value<[Double]>? 
        
        /// Controls the frame of reference for `fill-translate`.
        public var fillTranslateAnchor: Value<FillTranslateAnchor>? 
    }
    
    public var options = Options() {
        didSet {
            guard options != oldValue else { return }
            
            do {
                let data = try JSONEncoder().encode(options)
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    fatalError("Could not convert PolygonAnnotationManager.Options to JSON object")
                }
                try style.setLayerProperties(for: layerId, properties: json)
            } catch {
                fatalError("Could not encode PolygonAnnotationManager.Options")
            }
        }
    }
    
    private let id: String
    private let style: Style
    private let sourceId: String
    private let layerId: String

    internal init(id: String, style: Style) {
        self.id = id
        self.style = style
        self.sourceId = id + "-source"
        self.layerId = id + "-layer"
        
        do {
            try makeSourceAndLayer()
        } catch {
            fatalError("Failed to create source / layer in PolygonAnnotationManager")
        }
    }

    internal func makeSourceAndLayer() throws {

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

        try style.addLayer(layer)
    }

    internal func syncAnnotations() {
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