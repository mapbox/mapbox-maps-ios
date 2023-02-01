internal final class CancelableContainer {
    private var cancelables = [ObjectIdentifier: Cancelable]()

    deinit {
        for cancelable in cancelables.values {
            cancelable.cancel()
        }
    }

    internal func add(_ cancelable: Cancelable) {
        cancelables[ObjectIdentifier(cancelable)] = cancelable
    }

    internal func cancelAll() {
        let cancelables = cancelables
        self.cancelables.removeAll()
        for cancelable in cancelables.values {
            cancelable.cancel()
        }
    }
}

internal extension Cancelable {
    func add(to container: CancelableContainer) {
        container.add(self)
    }
}
