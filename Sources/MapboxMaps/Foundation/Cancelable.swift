/// A type that conforms to ``Cancelable`` typically represents a long
/// running operation that can be canceled. Custom implementations
/// must behave correctly if ``Cancelable/cancel()`` is invoked
/// more than once.
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
