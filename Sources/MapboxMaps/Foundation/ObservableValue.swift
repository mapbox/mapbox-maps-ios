internal final class ObservableValue<Value> where Value: Equatable {
    private var observers = [Observer]()

    internal private(set) var value: Value?

    internal func notify(with newValue: Value) {
        guard newValue != value else {
            return
        }
        observers.forEach { (observer) in
            observer.invokeHandler(with: newValue)
        }
        value = newValue
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
