import MapboxCommon

extension Cancelable {
    internal var erased: AnyCancelable {
        return AnyCancelable(self)
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
