import SwiftUI

/// Represents MapStyleContent such as Sources and Layers.
///
/// See implementations for more details.
@_spi(Experimental)
/// :nodoc:
public protocol MapStyleContent {}

protocol PrimitiveMapStyleContent: MapStyleContent {
    func _visit(_ visitor: MapStyleContentVisitor)
}

protocol LayerMapStyleContent: PrimitiveMapStyleContent {
    func _visit(_ visitor: MapStyleContentVisitor, layerPosition: LayerPosition?)
}

extension MapStyleContent {
    func visit(_ visitor: MapStyleContentVisitor) {
        (self as? PrimitiveMapStyleContent)?._visit(visitor)
    }
}

/// A type that collects multiple instances of a ``MapStyleContent`` — into a single unit.
struct CompositeStyleContent: PrimitiveMapStyleContent {
    var children: [(MapStyleContentVisitor) -> Void]

    init(_ children: [(MapStyleContentVisitor) -> Void]) {
        self.children = children
    }

    func _visit(_ visitor: MapStyleContentVisitor) {
        children.forEach {
            $0(visitor)
        }
    }
}

struct EmptyMapStyleContent: MapStyleContent {}

enum ConditionalMapStyleContent: PrimitiveMapStyleContent {
    case first(MapStyleContent)
    case second(MapStyleContent)

    func _visit(_ visitor: MapStyleContentVisitor) {
        switch self {
        case .first(let content):
            content.visit(visitor)
        case .second(let content):
            content.visit(visitor)
        }
    }
}
