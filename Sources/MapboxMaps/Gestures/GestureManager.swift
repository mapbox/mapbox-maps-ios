import UIKit

public protocol GestureManagerDelegate: AnyObject {

    /// Informs the delegate that a gesture has begun.
    func gestureManager(_ gestureManager: GestureManager, didBegin gestureType: GestureType)

    /// Informs the delegate that a gesture has ended and whether there will be additional animations after the gesture
    /// has completed. Does not indicate whether gesture-based animations have completed.
    func gestureManager(_ gestureManager: GestureManager, didEnd gestureType: GestureType, willAnimate: Bool)

    /// Informs the delegate that animations triggered due to a gesture have ended.
    func gestureManager(_ gestureManager: GestureManager, didEndAnimatingFor gestureType: GestureType)
}

public final class GestureManager: GestureHandlerDelegate {

    /// Configuration options for the built-in gestures
    public var options: GestureOptions {
        set {
            panGestureRecognizer.isEnabled = newValue.panEnabled
            pinchGestureRecognizer.isEnabled = newValue.pinchEnabled
            pinchGestureHandler.rotateEnabled = newValue.pinchRotateEnabled
            pinchGestureHandler.zoomEnabled = newValue.pinchZoomEnabled
            pinchGestureHandler.panEnabled = newValue.pinchPanEnabled
            pitchGestureRecognizer.isEnabled = newValue.pitchEnabled
            doubleTapToZoomInGestureRecognizer.isEnabled = newValue.doubleTapToZoomInEnabled
            doubleTouchToZoomOutGestureRecognizer.isEnabled = newValue.doubleTouchToZoomOutEnabled
            quickZoomGestureRecognizer.isEnabled = newValue.quickZoomEnabled
            panGestureHandler.panMode = newValue.panMode
            panGestureHandler.decelerationFactor = newValue.panDecelerationFactor
            doubleTapToZoomInGestureHandler.focalPoint = newValue.focalPoint
            doubleTouchToZoomOutGestureHandler.focalPoint = newValue.focalPoint
            quickZoomGestureHandler.focalPoint = newValue.focalPoint
            pinchGestureHandler.focalPoint = newValue.focalPoint
        }
        get {
            var gestureOptions = GestureOptions()
            gestureOptions.panEnabled = panGestureRecognizer.isEnabled
            gestureOptions.pinchEnabled = pinchGestureRecognizer.isEnabled
            gestureOptions.pinchRotateEnabled = pinchGestureHandler.rotateEnabled
            gestureOptions.pinchZoomEnabled = pinchGestureHandler.zoomEnabled
            gestureOptions.pinchPanEnabled = pinchGestureHandler.panEnabled
            gestureOptions.pitchEnabled = pitchGestureRecognizer.isEnabled
            gestureOptions.doubleTapToZoomInEnabled = doubleTapToZoomInGestureRecognizer.isEnabled
            gestureOptions.doubleTouchToZoomOutEnabled = doubleTouchToZoomOutGestureRecognizer.isEnabled
            gestureOptions.quickZoomEnabled = quickZoomGestureRecognizer.isEnabled
            gestureOptions.panMode = panGestureHandler.panMode
            gestureOptions.panDecelerationFactor = panGestureHandler.decelerationFactor
            gestureOptions.focalPoint = doubleTapToZoomInGestureHandler.focalPoint
            return gestureOptions
        }
    }

    /// The gesture recognizer for the pan gesture
    public var panGestureRecognizer: UIGestureRecognizer {
        return panGestureHandler.gestureRecognizer
    }

    /// The gesture recognizer for the "pinch to zoom" gesture
    public var pinchGestureRecognizer: UIGestureRecognizer {
        return pinchGestureHandler.gestureRecognizer
    }

    /// The gesture recognizer for the pitch gesture
    public var pitchGestureRecognizer: UIGestureRecognizer {
        return pitchGestureHandler.gestureRecognizer
    }

    /// The gesture recognizer for the "double tap to zoom in" gesture
    public var doubleTapToZoomInGestureRecognizer: UIGestureRecognizer {
        return doubleTapToZoomInGestureHandler.gestureRecognizer
    }

    /// The gesture recognizer for the "double touch to zoom out" gesture
    public var doubleTouchToZoomOutGestureRecognizer: UIGestureRecognizer {
        return doubleTouchToZoomOutGestureHandler.gestureRecognizer
    }

