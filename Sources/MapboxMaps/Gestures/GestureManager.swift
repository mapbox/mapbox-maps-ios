import UIKit

public protocol GestureManagerDelegate: AnyObject {

    /// Informs the delegate that a gesture has begun. Could be used to cancel camera tracking.
    func gestureManager(_ gestureManager: GestureManager, didBegin gestureType: GestureType)

    /// Informs the delegate that a gesture has ended and whether there will be additional animations after the gesture
    /// has completed. Does not indicate whether gesture-triggered animations have completed.
    func gestureManager(_ gestureManager: GestureManager, didEnd gestureType: GestureType, willDecelerate: Bool)

    /// Informs the delegate that animations triggered due to a gesture have ended.
    func gestureManager(_ gestureManager: GestureManager, didEndDeceleratingFor gestureType: GestureType)
}

public final class GestureManager: GestureHandlerDelegate {

    /// Configuration options for the built-in gestures
    public var options: GestureOptions {
        set {
            panGestureRecognizer.isEnabled = newValue.panEnabled
            pinchGestureRecognizer.isEnabled = newValue.pinchEnabled
            pitchGestureRecognizer.isEnabled = newValue.pitchEnabled
            doubleTapToZoomInGestureRecognizer.isEnabled = newValue.doubleTapToZoomInEnabled
            doubleTouchToZoomOutGestureRecognizer.isEnabled = newValue.doubleTouchToZoomOutEnabled
            quickZoomGestureRecognizer.isEnabled = newValue.quickZoomEnabled
            panGestureHandler.panMode = newValue.panMode
            panGestureHandler.decelerationFactor = newValue.panDecelerationFactor
        }
        get {
            var gestureOptions = GestureOptions()
            gestureOptions.panEnabled = panGestureRecognizer.isEnabled
            gestureOptions.pinchEnabled = pinchGestureRecognizer.isEnabled
            gestureOptions.pitchEnabled = pitchGestureRecognizer.isEnabled
            gestureOptions.doubleTapToZoomInEnabled = doubleTapToZoomInGestureRecognizer.isEnabled
            gestureOptions.doubleTouchToZoomOutEnabled = doubleTouchToZoomOutGestureRecognizer.isEnabled
            gestureOptions.quickZoomEnabled = quickZoomGestureRecognizer.isEnabled
            gestureOptions.panMode = panGestureHandler.panMode
            gestureOptions.panDecelerationFactor = panGestureHandler.decelerationFactor
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

    /// The gesture recognizer for the "double tap to zoom out" gesture
    public var doubleTouchToZoomOutGestureRecognizer: UIGestureRecognizer {
        return doubleTouchToZoomOutGestureHandler.gestureRecognizer
    }

    /// The gesture recognizer for the quickZoom gesture
    public var quickZoomGestureRecognizer: UIGestureRecognizer {
        return quickZoomGestureHandler.gestureRecognizer
    }

    /// Set this delegate to be called back if a gesture begins
    public weak var delegate: GestureManagerDelegate?

    private let panGestureHandler: PanGestureHandlerProtocol
    private let pinchGestureHandler: GestureHandler
    private let pitchGestureHandler: GestureHandler
    private let doubleTapToZoomInGestureHandler: GestureHandler
    private let doubleTouchToZoomOutGestureHandler: GestureHandler
    private let quickZoomGestureHandler: GestureHandler

    internal init(panGestureHandler: PanGestureHandlerProtocol,
                  pinchGestureHandler: GestureHandler,
                  pitchGestureHandler: GestureHandler,
                  doubleTapToZoomInGestureHandler: GestureHandler,
                  doubleTouchToZoomOutGestureHandler: GestureHandler,
                  quickZoomGestureHandler: GestureHandler) {
        self.panGestureHandler = panGestureHandler
        self.pinchGestureHandler = pinchGestureHandler
        self.pitchGestureHandler = pitchGestureHandler
        self.doubleTapToZoomInGestureHandler = doubleTapToZoomInGestureHandler
        self.doubleTouchToZoomOutGestureHandler = doubleTouchToZoomOutGestureHandler
        self.quickZoomGestureHandler = quickZoomGestureHandler

        panGestureHandler.delegate = self
        pinchGestureHandler.delegate = self
        pitchGestureHandler.delegate = self
        doubleTapToZoomInGestureHandler.delegate = self
        doubleTouchToZoomOutGestureHandler.delegate = self
        quickZoomGestureHandler.delegate = self

        pinchGestureHandler.gestureRecognizer.require(toFail: panGestureHandler.gestureRecognizer)
        pitchGestureHandler.gestureRecognizer.require(toFail: panGestureHandler.gestureRecognizer)
        quickZoomGestureHandler.gestureRecognizer.require(toFail: doubleTapToZoomInGestureHandler.gestureRecognizer)

        // Invoke the setter to ensure the defaults are synchronized
        self.options = GestureOptions()
    }

    internal func gestureBegan(for gestureType: GestureType) {
        delegate?.gestureManager(self, didBegin: gestureType)
    }

    func gestureEnded(for gestureType: GestureType, willDecelerate: Bool) {
        delegate?.gestureManager(self, didEnd: gestureType, willDecelerate: willDecelerate)
    }

    func driftEnded(for gestureType: GestureType) {
        delegate?.gestureManager(self, didEndDeceleratingFor: gestureType)
    }
}
