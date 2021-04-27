import UIKit
import MapboxCommon
import MapboxCoreMaps

extension GestureManager: GestureHandlerDelegate {
    // MapView has been tapped a certain number of times
    internal func tapped(numberOfTaps: Int, numberOfTouches: Int) {

        guard let mapView = cameraManager.mapView else {
            return
        }

        // Single tapping twice with one finger will cause the map to zoom in
        if numberOfTaps == 2 && numberOfTouches == 1 {
            cameraManager.setCamera(to: CameraOptions(zoom: mapView.zoom + 1.0),
                                    animated: true,
                                    duration: 0.3,
                                    completion: nil)
        }

        // Double tapping twice with two fingers will cause the map to zoom out
        if numberOfTaps == 2 && numberOfTouches == 2 {
            cameraManager.setCamera(to: CameraOptions(zoom: mapView.zoom - 1.0),
                                    animated: true,
                                    duration: 0.3,
                                    completion: nil)
        }
    }

    internal func panBegan(at point: CGPoint) {
        cameraManager.mapView?.mapboxMap.__map.dragStart(forPoint: point.screenCoordinate)
    }

    // MapView has been panned
    internal func panned(from startPoint: CGPoint, to endPoint: CGPoint) {

        if let cameraOptions = cameraManager.mapView?.mapboxMap.__map.getDragCameraOptionsFor(fromPoint: startPoint.screenCoordinate, toPoint: endPoint.screenCoordinate) {

            cameraManager.setCamera(to: CameraOptions(cameraOptions),
                                    animated: false,
                                    duration: 0,
                                    completion: nil)

        }
    }

    // Pan has ended on the MapView with a residual `offset`
    func panEnded(at endPoint: CGPoint, shouldDriftTo driftEndPoint: CGPoint) {

        if endPoint != driftEndPoint,
           let driftCameraOptions = cameraManager.mapView?.mapboxMap.__map.getDragCameraOptionsFor(fromPoint: endPoint.screenCoordinate, toPoint: driftEndPoint.screenCoordinate) {

            cameraManager.setCamera(to: CameraOptions(driftCameraOptions),
                                    animated: true,
                                    duration: Double(cameraManager.mapCameraOptions.decelerationRate),
                                    completion: nil)
        }
        cameraManager.mapView?.mapboxMap.__map.dragEnd()
    }

    internal func cancelGestureTransitions() {
        cameraManager.cancelAnimations()
    }

    internal func gestureBegan(for gestureType: GestureType) {
        cameraManager.cancelAnimations()
        delegate?.gestureBegan(for: gestureType)
    }

    internal func scaleForZoom() -> CGFloat {
        cameraManager.mapView?.zoom ?? 0
    }

    internal func pinchScaleChanged(with newScale: CGFloat, andAnchor anchor: CGPoint) {
        cameraManager.setCamera(to: CameraOptions(anchor: anchor, zoom: newScale),
                                animated: false,
                                duration: 0,
                                completion: nil)
    }

    internal func pinchEnded(with finalScale: CGFloat, andDrift possibleDrift: Bool, andAnchor anchor: CGPoint) {
        cameraManager.setCamera(to: CameraOptions(anchor: anchor, zoom: finalScale),
                                animated: false,
                                duration: 0,
                                completion: nil)
        unrotateIfNeededForGesture(with: .ended)
    }

    internal func quickZoomChanged(with newScale: CGFloat, and anchor: CGPoint) {
        let zoom = max(newScale, cameraManager.mapCameraOptions.minimumZoomLevel)
        cameraManager.setCamera(to: CameraOptions(anchor: anchor, zoom: zoom),
                                animated: false,
                                duration: 0,
                                completion: nil)
    }

    internal func quickZoomEnded() {
        unrotateIfNeededForGesture(with: .ended)
    }
    internal func isRotationAllowed() -> Bool {
        guard let mapView = cameraManager.mapView else {
            return false
        }

        return mapView.zoom >= cameraManager.mapCameraOptions.minimumZoomLevel
    }

    internal func rotationStartAngle() -> CGFloat {
        guard let mapView = cameraManager.mapView else {
            return 0
        }
        return CGFloat((mapView.bearing * .pi) / 180.0 * -1)
    }

    internal func rotationChanged(with changedAngle: CGFloat, and anchor: CGPoint, and pinchScale: CGFloat) {

        var changedAngleInDegrees = changedAngle * 180.0 / .pi * -1
        changedAngleInDegrees = changedAngleInDegrees.truncatingRemainder(dividingBy: 360.0)

        // Constraining `changedAngleInDegrees` to -30.0 to +30.0 degrees
        if isRotationAllowed() == false && abs(pinchScale) < 10 {
            changedAngleInDegrees = changedAngleInDegrees < -30.0 ? -30.0 : changedAngleInDegrees
            changedAngleInDegrees = changedAngleInDegrees > 30.0 ? 30.0 : changedAngleInDegrees
        }

        cameraManager.setCamera(to: CameraOptions(bearing: CLLocationDirection(changedAngleInDegrees)),
                                animated: false,
                                duration: 0,
                                completion: nil)
    }

    internal func rotationEnded(with finalAngle: CGFloat, and anchor: CGPoint, with pinchState: UIGestureRecognizer.State) {
        var finalAngleInDegrees = finalAngle * 180.0 / .pi * -1
        finalAngleInDegrees = finalAngleInDegrees.truncatingRemainder(dividingBy: 360.0)
        cameraManager.setCamera(to: CameraOptions(bearing: CLLocationDirection(finalAngleInDegrees)),
                                animated: false,
                                duration: 0,
                                completion: nil)
    }

    internal func unrotateIfNeededForGesture(with pinchState: UIGestureRecognizer.State) {
        guard let mapView = cameraManager.mapView else {
            return
        }

        // Avoid contention with in-progress gestures
        // let toleranceForSnappingToNorth: CGFloat = 7.0
        if mapView.bearing != 0.0
            && pinchState != .began
            && pinchState != .changed {
            if mapView.bearing != 0.0 && isRotationAllowed() == false {
                cameraManager.setCamera(to: CameraOptions(bearing: 0),
                                        animated: false,
                                        duration: 0,
                                        completion: nil)
            }

            // TODO: Add snapping behavior to "north" if bearing is less than some tolerance
            // else if abs(self.mapView.cameraView.bearing) < toleranceForSnappingToNorth
            //            || abs(self.mapView.cameraView.bearing) > 360.0 - toleranceForSnappingToNorth {
            //    self.transitionBearing(to: 0.0, animated: true)
            //}
        }
    }

    internal func initialPitch() -> CGFloat {
        guard let mapView = cameraManager.mapView else {
            return 0
        }
        return mapView.pitch
    }

    internal func horizontalPitchTiltTolerance() -> Double {
        return 45.0
    }

    internal func pitchChanged(newPitch: CGFloat) {
        cameraManager.setCamera(to: CameraOptions(pitch: newPitch),
                                animated: false,
                                duration: 0,
                                completion: nil)
    }

    internal func pitchEnded() {
    }
}
