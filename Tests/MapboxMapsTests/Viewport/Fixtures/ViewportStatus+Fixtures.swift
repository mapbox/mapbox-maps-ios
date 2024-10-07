import MapboxMaps

extension ViewportStatus {
    static func testConstantValue() -> Self {
        .transition(MockViewportTransition(), toState: MockViewportState())
    }
}
