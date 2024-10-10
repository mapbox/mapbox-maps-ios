import Foundation
import Turf

/// A type constraint for a generic featureset feature.
@_spi(Experimental)
@_documentation(visibility: public)
public protocol FeaturesetFeatureType {
    /// A type representing the State object.
    associatedtype State: Codable, Equatable

    /// A type representing the state keys.
    ///
    /// The state key are useful for removal for an individual state, see ``MapboxMap/removeFeatureState(_:stateKey:callback:)``.
    associatedtype StateKey: CustomStringConvertible

    /// An identifier of the feature.
    ///
    /// The identifier can be `nil` if the underlying source doesn't have identifiers for features.
    /// In this case it's impossible to set a feature state for an individual feature.
    @_documentation(visibility: public)
    var id: FeaturesetFeatureId? { get }

    /// A featureset descriptor denoting a featureset this feature belongs to.
    @_documentation(visibility: public)
    var featureset: FeaturesetDescriptor<Self> { get }

    /// A feature state.
    ///
    /// This is a **snapshot** of the state that the feature had when it was interacted with.
    /// To update and read the original state, use ``MapboxMap/setFeatureState(_:state:callback:)`` and ``MapboxMap/getFeatureState(_:callback:)``.
    @_documentation(visibility: public)
    var state: State { get }

    /// A feature geometry.
    @_documentation(visibility: public)
    var geometry: Geometry { get }

    /// Feature JSON properties.
    @_documentation(visibility: public)
    var properties: JSONObject { get }

    /// Converts a generic feature to the typed one.
    ///
    /// - Parameters:
    ///    - from: A generic feature.
    @_documentation(visibility: public)
    init?(from: FeaturesetFeature)
}

/// A basic feature of a featureset.
///
/// The feature can be obtained in the interactions added to custom layers by using untyped featuresets, ``FeaturesetDescriptor-struct/layer(_:)`` or ``FeaturesetDescriptor-struct/featureset(_:importId:)`` descriptors:
/// ```swift
/// // SwiftUI
/// Map {
///   TapInteraction(.layer("my-custom-layer") { feature, context in
///     // Use feature here
///   })
/// }
///
/// // UIKit
/// mapView.mapboxMap.addInteraction(TapInteraction(.layer("my-custom-layer") { feature, context in
///     // Use feature here
/// })
/// ```
///
/// If you use Standard Style, you can use typed alternatives like ``StandardPoiFeature``, ``StandardPlaceLabelsFeature``, ``StandardBuildingsFeature``.
///
/// The featureset feature is different to the `Turf.Feature`. The latter represents any GeoJSON feature, while the former is a high level representation of features.
@_spi(Experimental)
@_documentation(visibility: public)
final public class FeaturesetFeature: FeaturesetFeatureType {
    public typealias State = JSONObject
    public typealias StateKey = String

    /// An identifier of the feature.
    ///
    /// The identifier can be `nil` if the underlying source doesn't have identifiers for features.
    /// In this case it's impossible to set a feature state for an individual feature.
    @_documentation(visibility: public)
    public let id: FeaturesetFeatureId?

    /// A featureset descriptor denoting a featureset this feature belongs to.
    @_documentation(visibility: public)
    public let featureset: FeaturesetDescriptor<FeaturesetFeature>

    /// A feature geometry.
    @_documentation(visibility: public)
    public var geometry: Geometry { geoJsonFeature.geometry! }

    /// Feature JSON properties.
    @_documentation(visibility: public)
    public var properties: JSONObject { geoJsonFeature.properties ?? [:] }

    /// A feature state.
    ///
    /// This is a **snapshot** of the state that the feature had when it was interacted with.
    /// To update and read the original state, use ``MapboxMap/setFeatureState(_:state:callback:)`` and ``MapboxMap/getFeatureState(_:callback:)``.
    @_documentation(visibility: public)
    public let state: JSONObject

    let geoJsonFeature: Feature

    /// Creates a feature.
    ///
    /// Most of the time you get the feature in an interaction callback. You can use this initializer for utility needs.
    /// - Parameters:
    ///   - id: An optional feature id.
    ///   - featureset: A featureset descriptor
    ///   - geoJsonFeature: An underlying feature.
    ///   - state: A snapshot of the feature state
    @_documentation(visibility: public)
    public init(
        id: FeaturesetFeatureId?,
        featureset: FeaturesetDescriptor<FeaturesetFeature>,
        geoJsonFeature: Feature,
        state: State
    ) {
        self.id = id
        self.featureset = featureset
        self.geoJsonFeature = geoJsonFeature
        self.state = state
    }

    /// Converts a generic feature to the typed one.
    ///
    /// - Parameters:
    ///    - other: A generic feature.
    @_documentation(visibility: public)
    public convenience required init?(from other: FeaturesetFeature) {
        self.init(id: other.id, featureset: other.featureset, geoJsonFeature: other.geoJsonFeature, state: other.state)
    }

    convenience init(queriedFeature: QueriedFeature, featureset: FeaturesetDescriptor<FeaturesetFeature>) {
        let state = (queriedFeature.state as? JSONObject.TurfRawValue).flatMap {
            JSONObject(turfRawValue: $0)
        } ?? [:]

        self.init(
            id: queriedFeature.featuresetFeatureId.map(FeaturesetFeatureId.init(core:)),
            featureset: featureset,
            geoJsonFeature: queriedFeature.feature,
            state: state)
    }
}

extension Result {
    func mapWithError<U>(transform: (Success) throws -> U) -> Result<U, any Error> {
        switch self {
        case .success(let value):
            do {
                return .success(try transform(value))
            } catch {
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
}

func decodeState<S: Codable>(json: JSONObject) throws -> S {
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    let json = try encoder.encode(json)
    return try decoder.decode(S.self, from: json)
}

func encodeState<S: Codable>(_ state: S) -> [String: Any]? {
    let encoder = DictionaryEncoder()
    return try? encoder.encode(state)
}

extension FeaturesetFeature {
    func typedState<S: Codable>(default: S) -> S {
        do {
            return try decodeState(json: state)
        } catch {
            return `default`
        }
    }
}
