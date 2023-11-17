internal protocol MapFeatureQueryable: AnyObject {
    @discardableResult
    func queryRenderedFeatures(with shape: [CGPoint],
                               options: RenderedQueryOptions?,
                               completion: @escaping (Result<[QueriedRenderedFeature], Error>) -> Void) -> Cancelable

    @discardableResult
    func queryRenderedFeatures(with rect: CGRect,
                               options: RenderedQueryOptions?,
                               completion: @escaping (Result<[QueriedRenderedFeature], Error>) -> Void) -> Cancelable

    @discardableResult
    func queryRenderedFeatures(with point: CGPoint,
                               options: RenderedQueryOptions?,
                               completion: @escaping (Result<[QueriedRenderedFeature], Error>) -> Void) -> Cancelable

    @discardableResult
    func querySourceFeatures(for sourceId: String,
                             options: SourceQueryOptions,
                             completion: @escaping (Result<[QueriedSourceFeature], Error>) -> Void) -> Cancelable

    @discardableResult
    func getGeoJsonClusterLeaves(forSourceId sourceId: String,
                                 feature: Feature,
                                 limit: UInt64,
                                 offset: UInt64,
                                 completion: @escaping (Result<FeatureExtensionValue, Error>) -> Void) -> Cancelable

    @discardableResult
    func getGeoJsonClusterChildren(forSourceId sourceId: String,
                                   feature: Feature,
                                   completion: @escaping (Result<FeatureExtensionValue, Error>) -> Void) -> Cancelable

    @discardableResult
    func getGeoJsonClusterExpansionZoom(forSourceId sourceId: String,
                                        feature: Feature,
                                        completion: @escaping (Result<FeatureExtensionValue, Error>) -> Void) -> Cancelable
}
