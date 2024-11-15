/// A top-level interface for annotations.
public protocol Annotation {

    /// The unique identifier of the annotation.
    var id: String { get }

    /// The geometry that is backing this annotation.
    var geometry: Geometry { get }

    /// Properties associated with the annotation.
    @available(*, deprecated, message: "Will be deleted in future, for Mapbox-provided annotations see customData instead.")
    var userInfo: [String: Any]? { get set }
}

protocol AnnotationInternal {
    associatedtype LayerType: Layer
    associatedtype GeometryType: GeometryConvertible & OffsetGeometryCalculator

    var id: String { get set }
    var layerProperties: [String: Any] { get }
    var feature: Feature { get }
    var isSelected: Bool { get set }
    var isDraggable: Bool { get set }

    var tapHandler: ((InteractionContext) -> Bool)? { get set }
    var longPressHandler: ((InteractionContext) -> Bool)? { get set }

    var dragBeginHandler: ((inout Self, InteractionContext) -> Bool)? { get set }
    var dragChangeHandler: ((inout Self, InteractionContext) -> Void)? { get set }
    var dragEndHandler: ((inout Self, InteractionContext) -> Void)? { get set }

    mutating func drag(translation: CGPoint, in map: MapboxMapProtocol)

    static func makeLayer(id: String) -> LayerType
}

extension AnnotationInternal {
    var handlesTap: Bool { tapHandler != nil }
    var handlesLongPress: Bool { longPressHandler != nil }
}

extension PointAnnotation {
    typealias GeometryType = Point
    typealias LayerType = SymbolLayer

    static func makeLayer(id: String) -> SymbolLayer {
        var layer = SymbolLayer(id: id, source: id)
        // Show all icons and texts by default in point annotations.
        layer.iconAllowOverlap = .constant(true)
        layer.textAllowOverlap = .constant(true)
        layer.iconIgnorePlacement = .constant(true)
        layer.textIgnorePlacement = .constant(true)
        return layer
    }
}

extension CircleAnnotation {
    typealias GeometryType = Point
    typealias LayerType = CircleLayer

    static func makeLayer(id: String) -> CircleLayer {
        CircleLayer(id: id, source: id)
    }
}

extension PolygonAnnotation {
    typealias GeometryType = Polygon
    typealias LayerType = FillLayer

    static func makeLayer(id: String) -> FillLayer {
        FillLayer(id: id, source: id)
    }
}

extension PolylineAnnotation {
    typealias GeometryType = LineString
    typealias LayerType = LineLayer

    static func makeLayer(id: String) -> LineLayer {
        LineLayer(id: id, source: id)
    }
}

extension Array where Element: Annotation {
    /// Deduplicates annotations.
    mutating func removeDuplicates() {
        let duplicates = self.removeDuplicates(by: \.id)
        if !duplicates.isEmpty {
            let ids = duplicates.lazy.map(\.id).joined(separator: ", ")
            Log.error("Duplicated annotations: \(ids)", category: "Annotations")
        }
    }
}

extension StyleProtocol {
    func apply<T: Annotation>(annotationsDiff diff: CollectionDiff<[T]>, sourceId: String, feature: (T) -> Feature) {
        if !diff.remove.isEmpty {
            removeGeoJSONSourceFeatures(forSourceId: sourceId, featureIds: diff.remove.map(\.id), dataId: nil)
        }
        if !diff.update.isEmpty {
            updateGeoJSONSourceFeatures(forSourceId: sourceId, features: diff.update.map(feature), dataId: nil)
        }
        if !diff.add.isEmpty {
            addGeoJSONSourceFeatures(forSourceId: sourceId, features: diff.add.map(feature), dataId: nil)
        }
    }
}
