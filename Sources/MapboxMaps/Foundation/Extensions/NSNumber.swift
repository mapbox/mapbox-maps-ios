import Foundation
import CoreGraphics
import CoreLocation

/// :nodoc:
/// Deprecated. These extensions will be removed from the public API in a future major version.
extension NSNumber {

    /// Converts an `NSNumber` to a `CGFloat` value from its `Double` representation.
    public var CGFloat: CGFloat {
        CoreGraphics.CGFloat(doubleValue)
    }

    /// Converts the `Float` value of an `NSNumber` to a `CLLocationDirection` representation.
    public var CLLocationDirection: CLLocationDirection {
        CoreLocation.CLLocationDirection(doubleValue)
    }

    // Useful for converting between NSNumbers and Core enums
    internal func intValueAsRawRepresentable<T>() -> T? where
        T: RawRepresentable,
        T.RawValue == Int {
        return T(rawValue: intValue)
    }
}
