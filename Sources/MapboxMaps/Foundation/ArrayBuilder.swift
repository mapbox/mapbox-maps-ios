/// A result builder that creates array of homogenous elements.
/// If element is missing, the resulting array leaves nil gaps.
@resultBuilder public struct ArrayBuilder<T> {
    /// :nodoc:
    public static func buildExpression(_ expression: T) -> [T] { [expression] }

    /// :nodoc:
    public static func buildOptional(_ component: [T]?) -> [T] { component ?? [] }

    /// :nodoc:
    public static func buildPartialBlock(first: T) -> [T] { [first] }

    /// :nodoc:
    public static func buildPartialBlock(first: [T]) -> [T] { first }

    /// :nodoc:
    public static func buildPartialBlock(accumulated: [T], next: T) -> [T] { accumulated + [next] }

    /// :nodoc:
    public static func buildPartialBlock(accumulated: [T], next: [T]) -> [T] { accumulated + next }

    /// :nodoc:
    public static func buildBlock() -> [T] { [] }

    /// :nodoc:
    public static func buildEither(first: [T]) -> [T] { first }

    /// :nodoc:
    public static func buildEither(second: [T]) -> [T] { second }

    /// :nodoc:
    public static func buildIf(_ element: [T]?) -> [T] { element ?? [] }

    /// :nodoc:
    public static func buildPartialBlock(first: Never) -> [T] {}
}
