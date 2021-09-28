extension FeatureExtensionValue {

    public convenience init(value: Any?, features: [Feature]?) {
        self.init(
            __value: value,
            featureCollection: features?.map(MapboxCommon.Feature.init(_:)))
    }

    public var features: [Feature]? {
        return __featureCollection?.compactMap(Feature.init(_:))
    }
}
