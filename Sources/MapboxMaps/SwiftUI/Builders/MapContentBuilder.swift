/// A result builder that creates map content from closures you provide.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
@_spi(Experimental)
@resultBuilder public struct MapContentBuilder {

    /// :nodoc:
    public static func buildBlock(_ content: MapContent...) -> MapContent {
        CompositeMapContent(children: content)
    }

    /// :nodoc:
    public static func buildOptional(_ content: MapContent?) -> MapContent {
        content ?? CompositeMapContent()
    }

    /// :nodoc:
    public static func buildEither(first component: MapContent) -> MapContent {
        ConditionalMapContent.first(component)
    }

    /// :nodoc:
    public static func buildEither(second component: MapContent) -> MapContent {
        ConditionalMapContent.second(component)
    }

    /// :nodoc:
    public static func buildLimitedAvailability(_ component: MapContent) -> MapContent {
        component
    }
}
