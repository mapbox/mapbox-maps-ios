// Check if the two values are Equatable and equal
func isEqual(_ lhs: Any, _ rhs: Any) -> Bool {
    func f<LHS>(lhs: LHS) -> Bool {
        if let typeInfo = Wrapped<LHS>.self as? AnyEquatable.Type {
            return typeInfo.isEqual(lhs: lhs, rhs: rhs)
        }
        return false
    }
    return _openExistential(lhs, do: f)
}

protocol AnyEquatable {
    static func isEqual(lhs: Any, rhs: Any) -> Bool
}

enum Wrapped<T> { }

extension Wrapped: AnyEquatable where T: Equatable {
    static func isEqual(lhs: Any, rhs: Any) -> Bool {
        guard let l = lhs as? T, let r = rhs as? T else {
            return false
        }
        return l == r
    }
}
