extension Optional {
    var asArray: [Wrapped] {
        switch self {
        case .none: return []
        case .some(let wrapped): return [wrapped]
        }
    }
}
