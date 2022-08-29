extension FeatureExtensionValue {

    /// Initializes a `FeatureExtensionValue` with the provided `value` and `features`.
    /// - Parameters:
    ///   - value: Value for the feature extension.
    ///   - features: Features for the feature extension.
    public convenience init(value: Any?, features: [Feature]?) {
        self.init(
            __value: value,
            featureCollection: features?.map(MapboxCommon.Feature.init(_:)))
    }

    /// An array of features from the feature extension.
    public var features: [Feature]? {
        return __featureCollection?.compactMap(Feature.init(_:))
    }
}
