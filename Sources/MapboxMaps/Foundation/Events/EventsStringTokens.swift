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
