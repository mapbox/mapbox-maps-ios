//
//  PitchGestureHandler.swift
//  MapboxMapsGestures
//

import Foundation
import UIKit
import CoreLocation

/*
 The `PitchGestureHandler` is responsible for handling the response
 triggered by a gesture comprised of a two-ginger pan in a vertical direction.
 
 The pitch gesture is only triggered if the angle between the two
 touch points is greater than 45°.
 */

internal class PitchGestureHandler: GestureHandler {
    internal var initialPitch = CGFloat.zero
    internal var dragGestureTranslation: CGPoint!
    private let mapboxMap: MapboxMapProtocol
    private let cameraAnimationsManager: CameraAnimationsManagerProtocol

    internal init(for view: UIView, mapboxMap: MapboxMapProtocol, cameraAnimationsManager: CameraAnimationsManagerProtocol) {
        self.mapboxMap = mapboxMap
        self.cameraAnimationsManager = cameraAnimationsManager
        super.init(for: view)

        let pitchGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePitchGesture(_:)))
        pitchGesture.minimumNumberOfTouches = 2
        pitchGesture.maximumNumberOfTouches = 2
        gestureRecognizer = pitchGesture
        view.addGestureRecognizer(pitchGesture)
    }

    @objc internal func handlePitchGesture(_ gesture: UIPanGestureRecognizer) {

        let horizontalTiltTolerance = 45.0

        if gesture.numberOfTouches != 2 {
            gesture.state = .ended
            return
        }

        if gesture.state == .began {

            let gestureTranslation = gesture.translation(in: gesture.view)
            /*
             In the following if and for the first execution gestureTranslation
             will be equal to dragGestureTranslation and the resulting
             gestureSlopeAngle will be 0º causing a small delay,
             initializing dragGestureTranslation with the current gestureTranslation
             but substracting one point from the 'y' translation forces an initial 90º angle
             making the gesture avoid the delay.
            */
            dragGestureTranslation = CGPoint(x: gestureTranslation.x, y: gestureTranslation.y-1)
            initialPitch = mapboxMap.cameraState.pitch
            cameraAnimationsManager.cancelAnimations()
            delegate?.gestureBegan(for: .pitch)

        } else if gesture.state == .changed {
            let leftTouchPoint = gesture.location(ofTouch: 0, in: gesture.view)
            let rightTouchPoint = gesture.location(ofTouch: 1, in: gesture.view)

            // Calculate the angle between the first and second finger touches
            let touchPointAngle = GestureUtilities.angleBetweenPoints(leftTouchPoint, rightTouchPoint)

            // The total direction the gesture has moved
            let gestureTranslation = gesture.translation(in: gesture.view)

            // The angle between the translation at the start of the gesture
            // and the current changed translation
            let gestureSlopeAngle = GestureUtilities.angleBetweenPoints(dragGestureTranslation, gestureTranslation)
            dragGestureTranslation = gestureTranslation

            // If the angle between the pan touchpoints is less than
            // the tolerance specified AND the slope angle of the gesture's
            // movement is more then 60, notify the delegate of a change in pitch.
            if fabs(touchPointAngle) < horizontalTiltTolerance && fabs(gestureSlopeAngle) > 60 {
                let verticalGestureTranslation = gestureTranslation.y
                let slowDown = CGFloat(2.0)
                let newPitch = initialPitch - ( verticalGestureTranslation / slowDown )
                mapboxMap.setCamera(to: CameraOptions(pitch: newPitch))
            }
        }
    }
}
