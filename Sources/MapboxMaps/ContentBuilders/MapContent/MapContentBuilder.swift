/// A result builder that creates map and style content from closures you provide.
/// Allows to mix content which is used in  StyleDSL API <doc:Declarative-Map-Styling> and in SwiftUI API <doc:SwiftUI-User-Guide>
@resultBuilder
public struct MapContentBuilder {
    /// Builds an expression within the map content builder.
    public static func buildExpression<Content>(_ content: Content) -> Content where Content: MapContent {
        content
    }

    /// Builds an expression within the map style content builder.
    public static func buildExpression<Content>(_ content: Content) -> some MapContent where Content: MapStyleContent {
        MapStyleContentAdapter(content)
    }

    /// Builds an empty map content.
    public static func buildBlock() -> EmptyMapContent { EmptyMapContent() }

    /// Build a block composed of multiple elements within the map content builder.
    public static func buildBlock<each Content>(_ content: repeat each Content) -> TupleMapContent<(repeat each Content)> where repeat each Content: MapContent {
        TupleMapContent(repeat each content)
    }

    /// Builds conditional content within the map content builder.
    public static func buildEither<First, Second>(first content: First) -> ConditionalMapContent<First, Second> where First: MapContent, Second: MapContent {
        ConditionalMapContent<First, Second>(first: content)
    }

    /// Builds conditional content within the map content builder.
    public static func buildEither<First, Second>(second content: Second) -> ConditionalMapContent<First, Second> where First: MapContent, Second: MapContent {
        ConditionalMapContent<First, Second>(second: content)
    }

    /// Builds optional content within the map content builder.
    public static func buildOptional<T: MapContent>(_ component: T?) -> OptionalMapContent<T> {
        OptionalMapContent(content: component)
    }
}
