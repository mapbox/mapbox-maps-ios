import Foundation

/// :nodoc:
/// Deprecated. This protocol will be removed from the public API in a future major version.
public protocol MapEventsObservable: AnyObject {
    @available(*, deprecated, renamed: "onTypedEvery(_:handler:)")
    @discardableResult
    func onEvery(_ eventType: MapEvents.EventKind, handler: @escaping (Event) -> Void) -> Cancelable

    @available(*, deprecated, renamed: "onTypedNext(_:handler:)")
    @discardableResult
    func onNext(_ eventType: MapEvents.EventKind, handler: @escaping (Event) -> Void) -> Cancelable

    @discardableResult
    func onTypedNext<Payload: Decodable>(_ eventType: MapEvents.Event<Payload>, handler: @escaping (TypedEvent<Payload>) -> Void) -> Cancelable
    @discardableResult
    func onTypedEvery<Payload: Decodable>(_ eventType: MapEvents.Event<Payload>, handler: @escaping (TypedEvent<Payload>) -> Void) -> Cancelable
}
