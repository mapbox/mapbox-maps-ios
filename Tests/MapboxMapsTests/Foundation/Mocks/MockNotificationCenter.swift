import Foundation
@testable import MapboxMaps

final class MockNotificationCenter: NotificationCenterProtocol {
    struct AddObserverParams {
        let observer: Any
        let selector: Selector
        let name: NSNotification.Name?
        let object: Any?
    }
    let addObserverStub = Stub<AddObserverParams, Void>()
    func addObserver(_ observer: Any, selector aSelector: Selector, name aName: NSNotification.Name?, object anObject: Any?) {
        addObserverStub.call(with: AddObserverParams(observer: observer, selector: aSelector, name: aName, object: anObject))
    }

    func post(name aName: NSNotification.Name, object anObject: Any?) {
        let notificaton = Notification(name: aName, object: anObject, userInfo: nil)
        for invocation in addObserverStub.invocations where invocation.parameters.name == aName {
            (invocation.parameters.observer as? NSObjectProtocol)?.perform(invocation.parameters.selector,
                                                                           with: notificaton)
        }
    }

    struct RemoveObserverParams {
        let observer: Any
        let name: NSNotification.Name?
        let object: Any?
    }
    let removeObserverStub = Stub<RemoveObserverParams, Void>()
    func removeObserver(_ observer: Any) {
        removeObserverStub.call(with: RemoveObserverParams(observer: observer, name: nil, object: nil))
    }
    func removeObserver(_ observer: Any, name aName: NSNotification.Name?, object anObject: Any?) {
        removeObserverStub.call(with: RemoveObserverParams(observer: observer, name: aName, object: anObject))
    }
}
