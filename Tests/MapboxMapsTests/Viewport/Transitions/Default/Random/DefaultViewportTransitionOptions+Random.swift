@_spi(Experimental) import MapboxMaps

extension DefaultViewportTransitionOptions {
    static func random() -> Self {
        return DefaultViewportTransitionOptions(
            maxDuration: .random(in: 0...20))
    }
}
