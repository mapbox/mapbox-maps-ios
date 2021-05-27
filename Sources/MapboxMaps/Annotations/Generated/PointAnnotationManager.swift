// swiftlint:disable all
// This file is generated.
import Foundation
import Turf
@_implementationOnly import MapboxCommon_Private

/// A delegate that is called when a tap is detected on an annotation (or on several of them).
public protocol PointAnnotationInteractionDelegate {

    /// This method is invoked when a tap gesture is detected
    /// - Parameters:
    ///   - manager: The `PointAnnotationManager` that detected this tap gesture
    ///   - annotations: A list of `PointAnnotations` that were tapped
    func annotationsTapped(forManager manager: PointAnnotationManager,
                           annotations: [PointAnnotation])

}

/// An instance of `PointAnnotationManager` is responsible for a collection of `PointAnnotation`s. 
public class PointAnnotationManager: AnnotationManager {

    // MARK: - Annotations -
    
    /// The collection of PointAnnotations being managed
    public var annotations = [PointAnnotation]() {
        didSet {
            addImageToStyleIfNeeded()
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
            fatalError("Failed to create source / layer in PointAnnotationManager")
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
        var layer = SymbolLayer(id: layerId)
        layer.source = sourceId
            
        // Show all icons and texts by default in point annotations. 
        layer.iconAllowOverlap = .constant(true)
        layer.textAllowOverlap = .constant(true)
        layer.iconIgnorePlacement = .constant(true)
        layer.textIgnorePlacement = .constant(true)
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
                Log.warning(forMessage: "Could not set layer property \(property) in PointAnnotationManager",
                            category: "Annotations")
            }
        }
        
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

    // MARK: - Common layer properties -
        
    /// If true, the icon will be visible even if it collides with other previously drawn symbols.
    public var iconAllowOverlap: Bool? {
        didSet {
            do {
                guard let iconAllowOverlap = iconAllowOverlap else { return }
                try style?.setLayerProperty(for: layerId, property: "icon-allow-overlap", value: iconAllowOverlap)
            } catch {
                Log.warning(forMessage: "Could not set PointAnnotationManager.iconAllowOverlap",
                            category: "Annotations")
            }
        }
    }
        
    /// If true, other symbols can be visible even if they collide with the icon.
    public var iconIgnorePlacement: Bool? {
        didSet {
            do {
                guard let iconIgnorePlacement = iconIgnorePlacement else { return }
                try style?.setLayerProperty(for: layerId, property: "icon-ignore-placement", value: iconIgnorePlacement)
            } catch {
                Log.warning(forMessage: "Could not set PointAnnotationManager.iconIgnorePlacement",
                            category: "Annotations")
            }
        }
    }
        
    /// If true, the icon may be flipped to prevent it from being rendered upside-down.
    public var iconKeepUpright: Bool? {
        didSet {
            do {
                guard let iconKeepUpright = iconKeepUpright else { return }
                try style?.setLayerProperty(for: layerId, property: "icon-keep-upright", value: iconKeepUpright)
            } catch {
                Log.warning(forMessage: "Could not set PointAnnotationManager.iconKeepUpright",
                            category: "Annotations")
            }
        }
    }
        
    /// If true, text will display without their corresponding icons when the icon collides with other symbols and the text does not.
    public var iconOptional: Bool? {
        didSet {
            do {
                guard let iconOptional = iconOptional else { return }
                try style?.setLayerProperty(for: layerId, property: "icon-optional", value: iconOptional)
            } catch {
                Log.warning(forMessage: "Could not set PointAnnotationManager.iconOptional",
                            category: "Annotations")
            }
        }
    }
        
    /// Size of the additional area around the icon bounding box used for detecting symbol collisions.
    public var iconPadding: Double? {
        didSet {
            do {
                guard let iconPadding = iconPadding else { return }
                try style?.setLayerProperty(for: layerId, property: "icon-padding", value: iconPadding)
            } catch {
                Log.warning(forMessage: "Could not set PointAnnotationManager.iconPadding",
                            category: "Annotations")
            }
        }
    }
        
