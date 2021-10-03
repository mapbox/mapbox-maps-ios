import Foundation
import MapboxCoreMaps

internal protocol ObservableProtocol: AnyObject {
    func subscribe(_ observer: Observer, events: [String])

    func unsubscribe(_ observer: Observer, events: [String])
}
