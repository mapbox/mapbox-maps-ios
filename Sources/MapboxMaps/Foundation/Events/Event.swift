import Foundation

public typealias Event = MapboxCoreMaps.Event

internal typealias EventAttributes = [String: Any]

internal enum EventType {
    case map(event: Maps)

    internal enum Maps {
        case loaded
    }
}

internal protocol EventsListener: AnyObject {
    func push(event: EventType)
}