    /// Orientation of icon when map is pitched.
    public var iconPitchAlignment: IconPitchAlignment? {
        didSet {
            do {
                guard let iconPitchAlignment = iconPitchAlignment else { return }
                try style?.setLayerProperty(for: layerId, property: "icon-pitch-alignment", value: iconPitchAlignment.rawValue)
            } catch {
                Log.warning(forMessage: "Could not set PointAnnotationManager.iconPitchAlignment",
                            category: "Annotations")
            }
        }
    }
        
    /// In combination with `symbol-placement`, determines the rotation behavior of icons.
    public var iconRotationAlignment: IconRotationAlignment? {
        didSet {
            do {
                guard let iconRotationAlignment = iconRotationAlignment else { return }
                try style?.setLayerProperty(for: layerId, property: "icon-rotation-alignment", value: iconRotationAlignment.rawValue)
            } catch {
                Log.warning(forMessage: "Could not set PointAnnotationManager.iconRotationAlignment",
                            category: "Annotations")
            }
        }
    }
        
    /// Scales the icon to fit around the associated text.
    public var iconTextFit: IconTextFit? {
        didSet {
            do {
                guard let iconTextFit = iconTextFit else { return }
                try style?.setLayerProperty(for: layerId, property: "icon-text-fit", value: iconTextFit.rawValue)
            } catch {
                Log.warning(forMessage: "Could not set PointAnnotationManager.iconTextFit",
                            category: "Annotations")
            }
        }
    }
        
    /// Size of the additional area added to dimensions determined by `icon-text-fit`, in clockwise order: top, right, bottom, left.
    public var iconTextFitPadding: [Double]? {
        didSet {
            do {
                guard let iconTextFitPadding = iconTextFitPadding else { return }
                try style?.setLayerProperty(for: layerId, property: "icon-text-fit-padding", value: iconTextFitPadding)
            } catch {
                Log.warning(forMessage: "Could not set PointAnnotationManager.iconTextFitPadding",
                            category: "Annotations")
            }
        }
    }
        
    /// If true, the symbols will not cross tile edges to avoid mutual collisions. Recommended in layers that don't have enough padding in the vector tile to prevent collisions, or if it is a point symbol layer placed after a line symbol layer. When using a client that supports global collision detection, like Mapbox GL JS version 0.42.0 or greater, enabling this property is not needed to prevent clipped labels at tile boundaries.
    public var symbolAvoidEdges: Bool? {
        didSet {
            do {
                guard let symbolAvoidEdges = symbolAvoidEdges else { return }
                try style?.setLayerProperty(for: layerId, property: "symbol-avoid-edges", value: symbolAvoidEdges)
            } catch {
                Log.warning(forMessage: "Could not set PointAnnotationManager.symbolAvoidEdges",
                            category: "Annotations")
            }
        }
    }
        
    /// Label placement relative to its geometry.
    public var symbolPlacement: SymbolPlacement? {
        didSet {
            do {
                guard let symbolPlacement = symbolPlacement else { return }
                try style?.setLayerProperty(for: layerId, property: "symbol-placement", value: symbolPlacement.rawValue)
            } catch {
                Log.warning(forMessage: "Could not set PointAnnotationManager.symbolPlacement",
                            category: "Annotations")
            }
        }
    }
        
    /// Distance between two symbol anchors.
    public var symbolSpacing: Double? {
        didSet {
            do {
                guard let symbolSpacing = symbolSpacing else { return }
                try style?.setLayerProperty(for: layerId, property: "symbol-spacing", value: symbolSpacing)
            } catch {
                Log.warning(forMessage: "Could not set PointAnnotationManager.symbolSpacing",
                            category: "Annotations")
            }
        }
    }
        
    /// Determines whether overlapping symbols in the same layer are rendered in the order that they appear in the data source or by their y-position relative to the viewport. To control the order and prioritization of symbols otherwise, use `symbol-sort-key`.
    public var symbolZOrder: SymbolZOrder? {
        didSet {
            do {
                guard let symbolZOrder = symbolZOrder else { return }
                try style?.setLayerProperty(for: layerId, property: "symbol-z-order", value: symbolZOrder.rawValue)
            } catch {
                Log.warning(forMessage: "Could not set PointAnnotationManager.symbolZOrder",
                            category: "Annotations")
            }
        }
    }
        
