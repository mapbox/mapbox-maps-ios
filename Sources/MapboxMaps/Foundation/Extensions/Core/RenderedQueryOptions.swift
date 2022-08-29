import Foundation
@_implementationOnly import MapboxCommon_Private

extension RenderedQueryOptions {

    /// Initialize a set of options to optimize feature querying
    /// - Parameters:
    ///   - layerIds: List of layer identifiers to limit the feature query to
    ///   - filter: Filter to a type of feature with an expression
    public convenience init(layerIds: [String]?, filter: Expression?) {
        var filterJson: Any?
        if let filter = filter {
            do {
                filterJson = try filter.toJSON()
            } catch {
                Log.error(forMessage: "Filter expression could not be encoded", category: "RenderedQueryOptions")
            }
        }

        self.init(__layerIds: layerIds, filter: filterJson)
    }

    /// Filters the returned features with an ``Expression``.
    public var filter: Expression? {

        guard let filter = __filter else { return nil }

        var filterExp: Exp?
        do {
            let filterData = try JSONSerialization.data(withJSONObject: filter, options: [])
            filterExp = try JSONDecoder().decode(Expression.self, from: filterData)
        } catch {
            Log.error(forMessage: "Filter expression could not be decoded", category: "RenderedQueryOptions")
        }

        return filterExp
    }
}
