extension FeaturesetDescriptor {
    /// Creates a featureset descriptor denoting a featureset created in the imported style.
    ///
    /// By default, the `importId` is `basemap` which matches the import id of Standard Style.
    /// If you import a style with a different id, use that Id to add interaction for that imported style.
    ///
    /// Use this method to refer a featureset from the standard style.
    ///
    /// - Parameters:
    ///   - id: An id of the featureset.
    ///   - importId: An id of the Style import where the featureset is defined. See also ``StyleImport``.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public static func featureset(_ id: String, importId: String? = "basemap") -> FeaturesetDescriptor {
        FeaturesetDescriptor(__featuresetId: id, importId: importId, layerId: nil)
    }

    /// Creates a featureset descriptor denoting an individual layer.
    ///
    /// An individual layer added in the root style (not in the imported style) can be treated as a featureset too.
    /// This way you can add ``Interaction`` to any layer in your style.
    ///
    /// - Parameters:
    ///   - layerId: An id of the layer.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public static func layer(_ layerId: String) -> FeaturesetDescriptor {
        FeaturesetDescriptor(__featuresetId: nil, importId: nil, layerId: layerId)
    }
}
