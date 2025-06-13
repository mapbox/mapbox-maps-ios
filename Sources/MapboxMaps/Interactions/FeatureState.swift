/// Sets the feature state to a feature in the SwiftUI  ``Map``.
public struct FeatureState<T: FeaturesetFeatureType>: Equatable, MapContent, PrimitiveMapContent {
    var featureset: FeaturesetDescriptor<T>
    var featureId: FeaturesetFeatureId?
    var state: T.State

    /// Sets the feature state using typed descriptor and feature id.
    ///
    /// - Parameters:
    ///   - featureset: A typed featureset descriptor.
    ///   - id: A feature identifier.
    ///   - state: A state to set.
    public init(_ featureset: FeaturesetDescriptor<T>, id: FeaturesetFeatureId, state: T.State) {
        self.featureset = featureset
        self.featureId = id
        self.state = state
    }

    /// Sets the feature state using the feature.
    ///
    /// The feature should have a valid ``FeaturesetFeatureType/id``. Otherwise this call is no-op.
    ///
    /// - Parameters:
    ///   - feature: A feature.
    ///   - state: A state instance.
    public init(_ feature: T, _ state: T.State) {
        self.featureset = feature.featureset
        self.featureId = feature.id
        self.state = state
    }

    func visit(_ node: MapContentNode) {
        node.mount(MountedFeatureState<T>(state: self))
    }
}
