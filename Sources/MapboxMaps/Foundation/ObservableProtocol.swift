import Foundation
import MapboxCoreMaps

internal protocol ObservableProtocol: AnyObject {
    /// Subscribes an Observer to a provided list of event types.
    ///
    /// A type conforming to `ObservableProtocol` will hold a strong reference
    /// to an Observer instance, therefore, in order to stop receiving notifications,
    /// the caller must call `unsubscribe` with the instance used for an initial
    /// subscription.
    ///
    /// - Parameters:
    ///   - observer: An `Observer`
    ///   - events: Array of event types to be subscribed to
    ///
    /// - Note:
    ///     Prefer `MapboxMap.on()` and `Snapshotter.on()` to using these
    ///     lower-level APIs
    func subscribe(_ observer: Observer, events: [String])

    /// Unsubscribes an Observer from a provided list of event types.
    ///
    /// A type conforming to `ObservableProtocol` will hold a strong reference
    /// to an Observer instance, therefore, in order to stop receiving notifications,
    /// the caller must call `unsubscribe` with the instance used for an initial
    /// subscription.
    ///
    /// - Parameters:
    ///   - observer: An `Observer`
    ///   - events: Array of event types to be unsubscribed from. If you pass an
    ///     empty array (the default) the all events will be unsubscribed from.
    func unsubscribe(_ observer: Observer, events: [String])
}
