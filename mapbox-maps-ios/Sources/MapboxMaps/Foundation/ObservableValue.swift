internal final class ObservableValue<Value> where Value: Equatable {
    private var observers = [Observer]() {
        didSet {
            if !observers.isEmpty, oldValue.isEmpty {
                onFirstSubscribe?()
            } else if observers.isEmpty, !oldValue.isEmpty {
                onLastUnsubscribe?()
            }
        }
    }

    internal private(set) var value: Value?

    internal func notify(with newValue: Value) {
        guard newValue != value else {
            return
        }
        value = newValue
        observers.forEach { (observer) in
            observer.invokeHandler(with: newValue)
        }
    }

    internal func observe(with handler: @escaping (Value) -> Bool) -> Cancelable {
        let observer = Observer { [weak self] (observer, value) in
            // handler returns false if it wants to stop receiving updates
            if !handler(value) {
                self?.observers.removeAll { $0 === observer }
            }
        }
        observers.append(observer)
        if let value = value {
            observer.invokeHandler(with: value)
        }
        return BlockCancelable { [weak self] in
            self?.observers.removeAll { $0 === observer }
        }
    }

    internal var onFirstSubscribe: (() -> Void)?

    internal var onLastUnsubscribe: (() -> Void)?

    private final class Observer {
        private let handler: (Observer, Value) -> Void

        internal init(handler: @escaping (Observer, Value) -> Void) {
            self.handler = handler
        }

        internal func invokeHandler(with value: Value) {
            handler(self, value)
        }
    }
}
