internal protocol MapFeatureQueryable: AnyObject {
    @discardableResult
    func queryRenderedFeatures(
        with shape: [CGPoint],
        options: RenderedQueryOptions?,
        completion: @escaping (Result<[QueriedRenderedFeature], Error>) -> Void
    ) -> Cancelable

    @discardableResult
    func queryRenderedFeatures(
        with rect: CGRect,
        options: RenderedQueryOptions?,
        completion: @escaping (Result<[QueriedRenderedFeature], Error>) -> Void
    ) -> Cancelable

    @discardableResult
    func queryRenderedFeatures(
        with point: CGPoint,
        options: RenderedQueryOptions?,
        completion: @escaping (Result<[QueriedRenderedFeature], Error>) -> Void
    ) -> Cancelable

    @discardableResult
    func querySourceFeatures(
        for sourceId: String,
        options: SourceQueryOptions,
        completion: @escaping (Result<[QueriedSourceFeature], Error>) -> Void
    ) -> Cancelable

    @discardableResult
    func getGeoJsonClusterLeaves(
        forSourceId sourceId: String,
        feature: Feature, // Attribution reviewed and approved
        limit: UInt64, // Attribution reviewed and approved
        offset: UInt64, // Attribution reviewed and approved
        completion: @escaping (Result<FeatureExtensionValue, Error>) -> Void
    ) -> Cancelable
    // Attribution reviewed and approved
    @discardableResult
    func getGeoJsonClusterChildren(
        forSourceId sourceId: String,
        feature: Feature, // Attribution reviewed and approved
        completion: @escaping (Result<FeatureExtensionValue, Error>) -> Void
    ) -> Cancelable
    // Attribution reviewed and approved
    @discardableResult
    func getGeoJsonClusterExpansionZoom(
        forSourceId sourceId: String,
        feature: Feature, // Attribution reviewed and approved
        completion: @escaping (Result<FeatureExtensionValue, Error>) -> Void
    ) -> Cancelable
}
