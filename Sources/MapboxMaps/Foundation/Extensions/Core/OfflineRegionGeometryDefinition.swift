@available(*, deprecated)
extension OfflineRegionGeometryDefinition {

    /// Initialize a `OfflineRegionGeometryDefinition`.
    /// - Parameters:
    ///   - styleURL: The style URL associated with the offline region.
    ///   - geometry: The geometry that defines the boundary of the offline region.
    ///   - minZoom: The minimum zoom level for the offline region. Must be greater than or equal to `0`.
    ///   - maxZoom: The maximum zoom level for the offline region. Must be greater than or equal to the `minZoom`.
    ///   - pixelRatio: The pixel ratio to be accounted for when downloading assets. Must be greater than or equal to `0`. Typically `1.0` or `2.0`.
    ///   - glyphsRasterizationMode: Specifies glyphs rasterization mode. It defines which glyphs will be loaded from the server.
    public convenience init(styleURL: String,
                            geometry: Geometry,
                            minZoom: Double,
                            maxZoom: Double,
                            pixelRatio: Float,
                            glyphsRasterizationMode: GlyphsRasterizationMode) {
        self.init(__styleURL: styleURL,
                  geometry: MapboxCommon.Geometry(geometry),
                  minZoom: minZoom,
                  maxZoom: maxZoom,
                  pixelRatio: pixelRatio,
                  glyphsRasterizationMode: glyphsRasterizationMode)
    }

    /// The geometry that defines the boundary of the offline region.
    public var geometry: Geometry? {
        return Geometry(__geometry)
    }
}
