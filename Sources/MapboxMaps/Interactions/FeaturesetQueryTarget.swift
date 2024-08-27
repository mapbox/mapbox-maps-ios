/// Defines the parameters for querying features from a Featureset with an optional filter and id.
@_spi(Experimental)
@_documentation(visibility: public)
public struct FeaturesetQueryTarget: Equatable {
    /// A `FeaturesetDescriptor` that specifies the featureset to be included in the query.
    @_documentation(visibility: public)
    public var featureset: FeaturesetDescriptor

    /// An optional filter expression used to refine the query results based on conditions related to the specified featureset.
    @_documentation(visibility: public)
    public var filter: Exp?

    /// An optional unique identifier associated with the target.
    @_documentation(visibility: public)
    public let id: UInt64?

    /// Creates a target.
    public init(featureset: FeaturesetDescriptor, filter: Exp? = nil, id: UInt64? = nil) {
        self.featureset = featureset
        self.filter = filter
        self.id = id
    }
}

extension FeaturesetQueryTarget {
    init(core: CoreFeaturesetQueryTarget) {
        /// Core never returns the filter.
        self.init(featureset: core.featureset, filter: nil, id: nil)
    }

    var core: CoreFeaturesetQueryTarget {
        CoreFeaturesetQueryTarget(featureset: featureset, filter: filter?.asCore, id: id?.NSNumber)
    }
}
