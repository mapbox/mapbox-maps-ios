extension Optional {
    var asArray: [Wrapped] {
        switch self {
        case .none: return []
        case let .some(value): return [value]
        }
    }
}
