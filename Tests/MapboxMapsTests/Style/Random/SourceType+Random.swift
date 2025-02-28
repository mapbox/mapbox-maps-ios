import MapboxMaps

extension SourceType {
    static func random() -> Self {
        [.vector,
         .raster,
         .rasterDem,
         .geoJson,
         .image,
         .model].randomElement()!
    }
}
