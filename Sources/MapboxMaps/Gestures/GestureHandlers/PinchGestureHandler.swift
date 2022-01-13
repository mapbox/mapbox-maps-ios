#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

internal protocol PinchGestureHandlerProtocol: GestureHandler {
    var rotateEnabled: Bool { get set }
    var behavior: PinchGestureBehavior { get set }
}

internal protocol PinchGestureHandlerImpl: AnyObject {
    func handleGesture(_ gestureRecognizer: UIPinchGestureRecognizer, state: UIGestureRecognizer.State)
}

/// `PinchGestureHandler` updates the map camera in response to a 2-touch
/// gesture that may consist of translation, scaling, and rotation
internal final class PinchGestureHandler: GestureHandler, PinchGestureHandlerProtocol {
    /// Whether pinch gesture can rotate map or not
    internal var rotateEnabled: Bool = true {
        didSet {
            impl1.rotateEnabled = rotateEnabled
            impl2.rotateEnabled = rotateEnabled
        }
    }

    internal var behavior: PinchGestureBehavior = .tracksTouchLocationsWhenPanningAfterZoomChange

    private var initialBehavior: PinchGestureBehavior?

    private let impl1: PinchGestureHandlerImpl1

    private let impl2: PinchGestureHandlerImpl2

    /// Initialize the handler which creates the panGestureRecognizer and adds to the view
    internal init(gestureRecognizer: UIPinchGestureRecognizer,
                  mapboxMap: MapboxMapProtocol) {
        self.impl1 = PinchGestureHandlerImpl1(mapboxMap: mapboxMap)
        self.impl2 = PinchGestureHandlerImpl2(mapboxMap: mapboxMap)
        super.init(gestureRecognizer: gestureRecognizer)
        gestureRecognizer.addTarget(self, action: #selector(handleGesture(_:)))
        impl1.delegate = self
        impl2.delegate = self
    }

    @objc private func handleGesture(_ gestureRecognizer: UIPinchGestureRecognizer) {
        let effectiveBehavior: PinchGestureBehavior?

        let state = gestureRecognizer.state

        switch state {
        case .began:
            effectiveBehavior = behavior
            initialBehavior = behavior
        case .changed:
            effectiveBehavior = initialBehavior
        case .cancelled, .ended:
            effectiveBehavior = initialBehavior
            initialBehavior = nil
        default:
            effectiveBehavior = nil
        }

        let impl: PinchGestureHandlerImpl?

        switch effectiveBehavior {
        case .tracksTouchLocationsWhenPanningAfterZoomChange:
            impl = impl1
        case .doesNotResetCameraAtEachFrame:
            impl = impl2
        default:
            impl = nil
        }

        impl?.handleGesture(gestureRecognizer, state: state)
    }
}

extension PinchGestureHandler: GestureHandlerDelegate {
    func gestureBegan(for gestureType: GestureType) {
        delegate?.gestureBegan(for: gestureType)
    }

    func gestureEnded(for gestureType: GestureType, willAnimate: Bool) {
        delegate?.gestureEnded(for: gestureType, willAnimate: willAnimate)
    }

    func animationEnded(for gestureType: GestureType) {
        delegate?.animationEnded(for: gestureType)
    }
}
