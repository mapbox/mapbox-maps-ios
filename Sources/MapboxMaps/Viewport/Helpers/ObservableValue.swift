internal final class ObservableValue<T> where T: Equatable {
    private var observers = [ObservableValueObserver<T>]()

    private var latestValue: T?

    internal func notify(with value: T) {
        guard value != latestValue else {
            return
        }
        observers.forEach { (observer) in
            observer.invokeHandler(with: value)
        }
        latestValue = value
    }

    internal func observe(with handler: @escaping (T) -> Bool) -> Cancelable {
        let observer = ObservableValueObserver<T> { [weak self] (observer, value) in
            // handler returns false if it wants to stop receiving updates
            if !handler(value) {
                self?.observers.removeAll { $0 === observer }
            }
        }
        observers.append(observer)
        if let value = latestValue {
            observer.invokeHandler(with: value)
        }
        return BlockCancelable { [weak self] in
            self?.observers.removeAll { $0 === observer }
        }
    }
}

private final class ObservableValueObserver<T> {
    private let handler: (ObservableValueObserver<T>, T) -> Void

    internal init(handler: @escaping (ObservableValueObserver<T>, T) -> Void) {
        self.handler = handler
    }

    internal func invokeHandler(with value: T) {
        handler(self, value)
    }
}
