#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// `DoubleTouchToZoomOutGestureHandler` updates the map camera in response
/// to single tap gestures with 2 touches
internal final class DoubleTouchToZoomOutGestureHandler: GestureHandler {

    private let mapboxMap: MapboxMapProtocol

    private let cameraAnimationsManager: CameraAnimationsManagerProtocol

    internal init(gestureRecognizer: UITapGestureRecognizer,
                  mapboxMap: MapboxMapProtocol,
                  cameraAnimationsManager: CameraAnimationsManagerProtocol) {
        gestureRecognizer.numberOfTapsRequired = 1
        #if !os(tvOS)
        gestureRecognizer.numberOfTouchesRequired = 2
        #endif
        self.mapboxMap = mapboxMap
        self.cameraAnimationsManager = cameraAnimationsManager
        super.init(
            gestureRecognizer: gestureRecognizer)
        gestureRecognizer.addTarget(self, action: #selector(handleGesture(_:)))
    }

    @objc private func handleGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        switch gestureRecognizer.state {
        case .recognized:
            guard let view = gestureRecognizer.view else { return }
            delegate?.gestureBegan(for: .doubleTouchToZoomOut)
            delegate?.gestureEnded(for: .doubleTouchToZoomOut, willAnimate: true)

            let tapLocation = gestureRecognizer.location(in: view)
            cameraAnimationsManager.ease(
                to: CameraOptions(anchor: tapLocation, zoom: mapboxMap.cameraState.zoom - 1),
                duration: 0.3,
                curve: .easeOut) { _ in
                    self.delegate?.animationEnded(for: .doubleTouchToZoomOut)
                }
        default:
            break
        }
    }
}
