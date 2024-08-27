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

    /// The gesture recognizer for the single tap gesture.
    ///
    /// - Note: This gesture recognizer is used to route tap gestures into ``Interaction``s and Annotations. To add your handlers use ``TapInteraction`` API or `Annotation.onTapGesture` callback.
    public var singleTapGestureRecognizer: UIGestureRecognizer {
        return singleTapGestureHandler.gestureRecognizer
    }

    /// The gesture recognizer for the long press gesture.
    ///
    /// - Note: This gesture recognizer is used to route long press gestures into ``Interaction``s and Annotations. To add your handlers use ``TapInteraction`` API or `Annotation.onLongPress` callback.
    public var longPressGestureRecognizer: UIGestureRecognizer {
        return longPressGestureHandler.gestureRecognizer
    }

    internal var anyTouchGestureRecognizer: UIGestureRecognizer {
        return anyTouchGestureHandler.gestureRecognizer
    }

    /// A stream of single tap events on the map.
    ///
    /// This event is called when the user taps the map and no interactions, annotations or layers handled the gesture.
    public var onMapTap: Signal<InteractionContext> { mapTap.signal }

    /// A stream of long press events.
    ///
    /// This event is called when the user long-presses the map and no annotations or layers handled the gesture.
    public var onMapLongPress: Signal<InteractionContext> { mapLongPress.signal }

    /// Adds a tap handler to the specified layer.
    ///
    /// The handler will be called in the event, starting with the topmost layer and propagating down to each layer under the tap in order.
    public func onLayerTap(_ layerId: String, handler: @escaping MapLayerGestureHandler) -> AnyCancelable {
        mapboxMap.addInteraction(CoreInteraction(layerId: layerId, type: .click, handler: handler)).erased
    }

    /// Adds a long press handler for the layer with `layerId`.
    ///
    /// The handler will be called in the event, starting with the topmost layer and propagating down to each layer under the tap in order.
    public func onLayerLongPress(_ layerId: String, handler: @escaping MapLayerGestureHandler) -> AnyCancelable {
        mapboxMap.addInteraction(CoreInteraction(layerId: layerId, type: .longClick, handler: handler)).erased
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
    private let longPressGestureHandler: GestureHandler
    private let anyTouchGestureHandler: GestureHandler
    private let interruptDecelerationGestureHandler: GestureHandler
    private let mapboxMap: MapboxMapProtocol

    private let mapTap = SignalSubject<InteractionContext>()
    private let mapLongPress = SignalSubject<InteractionContext>()

    init(
        panGestureHandler: PanGestureHandlerProtocol,
        pinchGestureHandler: PinchGestureHandlerProtocol,
        rotateGestureHandler: RotateGestureHandlerProtocol,
        pitchGestureHandler: GestureHandler,
        doubleTapToZoomInGestureHandler: FocusableGestureHandlerProtocol,
        doubleTouchToZoomOutGestureHandler: FocusableGestureHandlerProtocol,
        quickZoomGestureHandler: FocusableGestureHandlerProtocol,
        singleTapGestureHandler: GestureHandler,
        longPressGestureHandler: GestureHandler,
        anyTouchGestureHandler: GestureHandler,
        interruptDecelerationGestureHandler: GestureHandler,
        mapboxMap: MapboxMapProtocol
    ) {
        self.panGestureHandler = panGestureHandler
        self.pinchGestureHandler = pinchGestureHandler
        self.pitchGestureHandler = pitchGestureHandler
        self.doubleTapToZoomInGestureHandler = doubleTapToZoomInGestureHandler
        self.doubleTouchToZoomOutGestureHandler = doubleTouchToZoomOutGestureHandler
        self.quickZoomGestureHandler = quickZoomGestureHandler
        self.singleTapGestureHandler = singleTapGestureHandler
        self.longPressGestureHandler = longPressGestureHandler
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

        panGestureHandler.gestureRecognizer.require(toFail: pitchGestureHandler.gestureRecognizer)
        quickZoomGestureHandler.gestureRecognizer.require(toFail: doubleTapToZoomInGestureHandler.gestureRecognizer)
        singleTapGestureHandler.gestureRecognizer.require(toFail: doubleTapToZoomInGestureHandler.gestureRecognizer)

        // Invoke the setter to ensure the defaults are synchronized
        self.options = GestureOptions()

        // Add default tap and long-press interactions for API compatibility.
        mapboxMap.addInteraction(TapInteraction { [mapTap] in
            mapTap.send($0)
            return false
        })
        mapboxMap.addInteraction(LongPressInteraction { [mapLongPress] in
            mapLongPress.send($0)
            return false
        })
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
    var onMapTap: Signal<InteractionContext> { get }
    var onMapLongPress: Signal<InteractionContext> { get }
    func onLayerTap(_ layerId: String, handler: @escaping MapLayerGestureHandler) -> AnyCancelable
    func onLayerLongPress(_ layerId: String, handler: @escaping MapLayerGestureHandler) -> AnyCancelable
}

extension GestureManager: GestureManagerProtocol {}
