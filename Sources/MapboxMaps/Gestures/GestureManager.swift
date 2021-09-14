import UIKit
import CoreLocation

public protocol GestureManagerDelegate: AnyObject {

    /// Informs the delegate that a gesture haas begun. Could be used to cancel camera tracking.
    func gestureBegan(for gestureType: GestureType)
}

public final class GestureManager {

    /// The `GestureOptions` that are used to set up the required gestures on the map
    public var options: GestureOptions {
        set {
            panGestureRecognizer.isEnabled = newValue.scrollEnabled
            doubleTapToZoomOutGestureRecognizer.isEnabled = newValue.zoomEnabled
            doubleTapToZoomInGestureRecognizer.isEnabled = newValue.zoomEnabled
            pinchGestureRecognizer.isEnabled = newValue.scrollEnabled && newValue.zoomEnabled
            rotationGestureRecognizer.isEnabled = newValue.rotateEnabled
            quickZoomGestureRecognizer.isEnabled = newValue.zoomEnabled
            pitchGestureRecognizer.isEnabled = newValue.pitchEnabled
            panGestureHandler.panScrollingMode = newValue.scrollingMode
            panGestureHandler.decelerationRate = newValue.decelerationRate
        }
        get {
            var gestureOptions = GestureOptions()
            gestureOptions.scrollEnabled = panGestureRecognizer.isEnabled
                || pinchGestureRecognizer.isEnabled
            gestureOptions.rotateEnabled = rotationGestureRecognizer.isEnabled
            gestureOptions.zoomEnabled = quickZoomGestureRecognizer.isEnabled
                || pinchGestureRecognizer.isEnabled
                || doubleTapToZoomInGestureRecognizer.isEnabled
                || doubleTapToZoomOutGestureRecognizer.isEnabled
            gestureOptions.pitchEnabled = pitchGestureRecognizer.isEnabled
            gestureOptions.scrollingMode = panGestureHandler.panScrollingMode
            gestureOptions.decelerationRate = panGestureHandler.decelerationRate
            return gestureOptions
        }
    }

    private let panGestureHandler: PanGestureHandler

    /// The gesture recognizer for the pan gesture
    public var panGestureRecognizer: UIGestureRecognizer {
        return panGestureHandler.gestureRecognizer
    }

    private let doubleTapToZoomInGestureHandler: TapGestureHandler

    /// The gesture recognizer for the "double tap to zoom in" gesture
    public var doubleTapToZoomInGestureRecognizer: UIGestureRecognizer {
        return doubleTapToZoomInGestureHandler.gestureRecognizer
    }

    private let doubleTapToZoomOutGestureHandler: TapGestureHandler

    /// The gesture recognizer for the "double tap to zoom out" gesture
    public var doubleTapToZoomOutGestureRecognizer: UIGestureRecognizer {
        return doubleTapToZoomOutGestureHandler.gestureRecognizer
    }

    private let quickZoomGestureHandler: QuickZoomGestureHandler

    /// The gesture recognizer for the quickZoom gesture
    public var quickZoomGestureRecognizer: UIGestureRecognizer {
        return quickZoomGestureHandler.gestureRecognizer
    }

    private let pitchGestureHandler: PitchGestureHandler

    /// The gesture recognizer for the pitch gesture
    public var pitchGestureRecognizer: UIGestureRecognizer {
        return pitchGestureHandler.gestureRecognizer
    }

    private let rotationGestureHandler: RotateGestureHandler

    /// The gesture recognizer for the rotate gesture
    public var rotationGestureRecognizer: UIGestureRecognizer {
        return rotationGestureHandler.gestureRecognizer
    }

    private let pinchGestureHandler: PinchGestureHandler

    /// The gesture recognizer for the "pinch to zoom" gesture
    public var pinchGestureRecognizer: UIGestureRecognizer {
        return pinchGestureHandler.gestureRecognizer
    }

    /// Set this delegate to be called back if a gesture begins
    public weak var delegate: GestureManagerDelegate?

    internal init(view: UIView,
                  mapboxMap: MapboxMapProtocol,
                  cameraAnimationsManager: CameraAnimationsManagerProtocol) {
        self.panGestureHandler = PanGestureHandler(
            decelerationRate: UIScrollView.DecelerationRate.normal.rawValue,
            panScrollingMode: .horizontalAndVertical,
            view: view,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
        self.doubleTapToZoomInGestureHandler = TapGestureHandler(
            numberOfTouchesRequired: 1,
            view: view,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
        self.doubleTapToZoomOutGestureHandler = TapGestureHandler(
            numberOfTouchesRequired: 2,
            view: view,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
        self.pinchGestureHandler = PinchGestureHandler(
            view: view,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
        self.rotationGestureHandler = RotateGestureHandler(
            view: view,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
        self.quickZoomGestureHandler = QuickZoomGestureHandler(
            view: view,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
        self.pitchGestureHandler = PitchGestureHandler(
            view: view,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)

        pitchGestureHandler.gestureRecognizer.require(toFail: panGestureHandler.gestureRecognizer)
        quickZoomGestureHandler.gestureRecognizer.require(toFail: doubleTapToZoomOutGestureHandler.gestureRecognizer)
    }
}

extension GestureManager: GestureHandlerDelegate {
    func gestureBegan(for gestureType: GestureType) {
        delegate?.gestureBegan(for: gestureType)
    }
}
