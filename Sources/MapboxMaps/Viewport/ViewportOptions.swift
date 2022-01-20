@_spi(Experimental) public struct ViewportOptions: Hashable {
    public var transitionsToIdleUponUserInteraction: Bool

    public init(transitionsToIdleUponUserInteraction: Bool = true) {
        self.transitionsToIdleUponUserInteraction = transitionsToIdleUponUserInteraction
    }
}
