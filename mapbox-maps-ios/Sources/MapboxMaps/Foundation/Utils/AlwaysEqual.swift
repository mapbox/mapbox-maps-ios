/// Wraps a non-equatable type (a closure) to store it in a type with automatically-generated Equatable conformance.
struct AlwaysEqual<Value>: Equatable {
    var value: Value

    static func == (lhs: AlwaysEqual<Value>, rhs: AlwaysEqual<Value>) -> Bool {
        return true
    }
}
