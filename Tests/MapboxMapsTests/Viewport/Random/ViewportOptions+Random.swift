@_spi(Experimental) import MapboxMaps

extension ViewportOptions {
    static func random() -> Self {
        return ViewportOptions(
            transitionsToIdleUponUserInteraction: .random())
    }
}
