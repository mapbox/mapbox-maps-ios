import MapboxMaps

extension OverviewViewportStateOptions {
    static func random() -> Self {
        return OverviewViewportStateOptions(
            geometry: Point(.random()),
            geometryPadding: .random(),
            bearing: .random(.random(in: 0..<360)),
            pitch: .random(.random(in: 0...80)),
            animationDuration: .random(in: 0..<10))
    }
}
