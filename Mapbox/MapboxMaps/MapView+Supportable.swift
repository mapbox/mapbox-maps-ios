import UIKit
import CoreLocation
import MapboxMapsOrnaments
import MapboxMapsFoundation
import MapboxMapsStyle
import MapboxMapsLocation
import MapboxMapsAnnotations


extension MapView: OrnamentSupportableView {
    // User has tapped on an ornament
    public func tapped() {

    }

    public func compassTapped() {
        // Don't have access to CameraManager, so calling UIView.animate directly.
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: [.curveEaseOut, .allowUserInteraction],
                       animations: { [weak self] in
                        self?.cameraView.bearing = 0.0
        }, completion: nil)
    }

    public func subscribeCameraChangeHandler(_ handler: @escaping (CameraOptions) -> Void) {
        self.on(.cameraDidChange) { [weak self] _ in
            guard let validSelf = self else { return }
            handler(try! validSelf.__map.getCameraOptions(forPadding: nil))
        }
    }
}

extension MapView: LocationSupportableMapView {

    public func screenCoordinate(for locationCoordinate: CLLocationCoordinate2D) -> ScreenCoordinate {
        return try! self.__map.pixelForCoordinate(for: locationCoordinate)
    }

    public func metersPerPointAtLatitude(latitude: CLLocationDegrees) -> CLLocationDistance {
        return try! Projection.getMetersPerPixelAtLatitude(forLatitude: latitude, zoom: Double(self.cameraView.zoom))
    }

    public func subscribeRenderFrameHandler(_ handler: @escaping (MapboxCoreMaps.Event) -> Void) {
        self.on(.renderFrameStarted) { (event) in
            handler(event)
        }
    }

    public func subscribeStyleChangeHandler(_ handler: @escaping (MapboxCoreMaps.Event) -> Void) {
         self.on(.styleLoadingFinished) { (event) in
             handler(event)
         }
    }

}

extension Style: AnnotationStyleDelegate { }
