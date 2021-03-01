import Foundation
import MapboxMobileEvents

extension EventType.Maps {
    var typeString: String {
        switch self {
        case .loaded:
            return MMEEventTypeMapLoad
        }
    }
}

extension EventType.Metrics {
    var typeString: String {
        switch self {
        case .performance:
            return "mobile.performance_trace"
        }
    }
}

extension EventType.OfflineStorage {
    var typeString: String {
        switch self {
        case .downloadStarted:
            return MMEventTypeOfflineDownloadStart
        }
    }
}
