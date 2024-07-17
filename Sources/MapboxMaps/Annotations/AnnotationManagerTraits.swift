protocol AnnotationManagerTraits {
    associatedtype AnnotationType: Annotation & AnnotationInternal & Equatable
    associatedtype LayerType: Layer
    associatedtype OffsetCalculator: OffsetGeometryCalculator where OffsetCalculator.GeometryType == AnnotationType.GeometryType

    typealias UpdateOffset = (inout AnnotationType, CGPoint) -> Bool

    static func makeLayer(id: String) -> LayerType
    static var tag: String { get }
}

struct PointAnnotationManagerTraits: AnnotationManagerTraits {
    typealias OffsetCalculator = OffsetPointCalculator
    typealias AnnotationType = PointAnnotation
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

    static let tag = "PointAnnotationManager"
}

struct CircleAnnotationManagerTraits: AnnotationManagerTraits {
    typealias OffsetCalculator = OffsetPointCalculator
    typealias AnnotationType = CircleAnnotation
    typealias LayerType = CircleLayer

    static func makeLayer(id: String) -> CircleLayer {
        CircleLayer(id: id, source: id)
    }

    static let tag = "CircleAnnotationManager"
}

struct PolygonAnnotationManagerTraits: AnnotationManagerTraits {
    typealias OffsetCalculator = OffsetPolygonCalculator
    typealias AnnotationType = PolygonAnnotation
    typealias LayerType = FillLayer

    static func makeLayer(id: String) -> FillLayer {
        FillLayer(id: id, source: id)
    }

    static let tag = "PolygonAnnotationManager"
}

struct PolylineAnnotationManagerTraits: AnnotationManagerTraits {
    typealias OffsetCalculator = OffsetLineStringCalculator
    typealias AnnotationType = PolylineAnnotation
    typealias LayerType = LineLayer

    static func makeLayer(id: String) -> LineLayer {
        LineLayer(id: id, source: id)
    }

    static let tag = "PolylineAnnotationManager"
}
