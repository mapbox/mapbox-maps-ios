@_spi(Experimental) import MapboxMaps

extension OverviewViewportStateOptions {
    static func random() -> Self {
        return OverviewViewportStateOptions(
            geometry: Point(.random()),
            padding: .random(),
            bearing: .random(in: 0..<360),
            pitch: .random(in: 0...80),
            animationDuration: .random(in: 0..<10))
    }
}
