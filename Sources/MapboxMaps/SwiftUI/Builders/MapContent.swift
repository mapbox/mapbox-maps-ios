import SwiftUI

/// Represents a ``Map-swift.struct``content such as annotations.
///
/// See implementations for more details.
    @_documentation(visibility: public)
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
        for (idx, content) in children.enumerated() {
            visitor.visit(id: idx, content: content)
        }
    }
}

enum ConditionalMapContent: PrimitiveMapContent {
    case first(MapContent)
    case second(MapContent)

    func _visit(_ visitor: MapContentVisitor) {
        switch self {
        case .first(let content):
            visitor.visit(id: 1, content: content)
        case .second(let content):
            visitor.visit(id: 2, content: content)
        }
    }
}
