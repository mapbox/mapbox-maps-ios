/// A result builder that creates map content from closures you provide.
    @_documentation(visibility: public)
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
}

/// A result builder that creates array of homogenous elements.
/// If element is missing, the resulting array leaves nil gaps.
    @_documentation(visibility: public)
@_spi(Experimental)
@resultBuilder public struct ArrayBuilder<T> {
    /// :nodoc:
    public static func buildBlock(_ components: [T?]...) -> [T?] {
        components.flatMap { $0 }
    }

    /// :nodoc:
    public static func buildExpression(_ expression: T) -> [T?] {
        [expression]
    }

    /// :nodoc:
    public static func buildOptional(_ component: [T?]?) -> [T?] {
        component ?? [nil]
    }

    /// :nodoc:
    public static func buildEither(first component: [T?]) -> [T?] {
        component + [nil]
    }

    /// :nodoc:
    public static func buildEither(second component: [T?]) -> [T?] {
        [nil] + component
    }
}
