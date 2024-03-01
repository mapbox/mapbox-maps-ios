import os

/// Represents a piece of style content that can be used in the style builder.
@_spi(Experimental)
@available(iOS 13.0, *)
@_documentation(visibility: public)
public protocol MapStyleContent {
    /// Represents the composite type of the body content.
    associatedtype Body: MapStyleContent

    /// Provides the children style contents.
    @MapStyleContentBuilder
    var body: Body { get }
}

@available(iOS 13.0, *)
protocol PrimitiveMapStyleContent: MapStyleContent where Body == Never {
    func visit(_ node: MapStyleNode)
}

@_spi(Experimental)
extension Never: MapStyleContent {
    public var body: Never {
        fatalError("shouldn't be called")
    }
}

@available(iOS 13.0, *)
extension PrimitiveMapStyleContent {
    /// :nodoc:
    public var body: Never {
        fatalError("shouldn't be called")
    }
}

/// Defines an empty map style content.
@_spi(Experimental)
@available(iOS 13.0, *)
@_documentation(visibility: public)
public struct EmptyMapStyleContent: MapStyleContent, PrimitiveMapStyleContent {
    public init() {}

    func visit(_ node: MapStyleNode) {
        node.mount(MountedEmpty())
    }
}

/// A map style content composed of multiple values.
///
/// Use ``MapStyleContentBuilder`` to initialize this type.
@available(iOS 13.0, *)
@_spi(Experimental)
@_documentation(visibility: public)
public struct TupleMapStyleContent<T>: MapStyleContent, PrimitiveMapStyleContent {
    var _visit: (MapStyleNode) -> Void
    func visit(_ node: MapStyleNode) {
        _visit(node)
    }

    init<each Content>(_ content: repeat each Content)
        where repeat each Content: MapStyleContent, T == (repeat each Content) {
        _visit = { node in
            node.withChildrenNodes { nextNode in
                repeat (each content).visit(nextNode: nextNode)
            }
        }
    }
}

@available(iOS 13.0, *)
private extension MapStyleContent {
    func visit(nextNode: () -> MapStyleNode) {
        nextNode().update(with: self)
    }
}

/// Conditional map style content.
///
/// Use ``MapStyleContentBuilder`` to initialize this type.
@_spi(Experimental)
@available(iOS 13.0, *)
@_documentation(visibility: public)
public struct ConditionalMapStyleContent<F: MapStyleContent, S: MapStyleContent>: MapStyleContent, PrimitiveMapStyleContent {
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

    func visit(_ node: MapStyleNode) {
        node.withChildrenNodes { nextNode in
            switch storage {
            case .first(let first):
                nextNode().update(with: first)
                nextNode().update(with: EmptyMapStyleContent())
            case .second(let second):
                nextNode().update(with: EmptyMapStyleContent())
                nextNode().update(with: second)
            }
        }
    }
}

/// Optional map style content.
///
/// Use ``MapStyleContentBuilder`` to initialize this type.
@_spi(Experimental)
@available(iOS 13.0, *)
@_documentation(visibility: public)
public struct OptionalMapStyleContent<T: MapStyleContent>: MapStyleContent, PrimitiveMapStyleContent {
    var content: T?
    func visit(_ node: MapStyleNode) {
        node.withChildrenNodes { nextNode in
            if let content {
                nextNode().update(with: content)
            } else {
                nextNode().update(with: EmptyMapStyleContent())
            }
        }
    }
}

@available(iOS 13.0, *)
func evaluate(mapStyleContent: () -> some MapStyleContent) -> any MapStyleContent {
    OSLog.platform.withIntervalSignpost("MapStyleContent.eval") {
        mapStyleContent()
    }
}
