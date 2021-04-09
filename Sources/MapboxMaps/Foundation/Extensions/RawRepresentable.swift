import Foundation

extension RawRepresentable where Self.RawValue == Int {
    internal var NSNumber: NSNumber {
        Foundation.NSNumber(value: rawValue)
    }
}
