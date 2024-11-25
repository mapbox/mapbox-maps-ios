/// Describes the reason for a cache clearing failure.
public enum ClearCacheError: Error, Equatable, Sendable, CoreErrorRepresentable {

    /// There was an issue accessing the database
    case database(String)

    /// There was an uncategorised error, check the associated message
    case other(String)

    init(coreError: MapboxCommon.CacheClearingError) {
        switch coreError.type {
        case .databaseError: self = .database(coreError.message)
        case .otherError: fallthrough
        @unknown default: self = .other(coreError.message)
        }
    }
}
