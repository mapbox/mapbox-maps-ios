import Foundation
import UIKit
import MapboxCoreMaps
import MapboxCommon
import Turf
import CoreLocation

#if canImport(MapboxMaps)
#else
import MapboxMapsStyle
import MapboxMapsFoundation
#endif

//swiftlint:disable file_length type_body_length
/**
 Manages the addition, update, and the deletion of annotations to a map.

 All annotations added with this class belong to a single source and style layer.
 */
public class AnnotationManager {

    // MARK: - Public properties

    /**
     A dictionary of key/value pairs being managed by the
    `AnnotationManager`, where the key represents the unique identifier
     of the annotation and the value refers to the `Annotation` itself.

     - Note: This property is get-only, so it cannot be used to add or
             remove annotations. Instead, use the `addAnnotation` or `removeAnnotation`
             related methods update annotations belonging to the map view.
     */
    public private(set) var annotations: [String: Annotation]

    /**
     The delegate to notify of changes in annotations.
     */
    public weak var interactionDelegate: AnnotationInteractionDelegate?

    /**
     An array of annotations that have currently been selected by the annotation manager.
     */
    public var selectedAnnotations: [Annotation] {
        return annotations.values.filter { ( annotation ) -> Bool in
            return annotation.isSelected
        }
    }

    /**
     A `Bool` value that indicates whether users can interact with the annotations
     managed by the annotation manager. The default value is `true`. Setting this property
     to `false` will deinitialize the annotation manager's tap gesture recognizer.
     */
    public var userInteractionEnabled: Bool {
        didSet {
            if !userInteractionEnabled {
                tapGesture = nil
            } else if userInteractionEnabled && tapGesture == nil {
                configureTapGesture()
            }
        }
    }

    // MARK: - Internal properties

    /**
     The `FeatureCollection` that contains all annotations.
     */
    internal var annotationFeatures: FeatureCollection

    /**
     The `AnnotationStyleDelegate` that will be used to handle the addition
     of annotation sources and style layers.
     */
    // swiftlint:disable weak_delegate
    internal var styleDelegate: AnnotationStyleDelegate

    /**
     The map object this class will use when querying for annotations.
     */
    internal weak var mapView: AnnotationSupportableMap?

    /**
     The source layer used by the annotation manager.
     */
    internal var annotationSource: GeoJSONSource?

    /**
     Options used by the annotation manager.
     */
    internal var annotationOptions: AnnotationOptions

    /**
     The default source identifier, which will be used by the `AnnotationManager` by default.
     */
    internal let defaultSourceId = "com.mapbox.AnnotationManager.DefaultSource"

    /**
     The source identifier used by the `AnnotationManager`.
     */
    internal var sourceId: String {
        return annotationOptions.sourceId ?? defaultSourceId
    }

    /**
     The default style layer identifiers to be used by the point, line, and polygon
     style layers managed by this class.
     */
    internal let defaultSymbolLayerId = "com.mapbox.AnnotationManager.DefaultSymbolStyleLayer"
    internal let defaultLineLayerId = "com.mapbox.AnnotationManager.DefaultLineStyleLayer"
    internal let defaultPolygonLayerId = "com.mapbox.AnnotationManager.DefaultPolygonStyleLayer"

    /**
     The default style layers used to render point, line, and polygon
     annotations on the map view.
     */
    internal var symbolLayer: SymbolLayer?
    internal var lineLayer: LineLayer?
    internal var fillLayer: FillLayer?

    /**
     The tap gesture recognizer used to respond to tap events.
     Used to process annotation selection.
     */
    internal var tapGesture: UITapGestureRecognizer?

    // MARK: - Initialization

    deinit {
        self.tapGesture = nil
    }

    /**
     Creates a new `AnnotationManager` object. To manages the addition, update,
     and deletion of annotations (or "markers") to a map.

     - Parameter mapView: A conformer to AnnotationSupportableMap
     - Parameter styleDelegate: Delegate responsible for applying the style to a map
     - Parameter interactionDelegate: Delegate responsible for handling annotation interaction events
     */
    internal init(for mapView: AnnotationSupportableMap,
                  with styleDelegate: AnnotationStyleDelegate,
                  options: AnnotationOptions,
                  interactionDelegate: AnnotationInteractionDelegate? = nil) {

        self.mapView = mapView
        self.styleDelegate = styleDelegate
        self.interactionDelegate = interactionDelegate
        self.annotationOptions = options
        annotations = [:]
        annotationFeatures = FeatureCollection(features: [])
        userInteractionEnabled = true

        configureTapGesture()
        mapView.on(.mapLoaded) { [weak self] _ in
            // Reset the annotation source and default layers.
            guard let self = self else { return }
            self.annotations = [:]
            self.annotationSource = nil
            self.symbolLayer = nil
            self.lineLayer = nil
            self.fillLayer = nil
        }
    }

