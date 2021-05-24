// This file is generated.
import Foundation
import Turf

public struct PolylineAnnotationManager {

    public var annotations = Set<PolylineAnnotation>() {
        didSet {
            guard annotations != oldValue else { return }
            syncAnnotations()
         }
    }

    public struct Options: Codable, Equatable {
        
        /// The display of line endings.
        public var lineCap: Value<LineCap>? 
        
        /// Used to automatically convert miter joins to bevel joins for sharp angles.
        public var lineMiterLimit: Value<Double>? 
        
        /// Used to automatically convert round joins to miter joins for shallow angles.
        public var lineRoundLimit: Value<Double>? 
        
        /// Specifies the lengths of the alternating dashes and gaps that form the dash pattern. The lengths are later scaled by the line width. To convert a dash length to pixels, multiply the length by the current line width. Note that GeoJSON sources with `lineMetrics: true` specified won't render dashed lines to the expected scale. Also note that zoom-dependent expressions will be evaluated only at integer zoom levels.
        public var lineDasharray: Value<[Double]>? 
        
        /// Defines a gradient with which to color a line feature. Can only be used with GeoJSON sources that specify `"lineMetrics": true`.
        public var lineGradient: Value<ColorRepresentable>? 
        
        /// The geometry's offset. Values are [x, y] where negatives indicate left and up, respectively.
        public var lineTranslate: Value<[Double]>? 
        
        /// Controls the frame of reference for `line-translate`.
        public var lineTranslateAnchor: Value<LineTranslateAnchor>? 
    }
    
    public var options = Options() {
        didSet {
            guard options != oldValue else { return }
            
            do {
                let data = try JSONEncoder().encode(options)
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    fatalError("Could not convert PolylineAnnotationManager.Options to JSON object")
                }
                try style.setLayerProperties(for: layerId, properties: json)
            } catch {
                fatalError("Could not encode PolylineAnnotationManager.Options")
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
            fatalError("Failed to create source / layer in PolylineAnnotationManager")
        }
    }

    internal func makeSourceAndLayer() throws {

        // Add the source with empty `data` property
        var source = GeoJSONSource()
        source.data = .empty
        try style.addSource(source, id: sourceId)

        // Add the correct backing layer for this annotation type
        var layer = LineLayer(id: layerId)
        layer.source = sourceId

        layer.lineJoin = .expression( Exp(.get) { "line-join" } )
        layer.lineSortKey = .expression( Exp(.get) { "line-sort-key" } )
        layer.lineBlur = .expression( Exp(.get) { "line-blur" } )
        layer.lineColor = .expression( Exp(.get) { "line-color" } )
        layer.lineGapWidth = .expression( Exp(.get) { "line-gap-width" } )
        layer.lineOffset = .expression( Exp(.get) { "line-offset" } )
        layer.lineOpacity = .expression( Exp(.get) { "line-opacity" } )
        layer.linePattern = .expression( Exp(.get) { "line-pattern" } )
        layer.lineWidth = .expression( Exp(.get) { "line-width" } )

        try style.addLayer(layer)
    }

    internal func syncAnnotations() {
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
} 
// End of generated file.