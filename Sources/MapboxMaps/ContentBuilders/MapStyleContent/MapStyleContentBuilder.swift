/// A result builder that creates map style content from closures you provide.
///
/// See more information in the <doc:Declarative-Map-Styling>.
@resultBuilder
public struct MapStyleContentBuilder {
    /// Builds an expression within the map style content builder.
    public static func buildExpression<Content>(_ content: Content) -> Content where Content: MapStyleContent {
        content
    }

    /// Builds a block within the map style content builder.
    public static func buildBlock<Content>(_ content: Content) -> Content where Content: MapStyleContent {
        content
    }

    /// Builds an empty map style content.
    public static func buildBlock() -> EmptyMapStyleContent { EmptyMapStyleContent() }

    /// Build a block composed of multiple elements within the map style content builder.
    public static func buildBlock<each Content>(_ content: repeat each Content) -> TupleMapStyleContent<(repeat each Content)> where repeat each Content: MapStyleContent {
        TupleMapStyleContent(repeat each content)
    }

    /// Builds conditional content within the map style content builder.
    public static func buildEither<First, Second>(first content: First) -> ConditionalMapStyleContent<First, Second> where First: MapStyleContent, Second: MapStyleContent {
        ConditionalMapStyleContent<First, Second>(first: content)
    }

    /// Builds conditional content within the map style content builder.
    public static func buildEither<First, Second>(second content: Second) -> ConditionalMapStyleContent<First, Second> where First: MapStyleContent, Second: MapStyleContent {
        ConditionalMapStyleContent<First, Second>(second: content)
    }

    /// Builds optional content within the map style content builder.
    public static func buildOptional<T: MapStyleContent>(_ component: T?) -> OptionalMapStyleContent<T> {
        OptionalMapStyleContent(content: component)
    }
}
