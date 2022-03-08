import Foundation

/// :nodoc:
/// Deprecated. This protocol will be removed from the public API in a future major version.
public protocol MapEventsObservable: AnyObject {
    @discardableResult
    func onEvery(_ eventType: MapEvents.EventKind, handler: @escaping (Event) -> Void) -> Cancelable

    @discardableResult
    func onNext(_ eventType: MapEvents.EventKind, handler: @escaping (Event) -> Void) -> Cancelable
}
