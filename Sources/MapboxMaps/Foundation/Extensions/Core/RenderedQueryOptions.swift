import Foundation
@_implementationOnly import MapboxCommon_Private

extension RenderedQueryOptions {

    /// Initialize a set of options to optimize feature querying
    /// - Parameters:
    ///   - layerIds: List of layer identifiers to limit the feature query to
    ///   - filter: Filter to a type of feature with an expression
    public convenience init(layerIds: [String]?, filter: Exp?) {
        var filterJson: Any?
        if let filter = filter {
            do {
                filterJson = try filter.toJSON()
            } catch {
                Log.error("Filter expression could not be encoded", category: "RenderedQueryOptions")
            }
        }

        self.init(__layerIds: layerIds, filter: filterJson)
    }

    /// Filters the returned features with an ``Exp``.
    public var filter: Exp? {

        guard let filter = __filter else { return nil }

        var filterExp: Exp?
        do {
            let filterData = try JSONSerialization.data(withJSONObject: filter, options: [])
            filterExp = try JSONDecoder().decode(Exp.self, from: filterData)
        } catch {
            Log.error("Filter expression could not be decoded", category: "RenderedQueryOptions")
        }

        return filterExp
    }
}
