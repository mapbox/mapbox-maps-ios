import os.log

/// A protocol used to create any type of ``Map`` content, such as annotations, location indicator, layers, sources, lights, and more.
///
/// Implement this protocol to create higher level content components. Any type of ``MapStyleContent`` can be used as `MapContent`.
public protocol MapContent {
    /// Represents the composite type of the body content.
    associatedtype Body: MapContent

    /// Provides the child contents.
    @MapContentBuilder
    var body: Body { get }
}

public struct TupleMapContent<T>: MapContent, PrimitiveMapContent {
    var _visit: (MapContentNode) -> Void

    init<each Content>(_ content: repeat each Content)
        where repeat each Content: MapContent, T == (repeat each Content) {
        _visit = { node in
            node.withChildrenNodes { nextNode in
                repeat (each content).update(nextNode())
            }
        }
    }

    func visit(_ node: MapContentNode) {
        _visit(node)
    }
}

public struct ConditionalMapContent<F: MapContent, S: MapContent>: MapContent, PrimitiveMapContent {
    private enum Storage {
        case first(F)
        case second(S)
    }
    private let storage: Storage

    init(first: F) {
        storage = .first(first)
    }

    init(second: S) {
        storage = .second(second)
    }

    func visit(_ node: MapContentNode) {
        node.withChildrenNodes { nextNode in
            switch storage {
            case .first(let first):
                first.update(nextNode())
                EmptyMapContent().update(nextNode())
            case .second(let second):
                EmptyMapContent().update(nextNode())
                second.update(nextNode())
            }
        }
    }
}

public struct EmptyMapContent: MapContent, PrimitiveMapContent {
    public init() {}

    func visit(_ node: MapContentNode) {
        node.mount(MountedEmpty())
    }
}

public struct OptionalMapContent<T: MapContent>: MapContent, PrimitiveMapContent {
    var content: T?
    func visit(_ node: MapContentNode) {
        node.withChildrenNodes { nextNode in
            if let content {
                content.update(nextNode())
            } else {
                EmptyMapContent().update(nextNode())
            }
        }
    }
}

extension MapContent {
    func update(_ node: MapContentNode) {
        if let adapter = self as? AdaptingMapContent {
            adapter.visit(node)
        } else if let primitive = self as? PrimitiveMapContent {
            node.update(with: primitive)
        } else {
            node.update(newContent: self) { nextNode in
                body.update(nextNode)
            }
        }
    }
}
