/// A result builder that creates map style content from closures you provide.
@_spi(Experimental)
/// :nodoc:
@resultBuilder public struct MapStyleContentBuilder {
    /// :nodoc:
    public static func buildBlock(_ content: MapStyleContent...) -> MapStyleContent {
        CompositeStyleContent(content.map { $0.visit })
    }

    /// :nodoc:
    public static func buildEither(first content: MapStyleContent) -> MapStyleContent {
        ConditionalMapStyleContent.first(content)
    }

    /// :nodoc:
    public static func buildEither(second content: MapStyleContent) -> MapStyleContent {
        ConditionalMapStyleContent.second(content)
    }
}
