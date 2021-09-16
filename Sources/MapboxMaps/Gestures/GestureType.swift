import Foundation

public enum GestureType: Hashable, CaseIterable {
    /// The pan gesture
    case pan

    /// The double tap to zoom in gesture
    case doubleTapToZoomIn

    /// The double tap to zoom out gesture
    case doubleTapToZoomOut

    /// The pinch gesture
    case pinch

    /// The rotate gesture
    case rotate

    /// The quick zoom gesture
    case quickZoom

    /// The pitch gesture
    case pitch
}
