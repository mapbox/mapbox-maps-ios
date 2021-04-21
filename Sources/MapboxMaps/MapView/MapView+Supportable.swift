import UIKit
import CoreLocation

extension MapView: OrnamentSupportableView {
    // User has tapped on an ornament
    internal func tapped() {

    }

    internal func compassTapped() {
        var animator: CameraAnimator?
        animator = camera.makeAnimator(duration: 0.3, curve: .easeOut, animations: { (transition) in
            transition.bearing.toValue = 0
        })

        animator?.addCompletion({ (_) in
            animator = nil
        })

        animator?.startAnimation()
    }

    internal func subscribeCameraChangeHandler(_ handler: @escaping (CameraOptions) -> Void) {
        on(.cameraChanged) { [weak self] _ in
            guard let validSelf = self else { return }
            handler(CameraOptions(validSelf.mapboxMap.__map.getCameraOptions(forPadding: nil)))
        }
    }
}

extension MapView: LocationSupportableMapView {

    public func screenCoordinate(for locationCoordinate: CLLocationCoordinate2D) -> ScreenCoordinate {
        return mapboxMap.__map.pixelForCoordinate(for: locationCoordinate)
    }

    public func metersPerPointAtLatitude(latitude: CLLocationDegrees) -> CLLocationDistance {
        return Projection.getMetersPerPixelAtLatitude(forLatitude: latitude, zoom: Double(zoom))
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
