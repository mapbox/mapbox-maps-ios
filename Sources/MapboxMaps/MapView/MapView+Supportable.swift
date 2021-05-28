import UIKit
import CoreLocation

extension MapView: OrnamentSupportableView {
    // User has tapped on an ornament
    internal func tapped() {

    }

    internal func compassTapped() {
        var animator: BasicCameraAnimator?
        animator = camera.makeAnimator(duration: 0.3, curve: .easeOut, animations: { (transition) in
            transition.bearing.toValue = 0
        })

        animator?.addCompletion({ (_) in
            animator = nil
        })

        animator?.startAnimation()
    }

    internal func subscribeCameraChangeHandler(_ handler: @escaping (CameraState) -> Void) {
        mapboxMap.onEvery(.cameraChanged) { [weak self] _ in
            guard let self = self else {
                return
            }
            handler(self.cameraState)
        }
    }
}

extension MapView: LocationSupportableMapView {

    public func point(for coordinate: CLLocationCoordinate2D) -> CGPoint {
        return mapboxMap.point(for: coordinate)
    }

    public func metersPerPointAtLatitude(latitude: CLLocationDegrees) -> CLLocationDistance {
        return Projection.metersPerPoint(for: latitude, zoom: cameraState.zoom)
    }

    public func subscribeRenderFrameHandler(_ handler: @escaping (MapboxCoreMaps.Event) -> Void) {
        mapboxMap.onEvery(.renderFrameStarted) { (event) in
            handler(event)
        }
    }

    public func subscribeStyleChangeHandler(_ handler: @escaping (MapboxCoreMaps.Event) -> Void) {
        mapboxMap.onEvery(.styleLoaded) { (event) in
            handler(event)
        }
    }
}

extension Style: LocationStyleDelegate { }
