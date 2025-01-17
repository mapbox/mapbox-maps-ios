import os.log
/// A protocol used to create any type of  map style content, such as layers, sources, lighting and others.
///
/// The instances of `MapStyleContent` can be used in ``StyleManager/setMapStyleContent(content:)``, or in ``Map``'s content in SwiftUI.
///
/// Implement this protocol to create higher level content components.
///
/// - Note: In `SwiftUI` applications prefer to use ``MapContent`` instead.
public protocol MapStyleContent {
    /// Represents the composite type of the body content.
    associatedtype Body: MapStyleContent

    /// Provides the children style contents.
    @MapStyleContentBuilder
    var body: Body { get }
}

/// Defines an empty map style content.
public struct EmptyMapStyleContent: MapStyleContent, PrimitiveMapContent {
    public init() {}

    func visit(_ node: MapContentNode) {
        node.mount(MountedEmpty())
    }
}

/// A map style content composed of multiple values.
///
/// Use ``MapStyleContentBuilder`` to initialize this type.
public struct TupleMapStyleContent<T>: MapStyleContent, PrimitiveMapContent {
    var _visit: (MapContentNode) -> Void

    init<each Content>(_ content: repeat each Content) where repeat each Content: MapStyleContent, T == (repeat each Content) {
        _visit = TupleMapContent(repeat MapStyleContentAdapter(each content)).visit
    }

    func visit(_ node: MapContentNode) {
        _visit(node)
    }
}

/// Conditional map style content.
///
/// Use ``MapStyleContentBuilder`` to initialize this type.
public struct ConditionalMapStyleContent<F: MapStyleContent, S: MapStyleContent>: MapStyleContent, PrimitiveMapContent {
    private let subject: ConditionalMapContent<MapStyleContentAdapter<F>, MapStyleContentAdapter<S>>

    init(first: F) {
        subject = ConditionalMapContent(first: MapStyleContentAdapter(first))
    }

    init(second: S) {
        subject = ConditionalMapContent(second: MapStyleContentAdapter(second))
    }

    func visit(_ node: MapContentNode) {
        subject.visit(node)
    }
}

/// Optional map style content.
///
/// Use ``MapStyleContentBuilder`` to initialize this type.
public struct OptionalMapStyleContent<T: MapStyleContent>: MapStyleContent, PrimitiveMapContent {
    private let subject: OptionalMapContent<MapStyleContentAdapter<T>>

    init(content: T?) {
        self.subject = OptionalMapContent(content: content.map(MapStyleContentAdapter.init))
    }

    func visit(_ node: MapContentNode) {
        subject.visit(node)
    }
}
