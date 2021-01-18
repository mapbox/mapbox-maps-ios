import Foundation

// MARK: - Int
public extension Int {

    /// Wraps an `Int` within a `NSNumber` value.
    var NSNumber: NSNumber {
        Foundation.NSNumber(value: Int(self))
    }
}
