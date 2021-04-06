import Foundation

internal typealias EventAttributes = [String: Any]

public enum EventType {
    case custom(name: String)
    case map(event: Maps)
    case metrics(event: Metrics)
    case snapshot(event: Snapshot)
    case offlineStorage(event: OfflineStorage)
    case memoryWarning

    public enum Maps {
        case loaded
    }

    public enum Metrics {
        case performance(metrics: [String: Any])
    }

    public enum Snapshot {
        case initialized
    }

    public enum OfflineStorage {
        case downloadStarted(attributes: [String: Any])
    }
}

internal protocol EventsListener: AnyObject {
    func push(event: EventType)
}
