internal import MapboxCommon_Private

/// The name of a generic event that a ``TileStore`` may send.
///
/// - SeeAlso: ``TileStore/onEvent(_:)``
@_spi(Experimental)
public struct TileStoreEventName: RawRepresentable, Hashable, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Sent when a TileStore schema migration fails. The TileStore instance is still created.
    ///
    /// This event is sticky: if migration already failed during TileStore construction, an observer
    /// is notified immediately. The event's `text` is the failure reason and its `data` is the database path.
    ///
    /// This event typically triggers due to specific environment issues, such as a full device disk,
    /// restricted file permissions, or SQLite database corruption. This is primarily a diagnostic event;
    /// most applications do not need to take any direct action when this occurs.
    public static let metadataMigrationFailed = TileStoreEventName(rawValue: TileStoreEventNames.metadataMigrationFailed)
}
