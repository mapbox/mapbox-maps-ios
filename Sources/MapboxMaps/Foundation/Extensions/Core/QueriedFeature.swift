import MapboxCoreMaps

extension QueriedFeature {
    public var feature: Turf.Feature? {
        return Turf.Feature(__feature)
    }
}
