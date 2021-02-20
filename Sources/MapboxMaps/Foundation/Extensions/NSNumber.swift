import Foundation
import CoreGraphics
import CoreLocation

// MARK: - NSNumber
public extension NSNumber {

    /// Converts an `NSNumber` to a `CGFloat` value from its `Double` representation.
    var CGFloat: CGFloat {
        CoreGraphics.CGFloat(doubleValue)
    }

    /// Converts the `Float` value of an `NSNumber` to a `CLLocationDirection` representation.
    var CLLocationDirection: CLLocationDirection {
        CoreLocation.CLLocationDirection(floatValue)
    }
}
