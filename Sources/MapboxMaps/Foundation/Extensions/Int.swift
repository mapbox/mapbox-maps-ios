import Foundation

// MARK: - Int
extension Int {

    /// Wraps an `Int` within a `NSNumber` value.
    internal var NSNumber: NSNumber {
        Foundation.NSNumber(value: Int(self))
    }
}
