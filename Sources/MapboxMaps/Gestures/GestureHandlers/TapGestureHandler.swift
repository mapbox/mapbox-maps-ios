import UIKit

/// The TapGestureHandler is responsible for all `tap`
/// related infrastructure and tells the view to update itself when required
internal class TapGestureHandler: GestureHandler {

    private let cameraAnimationsManager: CameraAnimationsManagerProtocol
    private let mapboxMap: MapboxMapProtocol

    // Configures the TapGestureRecognizer to handle a tap
    public required init(for view: UIView,
                         numberOfTapsRequired numberOfTaps: Int = 1,
                         numberOfTouchesRequired: Int = 1,
                         withDelegate delegate: GestureHandlerDelegate,
                         cameraAnimationsManager: CameraAnimationsManagerProtocol,
                         mapboxMap: MapboxMapProtocol) {
        self.cameraAnimationsManager = cameraAnimationsManager
        self.mapboxMap = mapboxMap
        super.init(for: view, withDelegate: delegate)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                          action: #selector(handleTap(_:)))
        tapGestureRecognizer.numberOfTapsRequired = numberOfTaps
        tapGestureRecognizer.numberOfTouchesRequired = numberOfTouchesRequired
        view.addGestureRecognizer(tapGestureRecognizer)
        gestureRecognizer = tapGestureRecognizer
    }

    // Calls view to process the tap gesture
    @objc internal func handleTap(_ tap: UITapGestureRecognizer) {
        delegate.gestureBegan(for: .tap(numberOfTaps: tap.numberOfTapsRequired, numberOfTouches: tap.numberOfTouchesRequired))

        // Single tapping twice with one finger will cause the map to zoom in
        if tap.numberOfTapsRequired == 2 && tap.numberOfTouchesRequired == 1 {
            _ = cameraAnimationsManager.ease(to: CameraOptions(zoom: mapboxMap.cameraState.zoom + 1.0),
                                             duration: 0.3,
                                             curve: .easeOut,
                                             completion: nil)
        }

        // Double tapping twice with two fingers will cause the map to zoom out
        if tap.numberOfTapsRequired == 2 && tap.numberOfTouchesRequired == 2 {
            _ = cameraAnimationsManager.ease(to: CameraOptions(zoom: mapboxMap.cameraState.zoom - 1.0),
                                             duration: 0.3,
                                             curve: .easeOut,
                                             completion: nil)
        }
    }
}
