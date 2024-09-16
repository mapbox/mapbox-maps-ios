import Turf

/// Identifies a feature in a featureset.
///
/// Knowing the feature identifier allows to set the feature states to a particular feature, see ``MapboxMap/setFeatureState(featureset:featureId:state:callback:)``.
///
/// In a featureset a feature can come from different underlying sources. In that case their IDs are not guaranteed to be unique in the featureset.
/// The ``FeaturesetFeatureId/namespace`` is used to disambiguate from which source the feature is coming.
///
/// - Warning: There is no guarantee of identifier persistency. This depends on the underlying source of the features and may vary from style to style.
/// If you want to store the identifiers persistently, please make sure that the style or source provides this guarantee.
@_spi(Experimental)
@_documentation(visibility: public)
public struct FeaturesetFeatureId: Hashable {
    /// A feature id coming from the feature itself.
    @_documentation(visibility: public)
    public let id: String

    /// A namespace of the feature
    @_documentation(visibility: public)
    public let namespace: String?

    /// Creates an identifier.
    @_documentation(visibility: public)
    public init(id: String, namespace: String? = nil) {
        self.id = id
        self.namespace = namespace
    }

    var core: CoreFeaturesetFeatureId {
        CoreFeaturesetFeatureId(featureId: id, featureNamespace: namespace)
    }

    init(core: CoreFeaturesetFeatureId) {
        self.init(id: core.featureId, namespace: core.featureNamespace)
    }
}
