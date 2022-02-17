import UIKit

internal protocol PinchGestureHandlerProtocol: GestureHandler {
    var rotateEnabled: Bool { get set }
    var zoomEnabled: Bool { get set }
    var panEnabled: Bool { get set }
}

/// `PinchGestureHandler` updates the map camera in response to a 2-touch
/// gesture that may consist of translation, scaling, and rotation
internal final class PinchGestureHandler: GestureHandler, PinchGestureHandlerProtocol {
    /// Whether pinch gesture can rotate map or not
    internal var rotateEnabled: Bool = true

    /// Whether pinch gesture can zoom map or not
    internal var zoomEnabled: Bool = true

    /// Whether pinch gesture can pan map or not
    internal var panEnabled: Bool = true

    /// The behavior for the current gesture, based on the initial state of the \*Enabled flags.
    private var pinchBehavior: PinchBehavior?

    private var invokedGestureBegan = false

    private let mapboxMap: MapboxMapProtocol

    private let pinchBehaviorProvider: PinchBehaviorProviderProtocol

    /// Initialize the handler which creates the panGestureRecognizer and adds to the view
    internal init(gestureRecognizer: UIPinchGestureRecognizer,
                  mapboxMap: MapboxMapProtocol,
                  pinchBehaviorProvider: PinchBehaviorProviderProtocol) {
        self.mapboxMap = mapboxMap
        self.pinchBehaviorProvider = pinchBehaviorProvider
        super.init(gestureRecognizer: gestureRecognizer)
        gestureRecognizer.addTarget(self, action: #selector(handleGesture(_:)))
    }

    @objc private func handleGesture(_ gestureRecognizer: UIPinchGestureRecognizer) {
        guard let view = gestureRecognizer.view else {
            return
        }
        switch gestureRecognizer.state {
        case .began:
            // UIPinchGestureRecognizer sometimes begins with 1 touch.
            // If that happens, we ignore it here, but will start handling it
            // in .changed if the number of touches increases to 2.
            guard gestureRecognizer.numberOfTouches == 2 else {
                return
            }
            start(with: gestureRecognizer)
        case .changed:
            // UIPinchGestureRecognizer sends a .changed event when the number
            // of touches decreases from 2 to 1. If this happens, we pause our
            // gesture handling.
            //
            // if a second touch goes down again before the gesture ends, we
            // resume and re-capture the initial state
            guard gestureRecognizer.numberOfTouches == 2 else {
                pinchBehavior = nil
                gestureRecognizer.scale = 1
                return
            }

            if let pinchBehavior = pinchBehavior {
                pinchBehavior.update(
                    pinchMidpoint: gestureRecognizer.location(in: view),
                    pinchScale: gestureRecognizer.scale,
                    pinchAngle: pinchAngle(with: gestureRecognizer))
            } else {
                start(with: gestureRecognizer)
            }
        case .ended, .cancelled:
            pinchBehavior = nil
            if invokedGestureBegan {
                delegate?.gestureEnded(for: .pinch, willAnimate: false)
            }
            invokedGestureBegan = false
        default:
            break
        }
    }

    private func start(with gestureRecognizer: UIPinchGestureRecognizer) {
        guard let view = gestureRecognizer.view else {
            return
        }
        pinchBehavior = pinchBehaviorProvider.makePinchBehavior(
            panEnabled: panEnabled,
            zoomEnabled: zoomEnabled,
            rotateEnabled: rotateEnabled,
            initialCameraState: mapboxMap.cameraState,
            initialPinchMidpoint: gestureRecognizer.location(in: view),
            initialPinchAngle: pinchAngle(with: gestureRecognizer))
        // if this is the first time we started handling the gesture, inform
        // the delegate.
        if !invokedGestureBegan {
            invokedGestureBegan = true
            delegate?.gestureBegan(for: .pinch)
        }
    }

    private func pinchAngle(with gestureRecognizer: UIPinchGestureRecognizer) -> CGFloat {
        // we guard for this at the call site
        let view = gestureRecognizer.view!
        let pinchPoint0 = gestureRecognizer.location(ofTouch: 0, in: view)
        let pinchPoint1 = gestureRecognizer.location(ofTouch: 1, in: view)
        return atan2(pinchPoint1.y - pinchPoint0.y, pinchPoint1.x - pinchPoint0.x)
    }
}
