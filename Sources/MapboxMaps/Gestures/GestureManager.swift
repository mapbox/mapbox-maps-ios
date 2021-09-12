import UIKit
import CoreLocation

public protocol GestureManagerDelegate: AnyObject {

    /// Informs the delegate that a gesture haas begun. Could be used to cancel camera tracking.
    func gestureBegan(for gestureType: GestureType)
}

public final class GestureManager {

    /// The `GestureOptions` that are used to set up the required gestures on the map
    public var options = GestureOptions() {
        didSet {
            configureGestureHandlers(for: options)
        }
    }

    /// Map of GestureType --> GestureHandler. We mantain a map to allow us to remove gestures arbitrarily.
    private(set) var gestureHandlers: [GestureType: GestureHandler] = [:]

    /// The underlying gesture recognizer for the pan gesture
    public var panGestureRecognizer: UIGestureRecognizer? {
        return gestureHandlers[.pan]?.gestureRecognizer
    }

    /// The underlying gesture recognizer for the "double tap to zoom in" gesture
    public var doubleTapToZoomInGestureRecognizer: UIGestureRecognizer? {
        return gestureHandlers[.tap(numberOfTaps: 2, numberOfTouches: 1)]?.gestureRecognizer
    }

    /// The underlying gesture recognizer for the "double tap to zoom out" gesture
    public var doubleTapToZoomOutGestureRecognizer: UIGestureRecognizer? {
        return gestureHandlers[.tap(numberOfTaps: 2, numberOfTouches: 2)]?.gestureRecognizer
    }

    /// The underlying gesture recognizer for the quickZoom gesture
    public var quickZoomGestureRecognizer: UIGestureRecognizer? {
        return gestureHandlers[.quickZoom]?.gestureRecognizer
    }

    /// The underlying gesture recognizer for the pitch gesture
    public var pitchGestureRecognizer: UIGestureRecognizer? {
        return gestureHandlers[.pitch]?.gestureRecognizer
    }

    /// The underlying gesture recognizer for the rotate gesture
    public var rotationGestureRecognizer: UIGestureRecognizer? {
        return gestureHandlers[.rotate]?.gestureRecognizer
    }

    /// The underlying gesture recognizer for the "pinch to zoom" gesture
    public var pinchGestureRecognizer: UIGestureRecognizer? {
        return gestureHandlers[.pinch]?.gestureRecognizer
    }

    /// The view that all gestures operate on
    private weak var view: UIView?

    /// The camera manager that responds to gestures.
    private let cameraAnimationsManager: CameraAnimationsManagerProtocol

    private let mapboxMap: MapboxMap

    /// Set this delegate to be called back if a gesture begins
    public weak var delegate: GestureManagerDelegate? {
        didSet {
            gestureHandlers.forEach { $0.value.delegate = delegate }
        }
    }

    /// Internal delegate for gesture recognizers
    // swiftlint:disable:next weak_delegate
    internal let gestureRecognizerDelegate: GestureRecognizerDelegate

    internal init(view: UIView, cameraAnimationsManager: CameraAnimationsManagerProtocol, mapboxMap: MapboxMap) {
        self.view = view
        self.cameraAnimationsManager = cameraAnimationsManager
        self.mapboxMap = mapboxMap
        self.gestureRecognizerDelegate = GestureRecognizerDelegate()
        configureGestureHandlers(for: options)
    }

    // Loops through supported gestures and generate associated handlers that are to be kept alive
    internal func configureGestureHandlers(for options: GestureOptions) {
        guard let view = view else {
            assertionFailure("GestureManager view is nil.")
            return
        }
        var newGestureHandlerMap: [GestureType: GestureHandler] = [:]
        for gestureType in options.supportedGestureTypes() {
            if gestureHandlers[gestureType] == nil {
                newGestureHandlerMap[gestureType] = gestureType.makeHandler(for: view,
                                                                            cameraAnimationsManager: cameraAnimationsManager,
                                                                            mapboxMap: mapboxMap,
                                                                            contextProvider: self,
                                                                            gestureOptions: options)
                newGestureHandlerMap[gestureType]?.delegate = delegate
            } else {
                newGestureHandlerMap[gestureType] = gestureHandlers[gestureType]
            }
        }

        gestureHandlers = newGestureHandlerMap

        if let pitchHandler = gestureHandlers[.pitch], let panHandler = gestureHandlers[.pan] {
            requireGestureToFail(allowedGesture: pitchHandler, failableGesture: panHandler)
        }

        if let pinchHandler = gestureHandlers[.pinch], let panHandler = gestureHandlers[.pan] {
            requireGestureToFail(allowedGesture: pinchHandler, failableGesture: panHandler)
        }

        if let doubleTapHandler = gestureHandlers[.tap(numberOfTaps: 2, numberOfTouches: 1)],
           let quickZoomHandler = gestureHandlers[.quickZoom] {
            requireGestureToFail(allowedGesture: quickZoomHandler, failableGesture: doubleTapHandler)
        }

        registerAsDelegate()
    }

    internal func registerAsDelegate() {

        guard let view = view,
              let validGestureRecognizers = view.gestureRecognizers else {
            return
        }

        for gestureRecognizer in validGestureRecognizers {
            gestureRecognizer.delegate = gestureRecognizerDelegate
        }
    }
}

/**
 Declare protocol with AnyObject so that it can
 be specified as weak.
 */
internal protocol GestureContextProvider: AnyObject {
    func fetchPinchState() -> UIGestureRecognizer.State?
    func fetchPinchScale() -> CGFloat?
    func requireGestureToFail(allowedGesture: GestureHandler, failableGesture: GestureHandler)
}

extension GestureManager: GestureContextProvider {

    internal func fetchPinchState() -> UIGestureRecognizer.State? {

        guard let validPinchHandler = gestureHandlers[.pinch],
            let validPinchRecognizer = validPinchHandler.gestureRecognizer as? UIPinchGestureRecognizer else {
                return nil
        }

        return validPinchRecognizer.state
    }

    internal func fetchPinchScale() -> CGFloat? {

        guard let validPinchHandler = gestureHandlers[.pinch],
            let validPinchRecognizer = validPinchHandler.gestureRecognizer as? UIPinchGestureRecognizer else {
                return nil
        }

        return validPinchRecognizer.scale
    }

    internal func requireGestureToFail(allowedGesture: GestureHandler, failableGesture: GestureHandler) {
        guard let failableGesture = failableGesture.gestureRecognizer else { return }
        allowedGesture.gestureRecognizer?.require(toFail: failableGesture)
    }
}