    internal func updateAnnotationOptions(with newOptions: AnnotationOptions) {
        self.annotationOptions = newOptions
        Log.warning(forMessage: "Updating annotation manager is not supported at this time.", category: "Annotations")
    }

    // MARK: - Public functions

    /**
     Adds a given annotation to the `MapView`.

     If the given annotation has already been added to the `MapView`, this returns an error.

     - Parameter annotation: Annotation to add to the `MapView`.
     - Returns: If operation successful, returns a `true` as part of the `Result` success case.
                Else, returns a `AnnotationError` in the `Result` failure case.
     */
    @discardableResult public func addAnnotation(_ annotation: Annotation) -> Result<Bool, AnnotationError> {

        if annotations[annotation.identifier] != nil {
            return .failure(.annotationAlreadyExists("Annotation has already been added."))
        }

        // Add to annotations dictionary, and create a `Feature` for it.
        annotations[annotation.identifier] = annotation

        // Create geoJSON source data from feature collection
        do {
            try updateFeatureCollection(for: annotation)
            try updateLayers(for: annotation)
        } catch let error {
            return .failure(AnnotationError.addAnnotationFailed(error))
        }

        return .success(true)
    }

    /**
     Adds a given array of annotations to the `MapView`.

     The method is equivalent to calling `addAnnotation(_ annotation:)` method for each annotation within the group.

     - Parameter annotations: Annotations to add to the `MapView`.
     */
    @discardableResult public func addAnnotations(_ annotations: [Annotation]) -> Result<Bool, AnnotationError> {
        for annotation in annotations {
            switch addAnnotation(annotation) {
            case .success:
                break
            case .failure(let annotationError):
                return .failure(annotationError)
            }
        }

        return .success(true)
    }

    /**
     Updates the annotation registered with the annotation manager.

     - Parameter annotation: The annotation that should be updated.
     - Throws: `AnnotationError.annotationDoesNotExist` if the annotation
                hasn't been added, otherwise throws `AnnotationError.updateAnnotationFailed`.
     */
    public func updateAnnotation(_ annotation: Annotation) throws {

        guard let existingAnnotation = annotations[annotation.identifier] else {
            throw AnnotationError.annotationDoesNotExist(nil)
        }

        do {
            annotations[existingAnnotation.identifier] = annotation
            try updateFeatureCollection(for: annotation)
            try updateLayers(for: annotation)
        } catch let error {
            throw AnnotationError.updateAnnotationFailed(error)
        }
    }

    /**
     Removes a given annotation from the `MapView`.

     If the given annotation has already been removed from the `MapView`, this returns an error.

     - Parameter annotation: Annotation to remove from the `MapView`.
     - Returns: If operation successful, returns a `true` as part of the `Result` success case.
                Else, returns a `AnnotationError` in the `Result` failure case.
     */
    @discardableResult public func removeAnnotation(_ annotation: Annotation) -> Result<Bool, AnnotationError> {

        guard annotations[annotation.identifier] != nil else {
            return .failure(.removeAnnotationFailed("Annotation has already been removed"))
        }

        annotations[annotation.identifier] = nil

        annotationFeatures.features.removeAll { (feature) -> Bool in
            guard let featureIdentifier = feature.identifier?.value as? String else { return false }
            return featureIdentifier == annotation.identifier ? true : false
        }

        // Create geoJSON source data from feature collection
        guard let geoJSONDictionary = try? GeoJSONManager.dictionaryFrom(annotationFeatures) else {
            return .failure(.removeAnnotationFailed("Failed to parse data from FeatureCollection"))
        }

        do {
            try styleDelegate.setSourceProperty(for: sourceId, property: "data", value: geoJSONDictionary)
            return .success(true)
        } catch {
            return .failure(.removeAnnotationFailed(error.localizedDescription))
        }
    }

    /**
     Removes a given array of annotations from the `MapView`.

     The method is equivalent to calling `removeAnnotation(_ annotation:)` method for each annotation within the group.

     - Parameter annotations: Annotations to remove from the `MapView`.
     */
    @discardableResult public func removeAnnotations(_ annotations: [Annotation]) -> Result<Bool, AnnotationError> {
        for annotation in annotations {
            switch removeAnnotation(annotation) {
            case .success:
                break
            case .failure(let annotationError):
                return .failure(annotationError)
            }
        }

        return .success(true)
    }

    /**
     Toggles the annotation's selection state.
     If the annotation is deselected, it becomes selected.
     If the annotation is selected, it becomes deselected.
     - Parameter Annotations: The annotation to select.
     */
    public func selectAnnotation(_ annotation: Annotation) {
        if var annotation = annotations[annotation.identifier] {
            annotation.isSelected.toggle()
            annotations[annotation.identifier] = annotation

            switch annotation.isSelected {
            case true:
                interactionDelegate?.didSelectAnnotation(annotation: annotation)
            case false:
                interactionDelegate?.didDeselectAnnotation(annotation: annotation)
            }
        }
    }

