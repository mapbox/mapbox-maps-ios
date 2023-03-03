import Foundation
import CoreGraphics
import CoreLocation

extension NSNumber {

    /// Converts an `NSNumber` to a `CGFloat` value from its `Double` representation.
    internal var CGFloat: CGFloat {
        CoreGraphics.CGFloat(doubleValue)
    }

    /// Converts the `Float` value of an `NSNumber` to a `CLLocationDirection` representation.
    internal var CLLocationDirection: CLLocationDirection {
        CoreLocation.CLLocationDirection(doubleValue)
    }

    // Useful for converting between NSNumbers and Core enums
    internal func intValueAsRawRepresentable<T>() -> T? where
        T: RawRepresentable,
        T.RawValue == Int {
        return T(rawValue: intValue)
    }
}
