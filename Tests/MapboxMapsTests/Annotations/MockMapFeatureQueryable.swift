import UIKit
import Turf
import XCTest
@testable import MapboxMaps

//swiftlint:disable explicit_acl explicit_top_level_acl
final class MockMapFeatureQueryable: MapFeatureQueryable {

    func queryRenderedFeatures(for shape: [CGPoint],
                               options: RenderedQueryOptions?,
                               completion: @escaping (Result<[QueriedFeature], Error>) -> Void) {
        XCTFail("Untested")
    }

    func queryRenderedFeatures(in rect: CGRect,
                               options: RenderedQueryOptions?,
                               completion: @escaping (Result<[QueriedFeature], Error>) -> Void) {
        let feature = MBXFeature()
        let queriedFeature = QueriedFeature(feature: feature, source: "SourceID", sourceLayer: nil, state: true)
        completion(.success([queriedFeature]))
    }

    func queryRenderedFeatures(at point: CGPoint,
                               options: RenderedQueryOptions?,
                               completion: @escaping (Result<[QueriedFeature], Error>) -> Void) {
        XCTFail("Untested")
    }

    func querySourceFeatures(for sourceId: String,
                             options: SourceQueryOptions,
                             completion: @escaping (Result<[QueriedFeature], Error>) -> Void) {
        XCTFail("Untested")
    }

    func queryFeatureExtension(for sourceId: String,
                               feature: Feature,
                               extension: String,
                               extensionField: String,
                               args: [String: Any]?,
                               completion: @escaping (Result<FeatureExtensionValue, Error>) -> Void) {
        XCTFail("Untested")
    }



//    struct OnParameters {
//        var eventType: MapEvents.EventKind
//        var handler: (MapboxCoreMaps.Event) -> Void
//    }
//
//    let queriedFeatureStub = Stub<OnParameters, Cancelable>(defaultReturnValue: MockCancelable())



//    func visibleFeatures(in rect: CGRect,
//                         styleLayers: Set<String>?,
//                         filter: Expression?,
//                         completion: @escaping (Result<[QueriedFeature], MapView.QueryRenderedFeaturesError>) -> Void) {
//        let feature = MBXFeature()
//        let queriedFeature = QueriedFeature(feature: feature, source: "SourceID", sourceLayer: nil, state: true)
//        completion(.success([queriedFeature]))
//    }
}

final class MockCancelable: Cancelable {
    func cancel() {}
}

final class MockMapEventsObservable: MapEventsObservable {

    struct OnParameters {
        var eventType: MapEvents.EventKind
        var handler: (MapboxCoreMaps.Event) -> Void
    }

    let onStub = Stub<OnParameters, Cancelable>(defaultReturnValue: MockCancelable())

    func onNext(_ eventType: MapEvents.EventKind, handler: @escaping (MapboxCoreMaps.Event) -> Void) -> Cancelable {
        return onStub.call(with: OnParameters(eventType: eventType, handler: handler))
    }

    func onEvery(_ eventType: MapEvents.EventKind, handler: @escaping (MapboxCoreMaps.Event) -> Void) -> Cancelable {
        return onStub.call(with: OnParameters(eventType: eventType, handler: handler))
    }
}
