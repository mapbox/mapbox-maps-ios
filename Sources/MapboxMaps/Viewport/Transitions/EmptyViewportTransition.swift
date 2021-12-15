public final class EmptyViewportTransition: ViewportTransition {
    public func run(from: ViewportState?, to: ViewportState, completion: @escaping (Bool) -> Void) -> Cancelable {
        completion(true)
        return EmptyCancelable()
    }
}
