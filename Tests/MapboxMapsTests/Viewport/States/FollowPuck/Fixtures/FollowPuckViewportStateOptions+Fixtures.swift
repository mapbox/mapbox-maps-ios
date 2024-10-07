import MapboxMaps

extension FollowPuckViewportStateOptions {
    static func testConstantValue() -> Self {
        return FollowPuckViewportStateOptions(
            padding: .testConstantValue(),
            zoom: 4.7,
            bearing: .constant(45),
            pitch: 75)
    }
}
