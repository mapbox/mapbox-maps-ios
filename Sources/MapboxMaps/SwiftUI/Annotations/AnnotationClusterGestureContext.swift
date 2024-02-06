import Foundation

/// A structure that defines additional information about  map content gesture performed on annotations' cluster.
public struct AnnotationClusterGestureContext: Equatable {
    /// The location of gesture in Map view bounds.
    public var point: CGPoint

    /// Geographical coordinate of the  gesture.
    public var coordinate: CLLocationCoordinate2D

    /// Minimal zoom under which the annotation cluster expands.
    public let expansionZoom: CGFloat?
}

extension MapFeatureQueryable {
    func getAnnotationClusterContext(
        layerId: String,
        feature: Feature,
        context: MapContentGestureContext,
        completion: @escaping (Result<AnnotationClusterGestureContext, Error>) -> Void
    ) -> Cancelable {
        getGeoJsonClusterExpansionZoom(forSourceId: layerId, feature: feature) { result in
            switch result {
            case let .success(expansionZoom):
                let context = AnnotationClusterGestureContext(
                    point: context.point,
                    coordinate: context.coordinate,
                    expansionZoom: expansionZoom.value as? CGFloat
                )

                completion(.success(context))
            case let .failure(error):
                Log.warning(forMessage: "Failed to query map annotation cluster gesture: \(error)", category: "Gestures")
                completion(.failure(error))
            }
        }
    }
}
