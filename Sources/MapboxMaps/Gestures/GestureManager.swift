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
            panGestureHandler.multiFingerPanEnabled = newValue.pinchPanEnabled
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
            gestureOptions.pinchPanEnabled = panGestureHandler.multiFingerPanEnabled
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

    /// A stream of single tap events on the map.
    ///
    //// This event is called when the user taps the map and no annotations or layers handled the gesture.
    public var onMapTap: Signal<MapContentGestureContext> { mapContentGestureManager.onMapTap }

    /// A stream of long press events.
    ///
    /// This event is called when the user long-presses the map and no annotations or layers handled the gesture.
    public var onMapLongPress: Signal<MapContentGestureContext> { mapContentGestureManager.onMapLongPress }

    /// Adds a tap handler to the specified layer.
    ///
    /// The handler will be called in the event, starting with the topmost layer and propagating down to each layer under the tap in order.
    public func onLayerTap(_ layerId: String, handler: @escaping MapLayerGestureHandler) -> AnyCancelable {
        mapContentGestureManager.onLayerTap(layerId, handler: handler)
    }

    /// Adds a long press handler for the layer with `layerId`.
    ///
    /// The handler will be called in the event, starting with the topmost layer and propagating down to each layer under the tap in order.
    public func onLayerLongPress(_ layerId: String, handler: @escaping MapLayerGestureHandler) -> AnyCancelable {
        mapContentGestureManager.onLayerLongPress(layerId, handler: handler)
    }

    /// Set this delegate to be called back if a gesture begins
    public weak var delegate: GestureManagerDelegate?

    // Gesture handlers for SwiftUI
    var gestureHandlers = MapGestureHandlers()

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
    private let mapContentGestureManager: MapContentGestureManagerProtocol

    init(
        panGestureHandler: PanGestureHandlerProtocol,
        pinchGestureHandler: PinchGestureHandlerProtocol,
        rotateGestureHandler: RotateGestureHandlerProtocol,
        pitchGestureHandler: GestureHandler,
        doubleTapToZoomInGestureHandler: FocusableGestureHandlerProtocol,
        doubleTouchToZoomOutGestureHandler: FocusableGestureHandlerProtocol,
        quickZoomGestureHandler: FocusableGestureHandlerProtocol,
        singleTapGestureHandler: GestureHandler,
        anyTouchGestureHandler: GestureHandler,
        interruptDecelerationGestureHandler: GestureHandler,
        mapboxMap: MapboxMapProtocol,
        mapContentGestureManager: MapContentGestureManagerProtocol
    ) {
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
        self.mapContentGestureManager = mapContentGestureManager

        panGestureHandler.delegate = self
        pinchGestureHandler.delegate = self
        rotateGestureHandler.delegate = self
        pitchGestureHandler.delegate = self
        doubleTapToZoomInGestureHandler.delegate = self
        doubleTouchToZoomOutGestureHandler.delegate = self
        quickZoomGestureHandler.delegate = self
        singleTapGestureHandler.delegate = self

        panGestureHandler.gestureRecognizer.require(toFail: pitchGestureHandler.gestureRecognizer)
        quickZoomGestureHandler.gestureRecognizer.require(toFail: doubleTapToZoomInGestureHandler.gestureRecognizer)
        singleTapGestureHandler.gestureRecognizer.require(toFail: doubleTapToZoomInGestureHandler.gestureRecognizer)

        // Invoke the setter to ensure the defaults are synchronized
        self.options = GestureOptions()
    }

    func gestureBegan(for gestureType: GestureType) {
        OSLog.poi.signpostEvent("Gesture began", message: "type: \(gestureType)")

        if gestureType.isContinuous {
            mapboxMap.beginGesture()
        }
        delegate?.gestureManager(self, didBegin: gestureType)
        gestureHandlers.onBegin?(gestureType)
    }

    func gestureEnded(for gestureType: GestureType, willAnimate: Bool) {
        OSLog.poi.signpostEvent("Gesture ended", message: "type: \(gestureType)")

        if gestureType.isContinuous, !willAnimate {
            mapboxMap.endGesture()
        }
        delegate?.gestureManager(self, didEnd: gestureType, willAnimate: willAnimate)
        gestureHandlers.onEnd?(gestureType, willAnimate)
    }

    func animationEnded(for gestureType: GestureType) {
        if gestureType.isContinuous {
            mapboxMap.endGesture()
        }
        delegate?.gestureManager(self, didEndAnimatingFor: gestureType)
        gestureHandlers.onAnimationEnd?(gestureType)
    }
}

protocol GestureManagerProtocol: AnyObject {
    var gestureHandlers: MapGestureHandlers { get set }
    var options: GestureOptions { get set }
    var onMapTap: Signal<MapContentGestureContext> { get }
    var onMapLongPress: Signal<MapContentGestureContext> { get }
    func onLayerTap(_ layerId: String, handler: @escaping MapLayerGestureHandler) -> AnyCancelable
    func onLayerLongPress(_ layerId: String, handler: @escaping MapLayerGestureHandler) -> AnyCancelable
}

extension GestureManager: GestureManagerProtocol {}
