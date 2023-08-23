import SwiftUI

/// Represents a ``Map-swift.struct``content such as annotations.
///
/// See implementations for more details.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
@_spi(Experimental)
public protocol MapContent {}

protocol PrimitiveMapContent: MapContent {
    func _visit(_ visitor: MapContentVisitor)
}

extension MapContent {
    func visit(_ visitor: MapContentVisitor) {
        (self as? PrimitiveMapContent)?._visit(visitor)
    }
}

/// A type that collects multiple instances of a ``MapContent`` — into a single unit.
struct CompositeMapContent: PrimitiveMapContent {
    var children: [MapContent] = []

    func _visit(_ visitor: MapContentVisitor) {
        for (idx, child) in children.enumerated() {
            visitor.push(idx)
            child.visit(visitor)
            visitor.pop()
        }
    }
}

enum ConditionalMapContent: PrimitiveMapContent {
    case first(MapContent)
    case second(MapContent)

    func _visit(_ visitor: MapContentVisitor) {
        switch self {
        case .first(let mapContent):
            visitor.push(1)
            mapContent.visit(visitor)
        case .second(let mapContent):
            visitor.push(2)
            mapContent.visit(visitor)
        }
    }
}
