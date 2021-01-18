import Foundation

/// Enum that provides options for positioning an ornament
public enum LayoutPosition: String, Equatable {
    case topLeft
    case topCenter
    case topRight
    case centerRight
    case bottomRight
    case bottomCenter
    case bottomLeft
    case centerLeft
}

extension LayoutPosition {
    internal var ornamentPosition: OrnamentPosition {
        switch self {
        case .topLeft:
            return .topLeft
        case .topCenter:
            return .topCenter
        case .topRight:
            return .topRight
        case .centerRight:
            return .centerRight
        case .bottomRight:
            return .bottomRight
        case .bottomCenter:
            return .bottomCenter
        case .bottomLeft:
            return .bottomLeft
        case .centerLeft:
            return .centerLeft
        }
    }
}
