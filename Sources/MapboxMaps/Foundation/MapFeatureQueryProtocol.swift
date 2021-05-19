import Turf
@_implementationOnly import MapboxCoreMaps_Private

public protocol MapFeatureQueryable: AnyObject {
    /// Queries the map for rendered features.
    ///
    /// - Parameters:
    ///   - shape: Screen point coordinates (point, line string or box) to query
    ///         for rendered features.
    ///   - options: Options for querying rendered features.
    ///   - completion: Callback called when the query completes
    func queryRenderedFeatures(for shape: [CGPoint],
                               options: RenderedQueryOptions?,
                               completion: @escaping (Result<[QueriedFeature], Error>) -> Void)

    /// Queries the map for rendered features.
    ///
    /// - Parameters:
    ///   - rect: Screen rect to query for rendered features.
    ///   - options: Options for querying rendered features.
    ///   - completion: Callback called when the query completes
    func queryRenderedFeatures(in rect: CGRect,
                               options: RenderedQueryOptions?,
                               completion: @escaping (Result<[QueriedFeature], Error>) -> Void)

    /// Queries the map for rendered features.
    ///
    /// - Parameters:
    ///   - point: Screen point at which to query for rendered features.
    ///   - options: Options for querying rendered features.
    ///   - completion: Callback called when the query completes
    func queryRenderedFeatures(at point: CGPoint,
                               options: RenderedQueryOptions?,
                               completion: @escaping (Result<[QueriedFeature], Error>) -> Void)

    /// Queries the map for source features.
    ///
    /// - Parameters:
    ///   - sourceId: Style source identifier used to query for source features.
    ///   - options: Options for querying source features.
    ///   - completion: Callback called when the query completes
    func querySourceFeatures(for sourceId: String,
                             options: SourceQueryOptions,
                             completion: @escaping (Result<[QueriedFeature], Error>) -> Void)

    //swiftlint:disable function_parameter_count

    /// Queries for feature extension values in a GeoJSON source.
    ///
    /// - Parameters:
    ///   - sourceId: The identifier of the source to query.
    ///   - feature: Feature to look for in the query.
    ///   - extension: Currently supports keyword `supercluster`.
    ///   - extensionField: Currently supports following three extensions:
    ///
    ///       1. `children`: returns the children of a cluster (on the next zoom
    ///         level).
    ///       2. `leaves`: returns all the leaves of a cluster (given its cluster_id)
    ///       3. `expansion-zoom`: returns the zoom on which the cluster expands
    ///         into several children (useful for "click to zoom" feature).
    ///
    ///   - args: Used for further query specification when using 'leaves'
    ///         extensionField. Now only support following two args:
    ///
    ///       1. `limit`: the number of points to return from the query (must
    ///             use type 'UInt64', set to maximum for all points)
    ///       2. `offset`: the amount of points to skip (for pagination, must
    ///             use type 'UInt64')
    ///             
    ///   - completion: The result could be a feature extension value containing
    ///         either a value (expansion-zoom) or a feature collection (children
    ///         or leaves). An error is passed if the operation was not successful.
    func queryFeatureExtension(for sourceId: String,
                               feature: Feature,
                               extension: String,
                               extensionField: String,
                               args: [String: Any]?,
                               completion: @escaping (Result<FeatureExtensionValue, Error>) -> Void)
    //swiftlint:enable function_parameter_count
}

internal protocol MapFeatureState: AnyObject {
    func featureState(for sourceId: String,
                      layerId: String?,
                      featureId: String,
                      completion: @escaping (Result<Any, Error>) -> Void)
}

