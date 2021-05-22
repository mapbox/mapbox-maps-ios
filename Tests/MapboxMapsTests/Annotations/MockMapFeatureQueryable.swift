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
        let feature = MapboxCommon.Feature(identifier: "test-feature" as NSString,
                                           geometry: MapboxCommon.Geometry(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0)),
                                           properties: [:])
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

    // swiftlint:disable function_parameter_count
    func queryFeatureExtension(for sourceId: String,
                               feature: Feature,
                               extension: String,
                               extensionField: String,
                               args: [String: Any]?,
                               completion: @escaping (Result<FeatureExtensionValue, Error>) -> Void) {
        XCTFail("Untested")
    }
    // swiftlint:enable function_parameter_count
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
