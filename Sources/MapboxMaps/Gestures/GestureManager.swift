import UIKit

public protocol GestureManagerDelegate: AnyObject {

    /// Informs the delegate that a gesture haas begun. Could be used to cancel camera tracking.
    func gestureBegan(for gestureType: GestureType)
}

public final class GestureManager: GestureHandlerDelegate {

    /// Configuration options for the built-in gestures
    public var options: GestureOptions {
        set {
            panGestureRecognizer.isEnabled = newValue.scrollEnabled
            doubleTapToZoomOutGestureRecognizer.isEnabled = newValue.zoomEnabled
            doubleTapToZoomInGestureRecognizer.isEnabled = newValue.zoomEnabled
            pinchGestureRecognizer.isEnabled = newValue.scrollEnabled && newValue.zoomEnabled
            rotationGestureRecognizer.isEnabled = newValue.rotateEnabled
            quickZoomGestureRecognizer.isEnabled = newValue.zoomEnabled
            pitchGestureRecognizer.isEnabled = newValue.pitchEnabled
            panScrollingMode = newValue.scrollingMode
            decelerationRate = newValue.decelerationRate
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
            gestureOptions.scrollingMode = panScrollingMode
            gestureOptions.decelerationRate = decelerationRate
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
    public var rotationGestureRecognizer: UIGestureRecognizer {
        return rotationGestureHandler.gestureRecognizer
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
    public var doubleTapToZoomOutGestureRecognizer: UIGestureRecognizer {
        return doubleTapToZoomOutGestureHandler.gestureRecognizer
    }

    /// The gesture recognizer for the quickZoom gesture
    public var quickZoomGestureRecognizer: UIGestureRecognizer {
        return quickZoomGestureHandler.gestureRecognizer
    }

    /// Set this delegate to be called back if a gesture begins
    public weak var delegate: GestureManagerDelegate?

    internal private(set) var decelerationRate: CGFloat
    internal private(set) var panScrollingMode: PanScrollingMode
    private let panGestureHandler: GestureHandler
    private let pinchGestureHandler: GestureHandler
    private let rotationGestureHandler: GestureHandler
    private let pitchGestureHandler: GestureHandler
    private let doubleTapToZoomInGestureHandler: GestureHandler
    private let doubleTapToZoomOutGestureHandler: GestureHandler
    private let quickZoomGestureHandler: GestureHandler

    internal init(decelerationRate: CGFloat,
                  panScrollingMode: PanScrollingMode,
                  panGestureHandler: GestureHandler,
                  pinchGestureHandler: GestureHandler,
                  rotationGestureHandler: GestureHandler,
                  pitchGestureHandler: GestureHandler,
                  doubleTapToZoomInGestureHandler: GestureHandler,
                  doubleTapToZoomOutGestureHandler: GestureHandler,
                  quickZoomGestureHandler: GestureHandler) {
        self.decelerationRate = decelerationRate
        self.panScrollingMode = panScrollingMode
        self.panGestureHandler = panGestureHandler
        self.pinchGestureHandler = pinchGestureHandler
        self.rotationGestureHandler = rotationGestureHandler
        self.pitchGestureHandler = pitchGestureHandler
        self.doubleTapToZoomInGestureHandler = doubleTapToZoomInGestureHandler
        self.doubleTapToZoomOutGestureHandler = doubleTapToZoomOutGestureHandler
        self.quickZoomGestureHandler = quickZoomGestureHandler

        panGestureHandler.delegate = self
        pinchGestureHandler.delegate = self
        rotationGestureHandler.delegate = self
        pitchGestureHandler.delegate = self
        doubleTapToZoomInGestureHandler.delegate = self
        doubleTapToZoomOutGestureHandler.delegate = self
        quickZoomGestureHandler.delegate = self

        pinchGestureHandler.gestureRecognizer.require(toFail: panGestureHandler.gestureRecognizer)
        pitchGestureHandler.gestureRecognizer.require(toFail: panGestureHandler.gestureRecognizer)
        quickZoomGestureHandler.gestureRecognizer.require(toFail: doubleTapToZoomInGestureHandler.gestureRecognizer)
    }

    internal func gestureBegan(for gestureType: GestureType) {
        delegate?.gestureBegan(for: gestureType)
    }
}
