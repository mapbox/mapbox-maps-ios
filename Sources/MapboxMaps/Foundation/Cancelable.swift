import Foundation

/// A type that conforms to `Cancelable` typically represents a long
/// running operation that can be canceled.
public protocol Cancelable: AnyObject {
    func cancel()
}

internal final class CommonCancelableWrapper: Cancelable {
    private let cancelable: MapboxCommon.Cancelable

    internal init(_ cancelable: MapboxCommon.Cancelable) {
        self.cancelable = cancelable
    }

    internal func cancel() {
        cancelable.cancel()
    }
}

extension MapboxCommon.Cancelable {
    internal func asCancelable() -> Cancelable {
        return CommonCancelableWrapper(self)
    }
}