    /**
     Returns the underlying layer identifier for the associated annotation type.
     - Parameter annotationType: Type of annotation, for example, PointAnnotation.self
     - Returns: Identifier (or nil, if there isn't a layer for that type)
     */
    public func layerId<T: Annotation>(for annotationType: T.Type) -> String? {
        switch annotationType {
        case is PointAnnotation.Type:
            return symbolLayer?.id

        case is LineAnnotation.Type:
            return lineLayer?.id

        case is PolygonAnnotation.Type:
            return fillLayer?.id

        default:
            Log.error(forMessage: "Type should be an annotation", category: "Annotations")
            return nil
        }
    }

    // MARK: - Internal functions

    /**
     Adds a new source layer for all annotations.
     */
    internal func createAnnotationSource() throws {

        annotationSource = GeoJSONSource()

        guard var source = annotationSource else {
            throw AnnotationError.addAnnotationFailed(nil)
        }

        source.data = .featureCollection(annotationFeatures)

        try styleDelegate.addSource(source, id: sourceId)
    }

    /**
     Creates a turf `Feature` based off an `Annotation`.
     */
    internal func makeFeature(for annotation: Annotation) throws -> Feature {

        var feature: Feature

        switch annotation {
        case let point as PointAnnotation:
            feature = Feature(Point(point.coordinate))

            if point.image != nil {
                feature.properties = ["icon-image": point.identifier]
            } else {
                feature.properties = ["icon-image": PointAnnotation.defaultIconImageIdentifier]
            }
        case let line as LineAnnotation:
            feature = Feature(LineString(line.coordinates))
        case let polygon as PolygonAnnotation:
            var turfPolygon: Polygon

            if let holes = polygon.interiorPolygons {
                let outerRing = Ring(coordinates: polygon.coordinates)
                let innerRings = holes.map({ Ring(coordinates: $0) })
                turfPolygon = Polygon(outerRing: outerRing, innerRings: innerRings)
            } else {
                let outerRing = Ring(coordinates: polygon.coordinates)
                turfPolygon = Polygon(outerRing: outerRing)
            }

            feature = Feature(turfPolygon)
        default:
            throw AnnotationError.featureGenerationFailed("Could not generate Feature from annotation")
        }

        feature.identifier = FeatureIdentifier.string(annotation.identifier)

        return feature
    }

    /**
     Updates the internal `FeatureCollection` with the given `Annotation`.
     If the annotation already exists in the `FeatureCollection`, it is updated at
     its given index. If it does not exist yet within the `FeatureCollection`, it
     is appended to the `FeatureCollection`.
     */
    internal func updateFeatureCollection(for annotation: Annotation) throws {

        let existingAnnotationIndex = annotationFeatures.features.firstIndex(where: { (feature) -> Bool in
            guard let featureIdentifier = feature.identifier?.value as? String else { return false }
            return featureIdentifier == annotation.identifier
        })

        let feature = try makeFeature(for: annotation)

        if let index = existingAnnotationIndex {
            annotationFeatures.features[index] = feature
        } else {
            annotationFeatures.features.append(feature)
        }
    }

    /**
     Updates the source and style layers if needed.
     */
    internal func updateLayers(for annotation: Annotation) throws {
        let geoJSONDictionary = try GeoJSONManager.dictionaryFrom(annotationFeatures)
        try updateSource(geoJSONDictionary: geoJSONDictionary)
        try updateStyleLayer(for: annotation)
    }

    /**
     Creates or updates the data source layer for the annotations.
     */
    internal func updateSource(geoJSONDictionary: [String: Any]?) throws {
        guard let geoJSON = geoJSONDictionary else {
            throw AnnotationError.addAnnotationFailed(nil)
        }

        if annotationSource == nil {
            try createAnnotationSource()
        } else {
            try styleDelegate.setSourceProperty(for: sourceId, property: "data", value: geoJSON)
        }
    }

    /**
     Creates a style layer for a given annotation type,
     if the annotation type hasn't been added yet.
     */
    internal func updateStyleLayer(for annotation: Annotation) throws {
        switch annotation {
        case let pointAnnotation as PointAnnotation:
            try updateSymbolStyleLayer(for: pointAnnotation)
        case _ as LineAnnotation:
            try updateLineStyleLayer()
        case _ as PolygonAnnotation:
            try updateFillStyleLayer()
        default:
            throw AnnotationError.styleLayerGenerationFailed(nil)
        }
    }

