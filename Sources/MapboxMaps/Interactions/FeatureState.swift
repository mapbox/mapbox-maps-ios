/// Sets the feature state to a feature in the SwiftUI context.
///
/// The feature is identified by two parameters:
///  - The ``FeaturesetDescriptor`` denotes the featureset the feature belongs to.
///  - The ``FeaturesetFeatureId`` identifies the feature inside of the featureset.
@_spi(Experimental)
@_documentation(visibility: public)
@available(iOS 13.0, *)
public struct FeatureState: Equatable, MapContent, PrimitiveMapContent {
    var featureset: FeaturesetDescriptor
    var featureId: FeaturesetFeatureId?
    var state: JSONObject

    /// Sets the feature state.
    ///
    /// - Parameters:
    ///   - featureset: A featureset descriptor of the feature
    ///   - id: A feature identifier
    ///   - state: A state to set.
    @_documentation(visibility: public)
    public init(_ featureset: FeaturesetDescriptor, id: FeaturesetFeatureId, state: JSONObject) {
        self.featureset = featureset
        self.state = state
        self.featureId = id
    }

    /// A convenience initializer that users the whole interactive feature.
    ///
    /// - Parameters:
    ///   - feature: A feature to set state to.
    ///   - state: A state to set.
    @_documentation(visibility: public)
    public init(_ feature: InteractiveFeature, state: JSONObject) {
        self.featureset = feature.featureset
        self.featureId = feature.id
        self.state = state
    }

    func visit(_ node: MapContentNode) {
        node.mount(MountedFeatureState(state: self))
    }
}
