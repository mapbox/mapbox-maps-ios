import Foundation

internal protocol NotificationCenterProtocol: AnyObject {
    func addObserver(_ observer: Any, selector aSelector: Selector, name aName: NSNotification.Name?, object anObject: Any?)

    func removeObserver(_ observer: Any)
    func removeObserver(_ observer: Any, name aName: NSNotification.Name?, object anObject: Any?)
}

extension NotificationCenter: NotificationCenterProtocol {}
