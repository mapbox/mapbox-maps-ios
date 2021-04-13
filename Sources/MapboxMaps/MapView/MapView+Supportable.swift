import UIKit
import CoreLocation

extension MapView: OrnamentSupportableView {
    // User has tapped on an ornament
    internal func tapped() {

    }

    internal func compassTapped() {
        // Don't have access to CameraManager, so calling UIView.animate directly.
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: [.curveEaseOut, .allowUserInteraction],
                       animations: { [weak self] in
                        self?.cameraView.bearing = 0.0
        }, completion: nil)
    }

    internal func subscribeCameraChangeHandler(_ handler: @escaping (CameraOptions) -> Void) {
        on(.cameraChanged) { [weak self] _ in
            guard let validSelf = self else { return }
            handler(validSelf.__map.getCameraOptions(forPadding: nil))
        }
    }
}

extension MapView: LocationSupportableMapView {

    public func screenCoordinate(for locationCoordinate: CLLocationCoordinate2D) -> ScreenCoordinate {
        return __map.pixelForCoordinate(for: locationCoordinate)
    }

    public func metersPerPointAtLatitude(latitude: CLLocationDegrees) -> CLLocationDistance {
        return Projection.getMetersPerPixelAtLatitude(forLatitude: latitude, zoom: Double(cameraView.zoom))
    }

    public func subscribeRenderFrameHandler(_ handler: @escaping (MapboxCoreMaps.Event) -> Void) {
        on(.renderFrameStarted) { (event) in
            handler(event)
        }
    }

    public func subscribeStyleChangeHandler(_ handler: @escaping (MapboxCoreMaps.Event) -> Void) {
         on(.styleLoaded) { (event) in
             handler(event)
         }
    }

}

extension Style: AnnotationStyleDelegate { }
