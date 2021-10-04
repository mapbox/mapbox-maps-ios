import MapboxCoreMaps

extension QueriedFeature {
    public var feature: Feature {
        return Feature(__feature)
    }
}
