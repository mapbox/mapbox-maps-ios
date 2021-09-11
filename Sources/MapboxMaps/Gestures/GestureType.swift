import Foundation

public enum GestureType: Hashable {
    /// The pan gesture type
    case pan

    /// The tap gesture type
    case tap(numberOfTaps: Int, numberOfTouches: Int)

    /// The zoom gesture type
    case pinch

    /// The rotate gesture type
    case rotate

    /// The quick zoom gesture type
    case quickZoom

    /// The pitch gesture type
    case pitch

    // Generates a handler for every gesture type
    // swiftlint:disable explicit_acl
    func makeHandler(for view: UIView,
                     cameraAnimationsManager: CameraAnimationsManagerProtocol,
                     mapboxMap: MapboxMapProtocol,
                     delegate: GestureHandlerDelegate,
                     contextProvider: GestureContextProvider,
                     gestureOptions: GestureOptions) -> GestureHandler {
        switch self {
        case .pan:
            return PanGestureHandler(for: view, withDelegate: delegate, panScrollMode: gestureOptions.scrollingMode, mapboxMap: mapboxMap, cameraAnimationsManager: cameraAnimationsManager)
        case .tap(let numberOfTaps, let numberOfTouches):
            return TapGestureHandler(for: view,
                                     numberOfTapsRequired: numberOfTaps,
                                     numberOfTouchesRequired: numberOfTouches,
                                     withDelegate: delegate,
                                     cameraAnimationsManager: cameraAnimationsManager,
                                     mapboxMap: mapboxMap)
        case .pinch:
            return PinchGestureHandler(for: view, withDelegate: delegate, mapboxMap: mapboxMap)
        case .rotate:
            return RotateGestureHandler(for: view, withDelegate: delegate, andContextProvider: contextProvider, mapboxMap: mapboxMap)
        case .quickZoom:
            return QuickZoomGestureHandler(for: view, withDelegate: delegate, mapboxMap: mapboxMap)
        case .pitch:
            return PitchGestureHandler(for: view, withDelegate: delegate, mapboxMap: mapboxMap)
        }
    }

    // Provides understanding of equality between gesture types
    public static func == (lhs: GestureType, rhs: GestureType) -> Bool {
        switch (lhs, rhs) {
        // Compares two pan gesture types (always true)
        case (.pan, .pan):
            return true
        // Compares two tap gesture types with potentially different parameterized values
        case (let .tap(lhsNumberOfTaps, lhsNumberOfTouches), let .tap(rhsNumberOfTaps, rhsNumberOfTouches)):
            return lhsNumberOfTaps == rhsNumberOfTaps &&
                   lhsNumberOfTouches == rhsNumberOfTouches
        // Compares two pinch gesture types (always true)
        case (.pinch, .pinch):
            return true
        // Compares two rotate gesture types (always true)
        case (.rotate, .rotate):
            return true
        // Compares two long press gesture types (always true)
        case (.quickZoom, .quickZoom):
            return true
        case (.pitch, .pitch):
            return true
        default:
            return false
        }
    }

}
