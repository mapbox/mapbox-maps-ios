//
//  GestureUtilities.swift
//  MapboxMapsGestures
//
//  Copyright © 2020 Mapbox. All rights reserved.
//

import UIKit
import CoreLocation

/**
 `GestureUtilities` provides a set of shared functions that can be used to perform
 common mathematical operations between gestures.
 */

internal class GestureUtilities {

    /**
     Calculates the angle in degrees between two points.
     For example, the angle between (0,0) and (45, 45) would be 45°
     */
    internal static func angleBetweenPoints(_ originPoint: CGPoint, _ endPoint: CGPoint) -> CLLocationDegrees? {
        var origin = originPoint
        var end = endPoint

        if originPoint.x > endPoint.x {
            origin = endPoint
            end = originPoint
        }

        let deltaX = end.x - origin.x
        let deltaY = end.y - origin.y

        let angleInRadians = atan2(deltaY, deltaX)
        let degreeDouble = (Double(angleInRadians) * 180) / Double.pi

        return CLLocationDegrees(exactly: degreeDouble)
    }
}
