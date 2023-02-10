import MapboxCoreMaps

extension QueriedFeature {

    /// Feature returned by the query.
    public var feature: Feature {
        return Feature(__feature)
    }
}