    internal func updateSymbolStyleLayer(for pointAnnotation: PointAnnotation) throws {

        // If the point annotation has a custom image, add it to the sprite.
        if let customImage = pointAnnotation.image {
            try styleDelegate.addImage(customImage,
                                       id: pointAnnotation.identifier,
                                       sdf: false,
                                       stretchX: [],
                                       stretchY: [],
                                       content: nil)
        }

        // Add the default symbol layer image.
        guard symbolLayer == nil else {
            return
        }

        // Add the default icon image to the sprite, but only once.
        if styleDelegate.image(withId: PointAnnotation.defaultIconImageIdentifier) == nil {

            try styleDelegate.addImage(pointAnnotation.defaultAnnotationImage(),
                                       id: PointAnnotation.defaultIconImageIdentifier,
                                       sdf: false,
                                       stretchX: [],
                                       stretchY: [],
                                       content: nil)
        }

        // Make the style layer for the first time.
        var symbolLayer = SymbolLayer(id: defaultSymbolLayerId)
        symbolLayer.source = sourceId

        /**
         Create an expression that will use the `icon-image`
         property associated with an annotation's `Feature`
         to set the image.
         */
        symbolLayer.layout?.iconImage = .expression(Exp(.get) {
            "icon-image"
        })

        /**
         Since all annotation geometries share the same source,
         render only the point geometries within the symbol layer.
         */
        symbolLayer.filter = Exp(.eq) {
            "$type"
            "Point"
        }

        try styleDelegate.addLayer(symbolLayer, layerPosition: annotationOptions.layerPosition)

        self.symbolLayer = symbolLayer
    }

    internal func updateLineStyleLayer() throws {
        guard lineLayer == nil else {
            return
        }

        var lineLayer = LineLayer(id: defaultLineLayerId)
        lineLayer.source = sourceId

        /**
         Since all annotation geometries share the same source,
         render only the line geometries within the line layer.
         */
        lineLayer.filter = Exp(.eq) {
            "$type"
            "LineString"
        }

        try styleDelegate.addLayer(lineLayer, layerPosition: annotationOptions.layerPosition)
        self.lineLayer = lineLayer
    }

    internal func updateFillStyleLayer() throws {
        guard fillLayer == nil else {
            return
        }

        var fillLayer = FillLayer(id: defaultPolygonLayerId)
        fillLayer.source = sourceId
        /**
         Since all annotation geometries share the same source,
         render only the polygon geometries within the fill layer.
         */
        fillLayer.filter = Exp(.eq) {
            "$type"
            "Polygon"
        }

        try styleDelegate.addLayer(fillLayer, layerPosition: annotationOptions.layerPosition)
        self.fillLayer = fillLayer
    }

    // MARK: - Annotation selection

    internal func configureTapGesture() {
        guard let mapView = mapView else {
            assertionFailure("MapView is nil")
            return
        }

        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))

        if let tapGesture = self.tapGesture {
            mapView.addGestureRecognizer(tapGesture)
        }
    }

    @objc internal func handleTap(sender: UITapGestureRecognizer) {
        guard let mapView = mapView else {
            assertionFailure("MapView is nil")
            return
        }

        let point = sender.location(in: mapView)

        /**
         Using 44 x 44 points, the recommended touch target size from
         Apple Human Interface Guidelines.
         */
        let hitRect = CGRect(x: point.x - 22,
                             y: point.y - 22,
                             width: 44,
                             height: 44)

        let annotationLayers: Set<String> = [defaultSymbolLayerId, defaultLineLayerId, defaultPolygonLayerId]
        mapView.visibleFeatures(in: hitRect,
                                styleLayers: annotationLayers,
                                filter: nil,
                                completion: { [weak self] result in
                                    guard let validSelf = self else { return }

                                    if case .success(let features) = result {
                                        if features.count == 0 { return }

                                        guard let featureIdentifier = features[0].feature.identifier as? String else { return }

                                        /**
                                         If the found feature identifier exists in the internal
                                         annotations dictionary, then we know we've found an annotation
                                         and can notify the delegate.
                                         */
                                        if let annotation = validSelf.annotations[featureIdentifier] {
                                            validSelf.selectAnnotation(annotation)
                                        }
                                    }
                                })
    }
    // MARK: - Errors

    // Annotation-related errors
    public enum AnnotationError: Error {
        // The Turf `Feature` could not be generated for the given annotation.
        case featureGenerationFailed(String?)
        // The annotation being added already exists.
        case annotationAlreadyExists(String?)
        // The annotation does not exist
        case annotationDoesNotExist(String?)
        // Generating the style layer for the annotation failed.
        case styleLayerGenerationFailed(Error?)
        // Adding the annotation failed.
        case addAnnotationFailed(Error?)
        // The annotation being removed does not exist.
        case annotationAlreadyRemoved(String?)
        // Removing the annotation failed.
        case removeAnnotationFailed(String?)
        // Updating the annotation failed.
        case updateAnnotationFailed(Error?)
    }
}
