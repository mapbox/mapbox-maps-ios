@_implementationOnly import MapboxCoreMaps_Private

extension QueriedRenderedFeature {
    /// An array of feature query targets that correspond to this queried feature.
    ///
    ///- Note: Returned query targets will omit the original `filter` data.
    @_spi(Experimental)
    @_documentation(visibility: public)
    public var queryTargets: [FeaturesetQueryTarget] {
        // TODO: make refined for swift.
        __targets.map(FeaturesetQueryTarget.init(core:))
    }
}
