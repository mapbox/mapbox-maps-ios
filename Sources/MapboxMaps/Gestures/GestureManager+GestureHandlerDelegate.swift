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
            _ = cameraManager.ease(to: CameraOptions(zoom: mapView.cameraState.zoom + 1.0),
                                   duration: 0.3,
                                   curve: .easeOut,
                                   completion: nil)
        }

        // Double tapping twice with two fingers will cause the map to zoom out
        if numberOfTaps == 2 && numberOfTouches == 2 {
            _ = cameraManager.ease(to: CameraOptions(zoom: mapView.cameraState.zoom - 1.0),
                                   duration: 0.3,
                                   curve: .easeOut,
                                   completion: nil)
        }
    }

    internal func panBegan(at point: CGPoint) {
        cameraManager.mapView?.mapboxMap.__map.dragStart(forPoint: point.screenCoordinate)
    }

    // MapView has been panned
    internal func panned(from startPoint: CGPoint, to endPoint: CGPoint) {

        if let cameraOptions = cameraManager.mapView?.mapboxMap.__map.getDragCameraOptionsFor(
            fromPoint: startPoint.screenCoordinate,
            toPoint: endPoint.screenCoordinate) {
            cameraManager.setCamera(to: CameraOptions(cameraOptions))
        }
    }

    // Pan has ended on the MapView with a residual `offset`
    func panEnded(at endPoint: CGPoint, shouldDriftTo driftEndPoint: CGPoint) {

        if endPoint != driftEndPoint,
           let driftCameraOptions = cameraManager.mapView?.mapboxMap.__map.getDragCameraOptionsFor(fromPoint: endPoint.screenCoordinate, toPoint: driftEndPoint.screenCoordinate) {

            _ = cameraManager.ease(
                    to: CameraOptions(driftCameraOptions),
                    duration: Double(cameraManager.options.decelerationRate),
                    curve: .easeOut,
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
        guard let mapView = cameraManager.mapView else {
            Log.error(forMessage: "MapView must exist when beginning a pinch gesture", category: "Gestures")
            return .zero
        }
        return mapView.cameraState.zoom
    }

    internal func pinchScaleChanged(with newScale: CGFloat, andAnchor anchor: CGPoint) {
        cameraManager.setCamera(to: CameraOptions(anchor: anchor, zoom: newScale))
    }

    internal func pinchEnded(with finalScale: CGFloat, andDrift possibleDrift: Bool, andAnchor anchor: CGPoint) {
        cameraManager.setCamera(to: CameraOptions(anchor: anchor, zoom: finalScale))
        unrotateIfNeededForGesture(with: .ended)
    }

    internal func quickZoomChanged(with newScale: CGFloat, and anchor: CGPoint) {
        let zoom = max(newScale, cameraManager.options.minimumZoomLevel)
        cameraManager.setCamera(to: CameraOptions(anchor: anchor, zoom: zoom))
    }

    internal func quickZoomEnded() {
        unrotateIfNeededForGesture(with: .ended)
    }
    internal func isRotationAllowed() -> Bool {
        guard let mapView = cameraManager.mapView else {
            return false
        }

        return mapView.cameraState.zoom >= cameraManager.options.minimumZoomLevel
    }

    internal func rotationStartAngle() -> CGFloat {
        guard let mapView = cameraManager.mapView else {
            return 0
        }
        return CGFloat((mapView.cameraState.bearing * .pi) / 180.0 * -1)
    }

    internal func rotationChanged(with changedAngle: CGFloat, and anchor: CGPoint, and pinchScale: CGFloat) {

        var changedAngleInDegrees = changedAngle * 180.0 / .pi * -1
        changedAngleInDegrees = changedAngleInDegrees.truncatingRemainder(dividingBy: 360.0)

        // Constraining `changedAngleInDegrees` to -30.0 to +30.0 degrees
        if isRotationAllowed() == false && abs(pinchScale) < 10 {
            changedAngleInDegrees = changedAngleInDegrees < -30.0 ? -30.0 : changedAngleInDegrees
            changedAngleInDegrees = changedAngleInDegrees > 30.0 ? 30.0 : changedAngleInDegrees
        }

        cameraManager.setCamera(
            to: CameraOptions(bearing: CLLocationDirection(changedAngleInDegrees)))
    }

    internal func rotationEnded(with finalAngle: CGFloat, and anchor: CGPoint, with pinchState: UIGestureRecognizer.State) {
        var finalAngleInDegrees = finalAngle * 180.0 / .pi * -1
        finalAngleInDegrees = finalAngleInDegrees.truncatingRemainder(dividingBy: 360.0)
        cameraManager.setCamera(to: CameraOptions(bearing: CLLocationDirection(finalAngleInDegrees)))
    }

    internal func unrotateIfNeededForGesture(with pinchState: UIGestureRecognizer.State) {
        guard let mapView = cameraManager.mapView else {
            return
        }

        let currentBearing = mapView.cameraState.bearing

        // Avoid contention with in-progress gestures
        // let toleranceForSnappingToNorth: CGFloat = 7.0
        if currentBearing != 0.0
            && pinchState != .began
            && pinchState != .changed {
            if currentBearing != 0.0 && isRotationAllowed() == false {
                cameraManager.setCamera(to: CameraOptions(bearing: 0))
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
            Log.error(forMessage: "MapView must exist when starting pitch gesture", category: "Gestures")
            return 0
        }
        return mapView.cameraState.pitch
    }

    internal func horizontalPitchTiltTolerance() -> Double {
        return 45.0
    }

    internal func pitchChanged(newPitch: CGFloat) {
        cameraManager.setCamera(to: CameraOptions(pitch: newPitch))
    }

    internal func pitchEnded() {
    }
}
