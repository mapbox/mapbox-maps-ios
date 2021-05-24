// This file is generated.
import Foundation
import Turf

public struct PointAnnotationManager {

    public var annotations = Set<PointAnnotation>() {
        didSet {
            guard annotations != oldValue else { return }
            syncAnnotations()
         }
    }

    public struct Options: Codable, Equatable {
        
        /// If true, the icon will be visible even if it collides with other previously drawn symbols.
        public var iconAllowOverlap: Value<Bool>? 
        
        /// If true, other symbols can be visible even if they collide with the icon.
        public var iconIgnorePlacement: Value<Bool>? 
        
        /// If true, the icon may be flipped to prevent it from being rendered upside-down.
        public var iconKeepUpright: Value<Bool>? 
        
        /// If true, text will display without their corresponding icons when the icon collides with other symbols and the text does not.
        public var iconOptional: Value<Bool>? 
        
        /// Size of the additional area around the icon bounding box used for detecting symbol collisions.
        public var iconPadding: Value<Double>? 
        
        /// Orientation of icon when map is pitched.
        public var iconPitchAlignment: Value<IconPitchAlignment>? 
        
        /// In combination with `symbol-placement`, determines the rotation behavior of icons.
        public var iconRotationAlignment: Value<IconRotationAlignment>? 
        
        /// Scales the icon to fit around the associated text.
        public var iconTextFit: Value<IconTextFit>? 
        
        /// Size of the additional area added to dimensions determined by `icon-text-fit`, in clockwise order: top, right, bottom, left.
        public var iconTextFitPadding: Value<[Double]>? 
        
        /// If true, the symbols will not cross tile edges to avoid mutual collisions. Recommended in layers that don't have enough padding in the vector tile to prevent collisions, or if it is a point symbol layer placed after a line symbol layer. When using a client that supports global collision detection, like Mapbox GL JS version 0.42.0 or greater, enabling this property is not needed to prevent clipped labels at tile boundaries.
        public var symbolAvoidEdges: Value<Bool>? 
        
        /// Label placement relative to its geometry.
        public var symbolPlacement: Value<SymbolPlacement>? 
        
        /// Distance between two symbol anchors.
        public var symbolSpacing: Value<Double>? 
        
        /// Determines whether overlapping symbols in the same layer are rendered in the order that they appear in the data source or by their y-position relative to the viewport. To control the order and prioritization of symbols otherwise, use `symbol-sort-key`.
        public var symbolZOrder: Value<SymbolZOrder>? 
        
        /// If true, the text will be visible even if it collides with other previously drawn symbols.
        public var textAllowOverlap: Value<Bool>? 
        
        /// If true, other symbols can be visible even if they collide with the text.
        public var textIgnorePlacement: Value<Bool>? 
        
        /// If true, the text may be flipped vertically to prevent it from being rendered upside-down.
        public var textKeepUpright: Value<Bool>? 
        
        /// Text leading value for multi-line text.
        public var textLineHeight: Value<Double>? 
        
        /// Maximum angle change between adjacent characters.
        public var textMaxAngle: Value<Double>? 
        
        /// If true, icons will display without their corresponding text when the text collides with other symbols and the icon does not.
        public var textOptional: Value<Bool>? 
        
        /// Size of the additional area around the text bounding box used for detecting symbol collisions.
        public var textPadding: Value<Double>? 
        
        /// Orientation of text when map is pitched.
        public var textPitchAlignment: Value<TextPitchAlignment>? 
        
        /// In combination with `symbol-placement`, determines the rotation behavior of the individual glyphs forming the text.
        public var textRotationAlignment: Value<TextRotationAlignment>? 
        
        /// To increase the chance of placing high-priority labels on the map, you can provide an array of `text-anchor` locations: the renderer will attempt to place the label at each location, in order, before moving onto the next label. Use `text-justify: auto` to choose justification based on anchor position. To apply an offset, use the `text-radial-offset` or the two-dimensional `text-offset`.
        public var textVariableAnchor: Value<[TextAnchor]>? 
        
        /// The property allows control over a symbol's orientation. Note that the property values act as a hint, so that a symbol whose language doesn’t support the provided orientation will be laid out in its natural orientation. Example: English point symbol will be rendered horizontally even if array value contains single 'vertical' enum value. The order of elements in an array define priority order for the placement of an orientation variant.
        public var textWritingMode: Value<[TextWritingMode]>? 
        
        /// Distance that the icon's anchor is moved from its original placement. Positive values indicate right and down, while negative values indicate left and up.
        public var iconTranslate: Value<[Double]>? 
        
