import SwiftUI

/// Represents a ``Map``content such as annotations.
@_spi(Experimental)
public protocol MapContent {
    func _visit(_ visitor: _MapContentVisitor)
}

/// A type that collects multiple instances of a ``MapContent`` — into a single unit.

struct CompositeMapContent: MapContent {
    var children: [MapContent] = []

    func _visit(_ visitor: _MapContentVisitor) {
        for (idx, child) in children.enumerated() {
            visitor.push(idx)
            child._visit(visitor)
            visitor.pop()
        }
    }
}

enum ConditionalMapContent: MapContent {
    case first(MapContent)
    case second(MapContent)

    func _visit(_ visitor: _MapContentVisitor) {
        switch self {
        case .first(let mapContent):
            visitor.push(1)
            mapContent._visit(visitor)
        case .second(let mapContent):
            visitor.push(2)
            mapContent._visit(visitor)
        }
    }
}
