import Foundation
import Turf

/// An interactive feature.
///
/// The interactive feature is in the interactions  handlers, see more in ``TapInteraction`` and ``LongPressInteraction``.
///
/// The interactive feature is different from `Turf.Feature` as it contains more context about the featureset
/// and provides easier access to the feature properties.
@_spi(Experimental)
@_documentation(visibility: public)
public class InteractiveFeature {
    /// An id of the feature
    ///
    /// The id can be empty if the underlying source don't have identifiers for features.
    /// If there's no id, it's impossible to set a feature state for an individual feature.
    @_documentation(visibility: public)
    public let id: FeaturesetFeatureId?

    /// A featureset descriptor denoting a featureset this feature belongs to.
    @_documentation(visibility: public)
    public let featureset: FeaturesetDescriptor

    /// Feature state.
    ///
    /// This is a snapshot of the state that the feature had when it was interacted.
    /// If you call ``MapboxMap/setFeatureState(feature:state:callback:)`` it won't be immediately reflected in this property.
    @_documentation(visibility: public)
    public let state: JSONObject?

    /// A feature geometry.
    @_documentation(visibility: public)
    public var geometry: Geometry { originalFeature.geometry! }

    /// Feature properties.
    @_documentation(visibility: public)
    public var properties: JSONObject? { originalFeature.properties }

    let originalFeature: Feature

    convenience init?(queriedFeature: QueriedFeature?, featureset: FeaturesetDescriptor) {
        guard let queriedFeature else {
            return nil
        }

        let state = (queriedFeature.state as? JSONObject.TurfRawValue).flatMap {
            JSONObject(turfRawValue: $0)
        }
        self.init(id: queriedFeature.featuresetFeatureId.map(FeaturesetFeatureId.init(core:)),
                  featureset: featureset, feature: queriedFeature.feature, state: state)
    }

    /// Creates a feature.
    ///
    /// Most of the time you get the feature in an interaction callback. You can use this initializer for utility needs.
    /// - Parameters:
    ///   - id: An optional feature id.
    ///   - featureset: A featureset descriptor
    ///   - state: An underlying feature.
    ///   - state: A snapshot of the feature state
    public init?(
        id: FeaturesetFeatureId?,
        featureset: FeaturesetDescriptor,
        feature: Feature,
        state: JSONObject?
    ) {
        if feature.geometry == nil {
            return nil
        }
        self.id = id
        self.originalFeature = feature
        self.featureset = featureset
        self.state = state
    }
}
