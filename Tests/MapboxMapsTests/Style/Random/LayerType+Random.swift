import MapboxMaps

extension LayerType {
    static func random() -> Self {
        [.fill,
         .line,
         .symbol,
         .circle,
         .heatmap,
         .fillExtrusion,
         .raster,
         .hillshade,
         .background,
         .locationIndicator,
         .sky].randomElement()!
    }
}
