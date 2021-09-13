import Foundation

public enum GestureType: Hashable {
    /// The pan gesture type
    case pan

    /// The tap gesture type
    case tap(numberOfTouches: Int)

    /// The zoom gesture type
    case pinch

    /// The rotate gesture type
    case rotate

    /// The quick zoom gesture type
    case quickZoom

    /// The pitch gesture type
    case pitch
}
