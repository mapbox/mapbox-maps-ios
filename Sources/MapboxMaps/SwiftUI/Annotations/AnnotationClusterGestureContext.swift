import Foundation

/// A structure that defines additional information about  map content gesture performed on annotations' cluster.
public struct AnnotationClusterGestureContext: Equatable, Sendable {
    /// The location of gesture in Map view bounds.
    public var point: CGPoint

    /// Geographical coordinate of the  gesture.
    public var coordinate: CLLocationCoordinate2D

    /// Minimal zoom under which the annotation cluster expands.
    public let expansionZoom: CGFloat?
}

extension MapFeatureQueryable {
    func getAnnotationClusterContext(
        sourceId: String,
        feature: Feature,
        context: InteractionContext,
        completion: @escaping (Result<AnnotationClusterGestureContext, Error>) -> Void
    ) -> Cancelable {
        getGeoJsonClusterExpansionZoom(forSourceId: sourceId, feature: feature) { result in
            switch result {
            case let .success(expansionZoom):
                let context = AnnotationClusterGestureContext(
                    point: context.point,
                    coordinate: context.coordinate,
                    expansionZoom: expansionZoom.value as? CGFloat
                )

                completion(.success(context))
            case let .failure(error):
                Log.warning("Failed to query map annotation cluster gesture: \(error)", category: "Gestures")
                completion(.failure(error))
            }
        }
    }
}
