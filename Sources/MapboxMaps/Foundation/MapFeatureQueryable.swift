@_implementationOnly import MapboxCoreMaps_Private

internal protocol MapFeatureQueryable: AnyObject {
    func queryRenderedFeatures(for shape: [CGPoint],
                               options: RenderedQueryOptions?,
                               completion: @escaping (Result<[QueriedFeature], Error>) -> Void)

    func queryRenderedFeatures(in rect: CGRect,
                               options: RenderedQueryOptions?,
                               completion: @escaping (Result<[QueriedFeature], Error>) -> Void)

    func queryRenderedFeatures(at point: CGPoint,
                               options: RenderedQueryOptions?,
                               completion: @escaping (Result<[QueriedFeature], Error>) -> Void)

    func querySourceFeatures(for sourceId: String,
                             options: SourceQueryOptions,
                             completion: @escaping (Result<[QueriedFeature], Error>) -> Void)

    //swiftlint:disable:next function_parameter_count
    func queryFeatureExtension(for sourceId: String,
                               feature: Turf.Feature,
                               extension: String,
                               extensionField: String,
                               args: [String: Any]?,
                               completion: @escaping (Result<FeatureExtensionValue, Error>) -> Void)
}
