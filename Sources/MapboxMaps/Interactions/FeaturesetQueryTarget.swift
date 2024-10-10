/// Defines the parameters for querying features from a Featureset with an optional filter and id.
@_spi(Experimental)
@_documentation(visibility: public)
public struct FeaturesetQueryTarget: Equatable {
    /// A `FeaturesetDescriptor` that specifies the featureset to be included in the query.
    @_documentation(visibility: public)
    public var featureset: FeaturesetDescriptor<FeaturesetFeature>

    /// An optional filter expression used to refine the query results based on conditions related to the specified featureset.
    @_documentation(visibility: public)
    public var filter: Exp?

    /// An optional unique identifier associated with the target.
    @_documentation(visibility: public)
    public let id: UInt64?

    /// Creates a target.
    public init<T>(featureset: FeaturesetDescriptor<T>, filter: Exp? = nil, id: UInt64? = nil) {
        self.featureset = featureset.converted()
        self.filter = filter
        self.id = id
    }
}

extension FeaturesetQueryTarget {
    init(core: CoreFeaturesetQueryTarget) {
        /// Core never returns the filter.
        self.init(
            featureset: FeaturesetDescriptor<FeaturesetFeature>(core: core.featureset),
            filter: nil,
            id: core.id?.uint64Value)
    }

    var core: CoreFeaturesetQueryTarget {
        CoreFeaturesetQueryTarget(featureset: featureset.core, filter: filter?.asCore, id: id?.NSNumber)
    }
}
