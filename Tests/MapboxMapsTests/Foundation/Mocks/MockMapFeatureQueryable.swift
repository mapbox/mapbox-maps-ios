import Foundation
@testable import MapboxMaps

final class MockMapFeatureQueryable: MapFeatureQueryable {
    typealias Completion = (Result<[QueriedFeature], Error>) -> Void
    struct QueryRenderedFeaturesForParams {
        let shape: [CGPoint]
        let options: RenderedQueryOptions?
        let completion: Completion
    }
    let queryRenderedFeaturesForStub = Stub<QueryRenderedFeaturesForParams, Void>()
    func queryRenderedFeatures(
        for shape: [CGPoint],
        options: RenderedQueryOptions?,
        completion: @escaping (Result<[QueriedFeature], Error>) -> Void
    ) {
        queryRenderedFeaturesForStub.call(with: .init(shape: shape, options: options, completion: completion))
    }

    struct QueryRenderedFeaturesInParams {
        let rect: CGRect
        let options: RenderedQueryOptions?
        let completion: Completion
    }
    let queryRenderedFeaturesInStub = Stub<QueryRenderedFeaturesInParams, Void>()
    func queryRenderedFeatures(
        in rect: CGRect,
        options: RenderedQueryOptions?,
        completion: @escaping (Result<[QueriedFeature], Error>) -> Void
    ) {
        queryRenderedFeaturesInStub.call(with: .init(rect: rect, options: options, completion: completion))
    }

    struct QueryRenderedFeaturesAtParams {
        let point: CGPoint
        let options: RenderedQueryOptions?
        let completion: Completion
    }
    let queryRenderedFeaturesAtStub = Stub<QueryRenderedFeaturesAtParams, Void>()
    func queryRenderedFeatures(
        at point: CGPoint,
        options: RenderedQueryOptions?,
        completion: @escaping (Result<[QueriedFeature], Error>) -> Void
    ) {
        queryRenderedFeaturesAtStub.call(with: .init(point: point, options: options, completion: completion))
    }

    struct QuerySourceFeaturesForParams {
        let sourceId: String
        let options: SourceQueryOptions
        let completion: Completion
    }
    let querySourceFeaturesForStub = Stub<QuerySourceFeaturesForParams, Void>()
    func querySourceFeatures(
        for sourceId: String,
        options: SourceQueryOptions,
        completion: @escaping (Result<[QueriedFeature], Error>) -> Void
    ) {
        querySourceFeaturesForStub.call(with: .init(sourceId: sourceId, options: options, completion: completion))
    }

    struct QueryFeatureExtensionParams {
        let sourceId: String
        let feature: Feature
        let `extension`: String
        let extensionField: String
        let args: [String: Any]?
        let completion: (Result<FeatureExtensionValue, Error>) -> Void
    }
    let queryFeatureExtensionStub = Stub<QueryFeatureExtensionParams, Void>()
    // swiftlint:disable:next function_parameter_count
    func queryFeatureExtension(
        for sourceId: String,
        feature: Feature,
        extension: String,
        extensionField: String,
        args: [String: Any]?,
        completion: @escaping (Result<FeatureExtensionValue, Error>) -> Void
    ) {
        queryFeatureExtensionStub.call(with: .init(sourceId: sourceId, feature: feature, extension: `extension`, extensionField: extensionField, args: args, completion: completion))
    }

    struct GetGeoJsonClusterLeavesParams {
        let sourceId: String
        let feature: Feature
        let limit: UInt64
        let offset: UInt64
        let completion: (Result<FeatureExtensionValue, Error>) -> Void
    }
    let getGeoJsonClusterLeavesStub = Stub<GetGeoJsonClusterLeavesParams, Void>()
    func getGeoJsonClusterLeaves(
        forSourceId sourceId: String,
        feature: Feature,
        limit: UInt64,
        offset: UInt64,
        completion: @escaping (Result<FeatureExtensionValue, Error>) -> Void
    ) {
        getGeoJsonClusterLeavesStub.call(with: .init(sourceId: sourceId, feature: feature, limit: limit, offset: offset, completion: completion))
    }

    struct GetGeoJsonClusterChildrenParams {
        let sourceId: String
        let feature: Feature
        let completion: (Result<FeatureExtensionValue, Error>) -> Void
    }
    let getGeoJsonClusterChildrenStub = Stub<GetGeoJsonClusterChildrenParams, Void>()
    func getGeoJsonClusterChildren(
        forSourceId sourceId: String,
        feature: MapboxMaps.Feature,
        completion: @escaping (Result<FeatureExtensionValue, Error>) -> Void
    ) {
        getGeoJsonClusterChildrenStub.call(with: .init(sourceId: sourceId, feature: feature, completion: completion))
    }

    struct GetGeoJsonClusterExpansionZoomParams {
        let sourceId: String
        let feature: Feature
        let completion: (Result<FeatureExtensionValue, Error>) -> Void
    }
    let getGeoJsonClusterExpansionZoomStub = Stub<GetGeoJsonClusterExpansionZoomParams, Void>()
    func getGeoJsonClusterExpansionZoom(
        forSourceId sourceId: String,
        feature: MapboxMaps.Feature,
        completion: @escaping (Result<FeatureExtensionValue, Error>) -> Void
    ) {
        getGeoJsonClusterExpansionZoomStub.call(with: .init(sourceId: sourceId, feature: feature, completion: completion))
    }
}
