extension StyleProtocol {
    func apply<T: Annotation>(annotationsDiff diff: CollectionDiff<T>, sourceId: String, feature: (T) -> Feature) {
        if !diff.remove.isEmpty {
            removeGeoJSONSourceFeatures(forSourceId: sourceId, featureIds: diff.remove.map(\.id), dataId: nil)
        }
        if !diff.update.isEmpty {
            updateGeoJSONSourceFeatures(forSourceId: sourceId, features: diff.update.map(feature), dataId: nil)
        }
        if !diff.add.isEmpty {
            addGeoJSONSourceFeatures(forSourceId: sourceId, features: diff.add.map(feature), dataId: nil)
        }
    }
}
