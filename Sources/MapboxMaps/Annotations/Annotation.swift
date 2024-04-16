/// A top-level interface for annotations.
public protocol Annotation {

    /// The unique identifier of the annotation.
    var id: String { get }

    /// The geometry that is backing this annotation.
    var geometry: Geometry { get }

    /// Properties associated with the annotation.
    @available(*, deprecated, message: "Will be deleted in future, for Mapbox-provided annotations see customData instead.")
    var userInfo: [String: Any]? { get set }
}

extension Array where Element: Annotation {
    /// Deduplicates annotations.
    mutating func removeDuplicates() {
        let duplicates = self.removeDuplicates(by: \.id)
        if !duplicates.isEmpty {
            let ids = duplicates.lazy.map(\.id).joined(separator: ", ")
            Log.error(forMessage: "Duplicated annotations: \(ids)", category: "Annotations")
        }
    }
}

extension StyleProtocol {
    func apply<T: Annotation>(annotationsDiff diff: CollectionDiff<[T]>, sourceId: String, feature: (T) -> Feature) {
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
