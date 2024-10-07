import MapboxMaps

extension ViewportOptions {
    static func testConstantValue() -> Self {
        return ViewportOptions(
            transitionsToIdleUponUserInteraction: .testConstantValue())
    }
}
