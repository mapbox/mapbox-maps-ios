import Foundation

/// A type that conforms to `Cancelable` typically represents a long
/// running operation that can be canceled.
public protocol Cancelable: AnyObject {
    func cancel()
}

extension MapboxCommon.Cancelable: Cancelable {}
