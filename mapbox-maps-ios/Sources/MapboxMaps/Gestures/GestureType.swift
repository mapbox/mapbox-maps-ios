public enum GestureType: Hashable, CaseIterable {
    /// The pan gesture
    case pan

    /// The pinch gesture
    case pinch

    /// The pitch gesture
    case pitch

    /// The double tap to zoom in gesture
    case doubleTapToZoomIn

    /// The double touch to zoom out gesture
    case doubleTouchToZoomOut

    /// The quick zoom gesture
    case quickZoom

    /// The single tap gesture
    case singleTap
}
