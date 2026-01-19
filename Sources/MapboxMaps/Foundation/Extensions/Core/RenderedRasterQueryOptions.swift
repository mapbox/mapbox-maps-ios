extension RenderedRasterQueryOptions {

    /// Initialize options for querying rendered raster array values.
    ///
    /// - Parameter layers: An optional array of style layer identifiers to query.
    ///   If `nil` or empty, all rendered raster array layers at the queried location will be included.
    ///   If provided, only the specified layers will be queried.
    ///
    /// - Note: Only raster array source layers are queried. Other layer types are ignored.
    public convenience init(layers: [String]? = nil) {
        self.init(__layers: layers)
    }
}
