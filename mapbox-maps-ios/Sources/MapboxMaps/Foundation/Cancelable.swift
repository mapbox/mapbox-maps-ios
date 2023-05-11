/// A protocol that indicates that activity supports cancellation.
///
/// This class has similar meaning as `Combine.Cancellable`, but doesn't require iOS 13.
public protocol Cancelable: AnyObject {
    /// Cancels activity.
    func cancel()
}

extension Cancelable {
    internal var erased: AnyCancelable {
        return AnyCancelable(self)
    }
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

extension MapboxCommon.Cancelable: Cancelable {}

extension MapboxCommon.Cancelable {
    internal func asCancelable() -> Cancelable {
        return CommonCancelableWrapper(self)
    }
}

internal final class BlockCancelable: Cancelable {
    private var block: (() -> Void)?

    internal init(block: @escaping () -> Void) {
        self.block = block
    }

    func cancel() {
        if let b = block {
            block = nil
            b()
        }
    }
}

internal final class CompositeCancelable: Cancelable {
    private var isCanceled = false

    private var cancelables = [Cancelable]()

    internal func add(_ cancelable: Cancelable) {
        if isCanceled {
            cancelable.cancel()
        } else {
            cancelables.append(cancelable)
        }
    }

    internal func cancel() {
        isCanceled = true
        let c = cancelables
        cancelables.removeAll()
        c.forEach { $0.cancel() }
    }
}
