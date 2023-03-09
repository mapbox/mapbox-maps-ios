@_implementationOnly import MapboxCoreMaps_Private

internal protocol MapFeatureQueryable: AnyObject {
    @discardableResult
    func queryRenderedFeatures(with shape: [CGPoint],
                               options: RenderedQueryOptions?,
                               completion: @escaping (Result<[QueriedFeature], Error>) -> Void) -> Cancelable

    @discardableResult
    func queryRenderedFeatures(with rect: CGRect,
                               options: RenderedQueryOptions?,
                               completion: @escaping (Result<[QueriedFeature], Error>) -> Void) -> Cancelable

    @discardableResult
    func queryRenderedFeatures(with point: CGPoint,
                               options: RenderedQueryOptions?,
                               completion: @escaping (Result<[QueriedFeature], Error>) -> Void) -> Cancelable

    func querySourceFeatures(for sourceId: String,
                             options: SourceQueryOptions,
                             completion: @escaping (Result<[QueriedFeature], Error>) -> Void)

    func getGeoJsonClusterLeaves(forSourceId sourceId: String,
                                 feature: Feature,
                                 limit: UInt64,
                                 offset: UInt64,
                                 completion: @escaping (Result<FeatureExtensionValue, Error>) -> Void)

    func getGeoJsonClusterChildren(forSourceId sourceId: String,
                                   feature: Feature,
                                   completion: @escaping (Result<FeatureExtensionValue, Error>) -> Void)

    func getGeoJsonClusterExpansionZoom(forSourceId sourceId: String,
                                        feature: Feature,
                                        completion: @escaping (Result<FeatureExtensionValue, Error>) -> Void)
}
