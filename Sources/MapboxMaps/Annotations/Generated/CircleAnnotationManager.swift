// This file is generated.
import Foundation
import Turf

public struct CircleAnnotationManager {

    public var annotations = Set<CircleAnnotation>() {
        didSet {
            guard annotations != oldValue else { return }
            syncAnnotations()
         }
    }

    public struct Options: Codable, Equatable {
        
        /// Orientation of circle when map is pitched.
        public var circlePitchAlignment: Value<CirclePitchAlignment>? 
        
        /// Controls the scaling behavior of the circle when the map is pitched.
        public var circlePitchScale: Value<CirclePitchScale>? 
        
        /// The geometry's offset. Values are [x, y] where negatives indicate left and up, respectively.
        public var circleTranslate: Value<[Double]>? 
        
        /// Controls the frame of reference for `circle-translate`.
        public var circleTranslateAnchor: Value<CircleTranslateAnchor>? 
    }
    
    public var options = Options() {
        didSet {
            guard options != oldValue else { return }
            
            do {
                let data = try JSONEncoder().encode(options)
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    fatalError("Could not convert CircleAnnotationManager.Options to JSON object")
                }
                try style.setLayerProperties(for: layerId, properties: json)
            } catch {
                fatalError("Could not encode CircleAnnotationManager.Options")
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
            fatalError("Failed to create source / layer in CircleAnnotationManager")
        }
    }

    internal func makeSourceAndLayer() throws {

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

        try style.addLayer(layer)
    }

    internal func syncAnnotations() {
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