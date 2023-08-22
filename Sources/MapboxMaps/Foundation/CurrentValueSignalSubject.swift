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
    private let passthrough = SignalSubject<Value>()

    let signal: Signal<Value>
    var value: Value {
        didSet {
            passthrough.send(value)
        }
    }

    var onObserved: SignalSubject.ObservationHandler? {
        get { passthrough.onObserved }
        set { passthrough.onObserved = newValue }
    }

    /// Creates the subject with an initial value.
    ///
    /// - Parameters:
    ///    - value: Initial value.
    ///    - onObserved: A callback that receives `true` when the first observer is added, or `false` when last observer is gone.
    init(_ value: Value) {
        self.value = value

        weak var weakSelf: CurrentValueSignalSubject?
        self.signal = Signal<Value>(observeImpl: { handler in
            guard let self = weakSelf else {
                return .empty
            }
            let token = self.passthrough.signal.observe(handler)
            // Send the first value upon observing.
            handler(self.value)
            return token
        })
        weakSelf = self
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
