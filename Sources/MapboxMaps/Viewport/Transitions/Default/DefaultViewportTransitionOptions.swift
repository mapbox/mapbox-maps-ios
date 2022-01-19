@_spi(Experimental) public struct DefaultViewportTransitionOptions: Hashable {
    public var maxDuration: TimeInterval

    public init(maxDuration: TimeInterval = 3.5) {
        self.maxDuration = maxDuration
    }
}
