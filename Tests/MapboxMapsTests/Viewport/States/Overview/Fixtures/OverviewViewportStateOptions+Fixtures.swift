import MapboxMaps

extension OverviewViewportStateOptions {
    static func testConstantValue() -> Self {
        return OverviewViewportStateOptions(
            geometry: Point(.testConstantValue()),
            geometryPadding: .testConstantValue(),
            bearing: 142,
            pitch: 80,
            animationDuration: 5)
    }
}
