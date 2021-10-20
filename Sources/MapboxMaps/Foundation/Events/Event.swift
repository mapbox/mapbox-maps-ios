import Foundation

public typealias Event = MapboxCoreMaps.Event

internal typealias EventAttributes = [String: Any]

internal enum EventType {
    case custom(name: String)
    case map(event: Maps)
    case metrics(event: Metrics)
    case snapshot(event: Snapshot)
    case offlineStorage(event: OfflineStorage)

    internal enum Maps {
        case loaded
    }

    internal enum Metrics {
        case performance(metrics: [String: Any])
    }

    internal enum Snapshot {
        case initialized
    }

    internal enum OfflineStorage {
        case downloadStarted(attributes: [String: Any])
    }
}

internal protocol EventsListener: AnyObject {
    func push(event: EventType)
}
