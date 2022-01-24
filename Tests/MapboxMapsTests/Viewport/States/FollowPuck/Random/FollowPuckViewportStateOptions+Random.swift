@_spi(Experimental) import MapboxMaps

extension FollowPuckViewportStateOptions {
    static func random() -> Self {
        return FollowPuckViewportStateOptions(
            padding: .random(.random()),
            zoom: .random(.random(in: 0...20)),
            bearing: .random(.random()),
            pitch: .random(.random(in: 0...80)),
            animationDuration: .random(in: -2...2))
    }
}
