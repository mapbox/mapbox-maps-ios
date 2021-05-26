import Foundation

// MARK: - Int
extension Int {
    /// Wraps an `Int` within a `NSNumber` value.
    internal var NSNumber: NSNumber {
        Foundation.NSNumber(value: Int(self))
    }
}

extension UInt64 {
    /// Wraps an `Int` within a `NSNumber` value.
    internal var NSNumber: NSNumber {
        Foundation.NSNumber(value: UInt64(self))
    }
}
