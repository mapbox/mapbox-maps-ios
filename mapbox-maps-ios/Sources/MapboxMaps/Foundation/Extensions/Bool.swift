import Foundation

extension Bool {
    internal var NSNumber: NSNumber {
        Foundation.NSNumber(value: self)
    }
}
