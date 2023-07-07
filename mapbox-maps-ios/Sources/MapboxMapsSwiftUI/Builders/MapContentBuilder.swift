/// A result builder that creates map content from closures you provide.
@_spi(Experimental)
@resultBuilder public struct MapContentBuilder {

    public static func buildBlock(_ content: MapContent...) -> MapContent {
        CompositeMapContent(children: content)
    }

    public static func buildOptional(_ content: MapContent?) -> MapContent {
        content ?? CompositeMapContent()
    }

    public static func buildEither(first component: MapContent) -> MapContent {
        ConditionalMapContent.first(component)
    }

    public static func buildEither(second component: MapContent) -> MapContent {
        ConditionalMapContent.second(component)
    }

    public static func buildLimitedAvailability(_ component: MapContent) -> MapContent {
        component
    }
}
