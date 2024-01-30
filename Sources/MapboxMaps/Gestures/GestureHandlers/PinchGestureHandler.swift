import UIKit
@_implementationOnly import MapboxCommon_Private

internal protocol PinchGestureHandlerProtocol: FocusableGestureHandlerProtocol {
    var zoomEnabled: Bool { get set }
    var simultaneousRotateAndPinchZoomEnabled: Bool { get set }
    var focalPoint: CGPoint? { get set }
}

/// `PinchGestureHandler` updates the map camera in response to a 2-touch
/// gesture that may consist of translation, scaling, and rotation
internal final class PinchGestureHandler: GestureHandler, PinchGestureHandlerProtocol {
    /// Whether pinch gesture can zoom map or not
    internal var zoomEnabled: Bool = true

    internal var simultaneousRotateAndPinchZoomEnabled: Bool = true

    /// Anchor point for rotating and zooming
    internal var focalPoint: CGPoint?

    private var invokedGestureBegan = false
    private var initialZoom: CGFloat?

    private let mapboxMap: MapboxMapProtocol

    /// Initialize the handler which creates the panGestureRecognizer and adds to the view
    internal init(gestureRecognizer: UIPinchGestureRecognizer, mapboxMap: MapboxMapProtocol) {
        self.mapboxMap = mapboxMap
        super.init(gestureRecognizer: gestureRecognizer)
        gestureRecognizer.delegate = self
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
                initialZoom = nil
                gestureRecognizer.scale = 1
                return
            }

            if let initialZoom = initialZoom {
                let zoomIncrement = log2(gestureRecognizer.scale)
                mapboxMap.setCamera(to: CameraOptions(
                    anchor: focalPoint ?? gestureRecognizer.location(in: view),
                    zoom: initialZoom + zoomIncrement))
            } else {
                start(with: gestureRecognizer)
            }
        case .ended, .cancelled:
            initialZoom = nil
            if invokedGestureBegan {
                delegate?.gestureEnded(for: .pinch, willAnimate: false)
            }
            invokedGestureBegan = false
        default:
            break
        }
    }

    private func start(with gestureRecognizer: UIPinchGestureRecognizer) {
        initialZoom = mapboxMap.cameraState.zoom

        // if this is the first time we started handling the gesture, inform
        // the delegate.
        if !invokedGestureBegan {
            invokedGestureBegan = true
            delegate?.gestureBegan(for: .pinch)
        }
    }
}

extension PinchGestureHandler: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.gestureRecognizer === gestureRecognizer && zoomEnabled
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        guard gestureRecognizer === self.gestureRecognizer else { return true }

        guard gestureRecognizer.attachedToSameView(as: otherGestureRecognizer) else { return true }

        switch otherGestureRecognizer {
        case is UIRotationGestureRecognizer:
            return simultaneousRotateAndPinchZoomEnabled
#if !(swift(>=5.9) && os(visionOS))
        case is UIScreenEdgePanGestureRecognizer:
            return false
#endif
        case let pan as UIPanGestureRecognizer where pan.maximumNumberOfTouches == 1:
            return true
        default:
            return false
        }
    }
}
