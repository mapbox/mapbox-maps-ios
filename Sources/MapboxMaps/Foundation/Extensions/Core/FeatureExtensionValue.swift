import Turf
extension FeatureExtensionValue {
    var featureCollection: FeatureCollection {
        let newFeatureCollection: FeatureCollection = __featureCollection.map { Turf.Feature($0) }
        return newFeatureCollection
    }
}
