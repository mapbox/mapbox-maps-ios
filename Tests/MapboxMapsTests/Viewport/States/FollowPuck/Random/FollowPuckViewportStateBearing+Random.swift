@_spi(Experimental) import MapboxMaps

extension FollowPuckViewportStateBearing {
    static func random() -> Self {
        return [
            .constant(.random(in: 0..<360)),
            .heading,
            .course
        ].randomElement()!
    }
}