    /// The gesture recognizer for the quickZoom gesture
    public var quickZoomGestureRecognizer: UIGestureRecognizer {
        return quickZoomGestureHandler.gestureRecognizer
    }

    /// The gesture recognizer for the single tap gesture
    /// - NOTE: The single tap gesture recognizer is primarily used to route tap events to the
    ///         `*AnnotationManager`s. You can add a target-action pair to this gesture recognizer
    ///         to be notified when a single tap occurs on the map.
    public var singleTapGestureRecognizer: UIGestureRecognizer {
        return singleTapGestureHandler.gestureRecognizer
    }

    internal var anyTouchGestureRecognizer: UIGestureRecognizer {
        return anyTouchGestureHandler.gestureRecognizer
    }

    /// Set this delegate to be called back if a gesture begins
    public weak var delegate: GestureManagerDelegate?

    private let panGestureHandler: PanGestureHandlerProtocol
    private let pinchGestureHandler: PinchGestureHandlerProtocol
    private let pitchGestureHandler: GestureHandler
    private let doubleTapToZoomInGestureHandler: FocusableGestureHandlerProtocol
    private let doubleTouchToZoomOutGestureHandler: FocusableGestureHandlerProtocol
    private let quickZoomGestureHandler: FocusableGestureHandlerProtocol
    private let singleTapGestureHandler: GestureHandler
    private let anyTouchGestureHandler: GestureHandler
    private let mapboxMap: MapboxMapProtocol

    internal init(panGestureHandler: PanGestureHandlerProtocol,
                  pinchGestureHandler: PinchGestureHandlerProtocol,
                  pitchGestureHandler: GestureHandler,
                  doubleTapToZoomInGestureHandler: FocusableGestureHandlerProtocol,
                  doubleTouchToZoomOutGestureHandler: FocusableGestureHandlerProtocol,
                  quickZoomGestureHandler: FocusableGestureHandlerProtocol,
                  singleTapGestureHandler: GestureHandler,
                  anyTouchGestureHandler: GestureHandler,
                  mapboxMap: MapboxMapProtocol) {
        self.panGestureHandler = panGestureHandler
        self.pinchGestureHandler = pinchGestureHandler
        self.pitchGestureHandler = pitchGestureHandler
        self.doubleTapToZoomInGestureHandler = doubleTapToZoomInGestureHandler
        self.doubleTouchToZoomOutGestureHandler = doubleTouchToZoomOutGestureHandler
        self.quickZoomGestureHandler = quickZoomGestureHandler
        self.singleTapGestureHandler = singleTapGestureHandler
        self.anyTouchGestureHandler = anyTouchGestureHandler
        self.mapboxMap = mapboxMap

        panGestureHandler.delegate = self
        pinchGestureHandler.delegate = self
        pitchGestureHandler.delegate = self
        doubleTapToZoomInGestureHandler.delegate = self
        doubleTouchToZoomOutGestureHandler.delegate = self
        quickZoomGestureHandler.delegate = self
        singleTapGestureHandler.delegate = self

        pinchGestureHandler.gestureRecognizer.require(toFail: panGestureHandler.gestureRecognizer)
        pitchGestureHandler.gestureRecognizer.require(toFail: panGestureHandler.gestureRecognizer)
        quickZoomGestureHandler.gestureRecognizer.require(toFail: doubleTapToZoomInGestureHandler.gestureRecognizer)
        singleTapGestureHandler.gestureRecognizer.require(toFail: doubleTapToZoomInGestureHandler.gestureRecognizer)

        // Invoke the setter to ensure the defaults are synchronized
        self.options = GestureOptions()
    }

    internal func gestureBegan(for gestureType: GestureType) {
        mapboxMap.beginGesture()
        delegate?.gestureManager(self, didBegin: gestureType)
    }

    internal func gestureEnded(for gestureType: GestureType, willAnimate: Bool) {
        mapboxMap.endGesture()
        delegate?.gestureManager(self, didEnd: gestureType, willAnimate: willAnimate)
    }

    internal func animationEnded(for gestureType: GestureType) {
        delegate?.gestureManager(self, didEndAnimatingFor: gestureType)
    }
}