        /// Controls the frame of reference for `icon-translate`.
        public var iconTranslateAnchor: Value<IconTranslateAnchor>? 
        
        /// Distance that the text's anchor is moved from its original placement. Positive values indicate right and down, while negative values indicate left and up.
        public var textTranslate: Value<[Double]>? 
        
        /// Controls the frame of reference for `text-translate`.
        public var textTranslateAnchor: Value<TextTranslateAnchor>? 
    }
    
    public var options = Options() {
        didSet {
            guard options != oldValue else { return }
            
            do {
                let data = try JSONEncoder().encode(options)
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    fatalError("Could not convert PointAnnotationManager.Options to JSON object")
                }
                try style.setLayerProperties(for: layerId, properties: json)
            } catch {
                fatalError("Could not encode PointAnnotationManager.Options")
            }
        }
    }
    
    private let id: String
    private let style: Style
    private let sourceId: String
    private let layerId: String

    internal init(id: String, style: Style, layerPosition: LayerPosition?) {
        self.id = id
        self.style = style
        self.sourceId = id + "-source"
        self.layerId = id + "-layer"
        
        do {
            try makeSourceAndLayer(layerPosition: layerPosition)
        } catch {
            fatalError("Failed to create source / layer in PointAnnotationManager")
        }
    }

    internal func makeSourceAndLayer(layerPosition: LayerPosition?) throws {

        // Add the source with empty `data` property
        var source = GeoJSONSource()
        source.data = .empty
        try style.addSource(source, id: sourceId)

        // Add the correct backing layer for this annotation type
        var layer = SymbolLayer(id: layerId)
        layer.source = sourceId
        
        // Show all icons and texts by default in point annotations. 
        layer.iconAllowOverlap = .constant(true)
        layer.textAllowOverlap = .constant(true)
        layer.iconIgnorePlacement = .constant(true)
        layer.textIgnorePlacement = .constant(true)

        layer.iconAnchor = .expression( Exp(.get) { "icon-anchor" } )
        layer.iconImage = .expression( Exp(.get) { "icon-image" } )
        layer.iconOffset = .expression( Exp(.get) { "icon-offset" } )
        layer.iconRotate = .expression( Exp(.get) { "icon-rotate" } )
        layer.iconSize = .expression( Exp(.get) { "icon-size" } )
        layer.symbolSortKey = .expression( Exp(.get) { "symbol-sort-key" } )
        layer.textAnchor = .expression( Exp(.get) { "text-anchor" } )
        layer.textField = .expression( Exp(.get) { "text-field" } )
        layer.textFont = .expression( Exp(.get) { "text-font" } )
        layer.textJustify = .expression( Exp(.get) { "text-justify" } )
        layer.textLetterSpacing = .expression( Exp(.get) { "text-letter-spacing" } )
        layer.textMaxWidth = .expression( Exp(.get) { "text-max-width" } )
        layer.textOffset = .expression( Exp(.get) { "text-offset" } )
        layer.textRadialOffset = .expression( Exp(.get) { "text-radial-offset" } )
        layer.textRotate = .expression( Exp(.get) { "text-rotate" } )
        layer.textSize = .expression( Exp(.get) { "text-size" } )
        layer.textTransform = .expression( Exp(.get) { "text-transform" } )
        layer.iconColor = .expression( Exp(.get) { "icon-color" } )
        layer.iconHaloBlur = .expression( Exp(.get) { "icon-halo-blur" } )
        layer.iconHaloColor = .expression( Exp(.get) { "icon-halo-color" } )
        layer.iconHaloWidth = .expression( Exp(.get) { "icon-halo-width" } )
        layer.iconOpacity = .expression( Exp(.get) { "icon-opacity" } )
        layer.textColor = .expression( Exp(.get) { "text-color" } )
        layer.textHaloBlur = .expression( Exp(.get) { "text-halo-blur" } )
        layer.textHaloColor = .expression( Exp(.get) { "text-halo-color" } )
        layer.textHaloWidth = .expression( Exp(.get) { "text-halo-width" } )
        layer.textOpacity = .expression( Exp(.get) { "text-opacity" } )

        try style.addLayer(layer, layerPosition: layerPosition)
    }

    internal func syncAnnotations() {
        let featureCollection = Turf.FeatureCollection(features: annotations.map(\.feature))
        do {
            let data = try JSONEncoder().encode(featureCollection)
            guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                fatalError("Could not convert annotation features to json object in PointAnnotationManager")
            }
            try style.setSourceProperty(for: sourceId, property: "data", value: jsonObject )
        } catch {
            fatalError("Could not update annotations in PointAnnotationManager")
        }
    }
} 
// End of generated file.