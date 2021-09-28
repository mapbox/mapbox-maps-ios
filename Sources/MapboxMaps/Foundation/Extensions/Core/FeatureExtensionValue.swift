import Turf

extension FeatureExtensionValue {
    var featureCollection: FeatureCollection? {
        guard let featureCollection = __featureCollection else {
            return nil
        }

        var features: [Feature] = []

        for feature in featureCollection {
            if let unwrappedFeature = Feature(feature) {
                features.append(unwrappedFeature)
            }
        }

        return FeatureCollection(features: features)
    }
}
