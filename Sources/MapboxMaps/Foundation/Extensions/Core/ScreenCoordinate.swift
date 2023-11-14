import Foundation
import CoreLocation
import CoreGraphics

// MARK: - ScreenCoordinate

extension CoreScreenCoordinate {

    // swiftlint:disable identifier_name
    /// Initializes an internal `ScreenCoordinate` type from two `CGFloat` values.
    /// - Parameters:
    ///   - x: The horizontal point along the screen's coordinate system.
    ///   - y: The vertical point along the screen's coordinate system.
    internal convenience init(x: CGFloat, y: CGFloat) {
        self.init(x: Double(x), y: Double(y))
    }
    // swiftlint:enable identifier_name

    /// Returns a `CGPoint` representation of an internal `ScreenCoordinate` value.
    internal var point: CGPoint {
        CGPoint(x: x, y: y)
    }
}
