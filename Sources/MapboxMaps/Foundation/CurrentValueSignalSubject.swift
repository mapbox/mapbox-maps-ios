/// A signal subject, that caches the current value.
///
/// Every new observer of ``CurrentValueSignalSubject/signal`` will receive the current value right away.
///
/// Example:
///     ```swift
///     var subject = CurrentValueSignalSubject(value: 5)
///     let token = subject.signal.observe {
///         print($0)
///     }
///     subject.value = 0
///
///     // Output: 5, 0
///     ```
/// Conceptually, this is iOS 12-compatible alternative to Combine's `CurrentValueSubject`.
internal class CurrentValueSignalSubject<Value> {
    typealias ObservationHandler = (Bool) -> Void
    private let store = ClosureHandlersStore<Value, Void>()

    var signal: Signal<Value> {
        Signal { [weak self] handler in
            guard let self else { return .empty }
            defer {
                // Send the first value upon observing.
                handler(self.value)
            }
            return self.store.add(handler: handler)
        }
    }
    var value: Value {
        didSet {
            store.send(value)
        }
    }

    var onObserved: ObservationHandler? {
        get { store.onObserved }
        set { store.onObserved = newValue }
    }

    /// Creates the subject with an initial value.
    ///
    /// - Parameters:
    ///    - value: Initial value.
    init(_ value: Value) {
        self.value = value
    }
}

extension CurrentValueSignalSubject where Value: ExpressibleByNilLiteral {
    convenience init() {
        self.init(nil)
    }
}

extension CurrentValueSignalSubject where Value: ExpressibleByArrayLiteral {
    convenience init() {
        self.init([])
    }
}
