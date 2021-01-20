import Foundation
import MapboxMapsOrnaments

/// Constants indicating the visibility of different map ornaments.
public enum LayoutVisibility: String, Equatable {
    /// A constant indicating that the ornament adapts to the current map state.
    case adaptive

    /// A constant indicating that the ornament is always hidden.
    case hidden

    /// A constant indicating that the ornament is always visible.
    case visible
}

extension LayoutVisibility {
    internal var ornamentVisibility: OrnamentVisibility {
        switch self {
        case .adaptive:
            return .adaptive
        case .hidden:
            return .hidden
        case .visible:
            return .visible
        }
    }
}