    /// If true, the text will be visible even if it collides with other previously drawn symbols.
    public var textAllowOverlap: Bool? {
        didSet {
            do {
                guard let textAllowOverlap = textAllowOverlap else { return }
                try style?.setLayerProperty(for: layerId, property: "text-allow-overlap", value: textAllowOverlap)
            } catch {
                Log.warning(forMessage: "Could not set PointAnnotationManager.textAllowOverlap",
                            category: "Annotations")
            }
        }
    }
        
    /// If true, other symbols can be visible even if they collide with the text.
    public var textIgnorePlacement: Bool? {
        didSet {
            do {
                guard let textIgnorePlacement = textIgnorePlacement else { return }
                try style?.setLayerProperty(for: layerId, property: "text-ignore-placement", value: textIgnorePlacement)
            } catch {
                Log.warning(forMessage: "Could not set PointAnnotationManager.textIgnorePlacement",
                            category: "Annotations")
            }
        }
    }
        
    /// If true, the text may be flipped vertically to prevent it from being rendered upside-down.
    public var textKeepUpright: Bool? {
        didSet {
            do {
                guard let textKeepUpright = textKeepUpright else { return }
                try style?.setLayerProperty(for: layerId, property: "text-keep-upright", value: textKeepUpright)
            } catch {
                Log.warning(forMessage: "Could not set PointAnnotationManager.textKeepUpright",
                            category: "Annotations")
            }
        }
    }
        
    /// Text leading value for multi-line text.
    public var textLineHeight: Double? {
        didSet {
            do {
                guard let textLineHeight = textLineHeight else { return }
                try style?.setLayerProperty(for: layerId, property: "text-line-height", value: textLineHeight)
            } catch {
                Log.warning(forMessage: "Could not set PointAnnotationManager.textLineHeight",
                            category: "Annotations")
            }
        }
    }
        
    /// Maximum angle change between adjacent characters.
    public var textMaxAngle: Double? {
        didSet {
            do {
                guard let textMaxAngle = textMaxAngle else { return }
                try style?.setLayerProperty(for: layerId, property: "text-max-angle", value: textMaxAngle)
            } catch {
                Log.warning(forMessage: "Could not set PointAnnotationManager.textMaxAngle",
                            category: "Annotations")
            }
        }
    }
        
    /// If true, icons will display without their corresponding text when the text collides with other symbols and the icon does not.
    public var textOptional: Bool? {
        didSet {
            do {
                guard let textOptional = textOptional else { return }
                try style?.setLayerProperty(for: layerId, property: "text-optional", value: textOptional)
            } catch {
                Log.warning(forMessage: "Could not set PointAnnotationManager.textOptional",
                            category: "Annotations")
            }
        }
    }
        
    /// Size of the additional area around the text bounding box used for detecting symbol collisions.
    public var textPadding: Double? {
        didSet {
            do {
                guard let textPadding = textPadding else { return }
                try style?.setLayerProperty(for: layerId, property: "text-padding", value: textPadding)
            } catch {
                Log.warning(forMessage: "Could not set PointAnnotationManager.textPadding",
                            category: "Annotations")
            }
        }
    }
        
    /// Orientation of text when map is pitched.
    public var textPitchAlignment: TextPitchAlignment? {
        didSet {
            do {
                guard let textPitchAlignment = textPitchAlignment else { return }
                try style?.setLayerProperty(for: layerId, property: "text-pitch-alignment", value: textPitchAlignment.rawValue)
            } catch {
                Log.warning(forMessage: "Could not set PointAnnotationManager.textPitchAlignment",
                            category: "Annotations")
            }
        }
    }
        
    /// In combination with `symbol-placement`, determines the rotation behavior of the individual glyphs forming the text.
    public var textRotationAlignment: TextRotationAlignment? {
        didSet {
            do {
                guard let textRotationAlignment = textRotationAlignment else { return }
                try style?.setLayerProperty(for: layerId, property: "text-rotation-alignment", value: textRotationAlignment.rawValue)
            } catch {
                Log.warning(forMessage: "Could not set PointAnnotationManager.textRotationAlignment",
                            category: "Annotations")
            }
        }
    }
        
    /// To increase the chance of placing high-priority labels on the map, you can provide an array of `text-anchor` locations: the renderer will attempt to place the label at each location, in order, before moving onto the next label. Use `text-justify: auto` to choose justification based on anchor position. To apply an offset, use the `text-radial-offset` or the two-dimensional `text-offset`.
    public var textVariableAnchor: [String]? {
        didSet {
            do {
                guard let textVariableAnchor = textVariableAnchor else { return }
                try style?.setLayerProperty(for: layerId, property: "text-variable-anchor", value: textVariableAnchor)
            } catch {
                Log.warning(forMessage: "Could not set PointAnnotationManager.textVariableAnchor",
                            category: "Annotations")
            }
        }
    }
        
