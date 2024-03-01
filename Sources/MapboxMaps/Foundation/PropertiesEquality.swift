/// Returns `true` if properties of `lhs` and `rhs` are equal.
func arePropertiesEqual(_ lhs: Any, _ rhs: Any) -> Bool {
    let lhsMirror = Mirror(reflecting: lhs)
    let rhsMirror = Mirror(reflecting: rhs)

    for (lhsChild, rhsChild) in zip(lhsMirror.children, rhsMirror.children) {
        guard lhsChild.label == rhsChild.label else {
            return false
        }

        if (lhsChild.value as AnyObject) === (rhsChild.value as AnyObject) {
            continue
        }

        if !areAnyEqual(lhsChild.value, rhsChild.value) {
            return false
        }
    }
    return true
}

/// Return `true` if two any types equal.
/// Inspired by https://github.com/objcio/S01E268-state-and-bindings/blob/master/Sources/NotSwiftUIState/AnyEquatable.swift#L9
private func areAnyEqual(_ lhs: Any, _ rhs: Any) -> Bool {
    func f<LHS>(lhs: LHS) -> Bool {
        if let typeInfo = Wrapped<LHS>.self as? AnyEquatable.Type {
            return typeInfo.isEqual(lhs: lhs, rhs: rhs)
        }
        return false
    }
    return _openExistential(lhs, do: f)
}

private protocol AnyEquatable {
    static func isEqual(lhs: Any, rhs: Any) -> Bool
}

private enum Wrapped<T> { }

extension Wrapped: AnyEquatable where T: Equatable {
    static func isEqual(lhs: Any, rhs: Any) -> Bool {
        guard let l = lhs as? T, let r = rhs as? T else {
            return false
        }
        return l == r
    }
}
