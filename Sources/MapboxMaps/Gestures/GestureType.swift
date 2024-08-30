public enum GestureType: Hashable, CaseIterable, Sendable {
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

    /// The rotation gesture
    case rotation

    /// A continious gesture is a gesture that results in a series of camera update events spread over time.
    /// E.g.:
    /// * Pan gesture that issues a camera update event every time its recognizer detects change in translation.
    /// * Double tap to zoom in/out are also considered continious gestures,
    ///     even if they rely on a discreet gesture recognition(double tap).
    ///     However, the animation that is triggered by them unconditionally
    ///     will issue a series of camera updates that are considered to be part of the gesture.
    internal var isContinuous: Bool {
        switch self {
        case .pan, .pinch, .pitch, .doubleTapToZoomIn, .doubleTouchToZoomOut, .quickZoom, .rotation:
            return true
        case .singleTap:
            return false
        }
    }
}
