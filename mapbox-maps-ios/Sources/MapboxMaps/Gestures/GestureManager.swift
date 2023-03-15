import UIKit
import os

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
            rotateGestureRecognizer.isEnabled = newValue.rotateEnabled
            pinchGestureHandler.zoomEnabled = newValue.pinchZoomEnabled
            pinchGestureHandler.panEnabled = newValue.pinchPanEnabled
            pinchGestureHandler.simultaneousRotateAndPinchZoomEnabled = newValue.simultaneousRotateAndPinchZoomEnabled
            rotateGestureHandler.simultaneousRotateAndPinchZoomEnabled = newValue.simultaneousRotateAndPinchZoomEnabled
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
            rotateGestureHandler.focalPoint = newValue.focalPoint
        }
        get {
            var gestureOptions = GestureOptions()
            gestureOptions.panEnabled = panGestureRecognizer.isEnabled
            gestureOptions.pinchEnabled = pinchGestureRecognizer.isEnabled
            gestureOptions.rotateEnabled = rotateGestureRecognizer.isEnabled
            gestureOptions.pinchZoomEnabled = pinchGestureHandler.zoomEnabled
            gestureOptions.pinchPanEnabled = pinchGestureHandler.panEnabled
            gestureOptions.simultaneousRotateAndPinchZoomEnabled = pinchGestureHandler.simultaneousRotateAndPinchZoomEnabled
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

    /// The gesture recognizer for the rotate gesture
    public var rotateGestureRecognizer: UIGestureRecognizer {
        return rotateGestureHandler.gestureRecognizer
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
    private let rotateGestureHandler: RotateGestureHandlerProtocol
    private let pitchGestureHandler: GestureHandler
    private let doubleTapToZoomInGestureHandler: FocusableGestureHandlerProtocol
    private let doubleTouchToZoomOutGestureHandler: FocusableGestureHandlerProtocol
    private let quickZoomGestureHandler: FocusableGestureHandlerProtocol
    private let singleTapGestureHandler: GestureHandler
    private let anyTouchGestureHandler: GestureHandler
    private let interruptDecelerationGestureHandler: GestureHandler
    private let mapboxMap: MapboxMapProtocol

    internal init(panGestureHandler: PanGestureHandlerProtocol,
                  pinchGestureHandler: PinchGestureHandlerProtocol,
                  rotateGestureHandler: RotateGestureHandlerProtocol,
                  pitchGestureHandler: GestureHandler,
                  doubleTapToZoomInGestureHandler: FocusableGestureHandlerProtocol,
                  doubleTouchToZoomOutGestureHandler: FocusableGestureHandlerProtocol,
                  quickZoomGestureHandler: FocusableGestureHandlerProtocol,
                  singleTapGestureHandler: GestureHandler,
                  anyTouchGestureHandler: GestureHandler,
                  interruptDecelerationGestureHandler: GestureHandler,
                  mapboxMap: MapboxMapProtocol) {
        self.panGestureHandler = panGestureHandler
        self.pinchGestureHandler = pinchGestureHandler
        self.pitchGestureHandler = pitchGestureHandler
        self.doubleTapToZoomInGestureHandler = doubleTapToZoomInGestureHandler
        self.doubleTouchToZoomOutGestureHandler = doubleTouchToZoomOutGestureHandler
        self.quickZoomGestureHandler = quickZoomGestureHandler
        self.singleTapGestureHandler = singleTapGestureHandler
        self.anyTouchGestureHandler = anyTouchGestureHandler
        self.rotateGestureHandler = rotateGestureHandler
        self.interruptDecelerationGestureHandler = interruptDecelerationGestureHandler
        self.mapboxMap = mapboxMap

        panGestureHandler.delegate = self
        pinchGestureHandler.delegate = self
        rotateGestureHandler.delegate = self
        pitchGestureHandler.delegate = self
        doubleTapToZoomInGestureHandler.delegate = self
        doubleTouchToZoomOutGestureHandler.delegate = self
        quickZoomGestureHandler.delegate = self
        singleTapGestureHandler.delegate = self

        pitchGestureHandler.gestureRecognizer.require(toFail: panGestureHandler.gestureRecognizer)
        quickZoomGestureHandler.gestureRecognizer.require(toFail: doubleTapToZoomInGestureHandler.gestureRecognizer)
        singleTapGestureHandler.gestureRecognizer.require(toFail: doubleTapToZoomInGestureHandler.gestureRecognizer)

        // Invoke the setter to ensure the defaults are synchronized
        self.options = GestureOptions()
    }

    private var pinchBeganCallCount = 0

    internal func gestureBegan(for gestureType: GestureType) {
        // filter out duplicate pinch events coming from pinch and rotate handlers
        // TODO: Remove this once GestureType.rotate is added
        if gestureType == .pinch {
            pinchBeganCallCount += 1

            guard pinchBeganCallCount == 1 else {
                return
            }
        }

        OSLog.poi.signpostEvent("Gesture began", message: "type: \(gestureType)")
        mapboxMap.beginGesture()
        delegate?.gestureManager(self, didBegin: gestureType)
    }

    internal func gestureEnded(for gestureType: GestureType, willAnimate: Bool) {
        // filter out duplicate pinch events coming from pinch and rotate handlers
        // TODO: Remove this once GestureType.rotate is added
        if gestureType == .pinch {
            assert(pinchBeganCallCount > 0)
            pinchBeganCallCount -= 1

            guard pinchBeganCallCount == 0 else {
                return
            }
        }

        OSLog.poi.signpostEvent("Gesture ended", message: "type: \(gestureType)")
        mapboxMap.endGesture()
        delegate?.gestureManager(self, didEnd: gestureType, willAnimate: willAnimate)
    }

    internal func animationEnded(for gestureType: GestureType) {
        delegate?.gestureManager(self, didEndAnimatingFor: gestureType)
    }
}
