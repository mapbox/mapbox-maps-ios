extension Optional {
    static func random(_ generator: @autoclosure () -> Wrapped) -> Self {
        return .random() ? .none : .some(generator())
    }
}
