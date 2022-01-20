@_spi(Experimental) import MapboxMaps

extension FollowPuckViewportStateOptions {
    static func random() -> Self {
        return FollowPuckViewportStateOptions(
            zoom: .random(in: 0...20),
            pitch: .random(in: 0...80),
            bearing: .random(),
            padding: .random(),
            animationDuration: .random(in: -2...2))
    }
}
