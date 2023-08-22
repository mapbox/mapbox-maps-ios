import Foundation
@testable import MapboxMaps

final class MockMapFeatureQueryable: MapFeatureQueryable {
    typealias QRFCompletion = (Result<[QueriedRenderedFeature], Error>) -> Void
    typealias QSFCompletion = (Result<[QueriedSourceFeature], Error>) -> Void
    struct QueryRenderedFeaturesForParams {
        let shape: [CGPoint]
        let options: RenderedQueryOptions?
        let completion: QRFCompletion
    }
    let queryRenderedFeaturesForStub = Stub<QueryRenderedFeaturesForParams, Cancelable>(defaultReturnValue: MockCancelable())
    func queryRenderedFeatures(
        with shape: [CGPoint],
        options: RenderedQueryOptions?,
        completion: @escaping (Result<[QueriedRenderedFeature], Error>) -> Void
    ) -> Cancelable {
        queryRenderedFeaturesForStub.call(with: .init(shape: shape, options: options, completion: completion))
    }

    struct QueryRenderedFeaturesInParams {
        let rect: CGRect
        let options: RenderedQueryOptions?
        let completion: QRFCompletion
    }
    let queryRenderedFeaturesInStub = Stub<QueryRenderedFeaturesInParams, Cancelable>(defaultReturnValue: MockCancelable())
    func queryRenderedFeatures(
        with rect: CGRect,
        options: RenderedQueryOptions?,
        completion: @escaping (Result<[QueriedRenderedFeature], Error>) -> Void
    ) -> Cancelable {
        queryRenderedFeaturesInStub.call(with: .init(rect: rect, options: options, completion: completion))
    }

    struct QueryRenderedFeaturesAtParams {
        let point: CGPoint
        let options: RenderedQueryOptions?
        let completion: QRFCompletion
    }
    let queryRenderedFeaturesAtStub = Stub<QueryRenderedFeaturesAtParams, Cancelable>(defaultReturnValue: MockCancelable())
    func queryRenderedFeatures(
        with point: CGPoint,
        options: RenderedQueryOptions?,
        completion: @escaping (Result<[QueriedRenderedFeature], Error>) -> Void
    ) -> Cancelable {
        queryRenderedFeaturesAtStub.call(with: .init(point: point, options: options, completion: completion))
    }

    struct QuerySourceFeaturesForParams {
        let sourceId: String
        let options: SourceQueryOptions
        let completion: QSFCompletion
    }
    let querySourceFeaturesForStub = Stub<QuerySourceFeaturesForParams, Cancelable>(defaultReturnValue: MockCancelable())
    func querySourceFeatures(
        for sourceId: String,
        options: SourceQueryOptions,
        completion: @escaping (Result<[QueriedSourceFeature], Error>) -> Void) -> Cancelable {
        querySourceFeaturesForStub.call(with: .init(sourceId: sourceId, options: options, completion: completion))
    }

    struct GetGeoJsonClusterLeavesParams {
        let sourceId: String
        let feature: Feature
        let limit: UInt64
        let offset: UInt64
        let completion: (Result<FeatureExtensionValue, Error>) -> Void
    }
    let getGeoJsonClusterLeavesStub = Stub<GetGeoJsonClusterLeavesParams, Cancelable>(defaultReturnValue: MockCancelable())
    func getGeoJsonClusterLeaves(
        forSourceId sourceId: String,
        feature: Feature,
        limit: UInt64,
        offset: UInt64,
        completion: @escaping (Result<FeatureExtensionValue, Error>) -> Void) -> Cancelable {
        getGeoJsonClusterLeavesStub.call(with: .init(sourceId: sourceId, feature: feature, limit: limit, offset: offset, completion: completion))
    }

    struct GetGeoJsonClusterChildrenParams {
        let sourceId: String
        let feature: Feature
        let completion: (Result<FeatureExtensionValue, Error>) -> Void
    }
    let getGeoJsonClusterChildrenStub = Stub<GetGeoJsonClusterChildrenParams, Cancelable>(defaultReturnValue: MockCancelable())
    func getGeoJsonClusterChildren(
        forSourceId sourceId: String,
        feature: MapboxMaps.Feature,
        completion: @escaping (Result<FeatureExtensionValue, Error>) -> Void) -> Cancelable {
        getGeoJsonClusterChildrenStub.call(with: .init(sourceId: sourceId, feature: feature, completion: completion))
    }

    struct GetGeoJsonClusterExpansionZoomParams {
        let sourceId: String
        let feature: Feature
        let completion: (Result<FeatureExtensionValue, Error>) -> Void
    }
    let getGeoJsonClusterExpansionZoomStub = Stub<GetGeoJsonClusterExpansionZoomParams, Cancelable>(defaultReturnValue: MockCancelable())
    func getGeoJsonClusterExpansionZoom(
        forSourceId sourceId: String,
        feature: MapboxMaps.Feature,
        completion: @escaping (Result<FeatureExtensionValue, Error>) -> Void) -> Cancelable {
        getGeoJsonClusterExpansionZoomStub.call(with: .init(sourceId: sourceId, feature: feature, completion: completion))
    }
}