    /// The property allows control over a symbol's orientation. Note that the property values act as a hint, so that a symbol whose language doesn’t support the provided orientation will be laid out in its natural orientation. Example: English point symbol will be rendered horizontally even if array value contains single 'vertical' enum value. The order of elements in an array define priority order for the placement of an orientation variant.
    public var textWritingMode: [String]? {
        didSet {
            do {
                guard let textWritingMode = textWritingMode else { return }
                try style?.setLayerProperty(for: layerId, property: "text-writing-mode", value: textWritingMode)
            } catch {
                Log.warning(forMessage: "Could not set PointAnnotationManager.textWritingMode",
                            category: "Annotations")
            }
        }
    }
        
    /// Distance that the icon's anchor is moved from its original placement. Positive values indicate right and down, while negative values indicate left and up.
    public var iconTranslate: [Double]? {
        didSet {
            do {
                guard let iconTranslate = iconTranslate else { return }
                try style?.setLayerProperty(for: layerId, property: "icon-translate", value: iconTranslate)
            } catch {
                Log.warning(forMessage: "Could not set PointAnnotationManager.iconTranslate",
                            category: "Annotations")
            }
        }
    }
        
    /// Controls the frame of reference for `icon-translate`.
    public var iconTranslateAnchor: IconTranslateAnchor? {
        didSet {
            do {
                guard let iconTranslateAnchor = iconTranslateAnchor else { return }
                try style?.setLayerProperty(for: layerId, property: "icon-translate-anchor", value: iconTranslateAnchor.rawValue)
            } catch {
                Log.warning(forMessage: "Could not set PointAnnotationManager.iconTranslateAnchor",
                            category: "Annotations")
            }
        }
    }
        
    /// Distance that the text's anchor is moved from its original placement. Positive values indicate right and down, while negative values indicate left and up.
    public var textTranslate: [Double]? {
        didSet {
            do {
                guard let textTranslate = textTranslate else { return }
                try style?.setLayerProperty(for: layerId, property: "text-translate", value: textTranslate)
            } catch {
                Log.warning(forMessage: "Could not set PointAnnotationManager.textTranslate",
                            category: "Annotations")
            }
        }
    }
        
    /// Controls the frame of reference for `text-translate`.
    public var textTranslateAnchor: TextTranslateAnchor? {
        didSet {
            do {
                guard let textTranslateAnchor = textTranslateAnchor else { return }
                try style?.setLayerProperty(for: layerId, property: "text-translate-anchor", value: textTranslateAnchor.rawValue)
            } catch {
                Log.warning(forMessage: "Could not set PointAnnotationManager.textTranslateAnchor",
                            category: "Annotations")
            }
        }
    }
    
    /// Font stack to use for displaying text.
    public var textFont: [String]? {
        didSet {
            do {
                guard let textFont = textFont else { return }
                try style?.setLayerProperty(for: layerId, property: "text-font", value: textFont)
            } catch {
                Log.warning(forMessage: "Could not set PointAnnotationManager.textFont",
                            category: "Annotations")
            }
        }
    }
    
    // MARK: - Selection Handling -

    /// Set this delegate in order to be called back if a tap occurs on an annotation being managed by this manager.
    public weak var delegate: PointAnnotationInteractionDelegate? {
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

    internal func handleAnnotationSelection(annotationIds: [String]) -> [PointAnnotation] {
        
        var updates: [(index: Int, annotation: PointAnnotation)] = []
        
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

    // MARK: - Image Convenience -
    
    func addImageToStyleIfNeeded() {
        guard let style = style else { return }
        let namedImages = annotations.compactMap(\.image)
        for namedImage in namedImages {
            do {
                let image = style.image(withId: namedImage.name)
                if image == nil {
                    try style.addImage(namedImage.image, id: namedImage.name)
                } 
            } catch {
                Log.warning(forMessage: "Could not add image to style in PointAnnotationManager", category: "Annnotations")
            }
        }
    }
} 
// End of generated file.
// swiftlint:enable all