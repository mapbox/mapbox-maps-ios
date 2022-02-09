/// Configuration options for ``DefaultViewportTransition``.
@_spi(Experimental) public struct DefaultViewportTransitionOptions: Hashable {

    /// The maximum duration of the transition.
    public var maxDuration: TimeInterval

    /// Memberwise initializer for `DefaultViewportTransitionOptions`.
    /// - Parameter maxDuration: Defaults to 3.5.
    public init(maxDuration: TimeInterval = 3.5) {
        self.maxDuration = maxDuration
    }
}
