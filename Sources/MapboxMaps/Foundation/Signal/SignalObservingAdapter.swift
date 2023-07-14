internal final class SignalObservingAdapter<ObserverType, Value> {
    private let signal: Signal<Value>
    private let notify: (ObserverType, Value) -> Void

    private var tokens = [ObjectIdentifier: AnyCancelable]()

    init(signal: Signal<Value>, notify: @escaping (ObserverType, Value) -> Void) {
        self.signal = signal
        self.notify = notify
    }

    func add(observer: ObserverType) {
        let observer = observer as AnyObject
        let notify = self.notify
        let identifier = ObjectIdentifier(observer)
        tokens[identifier] = signal.observe { [weak observer] value in
            if let observer = observer as? ObserverType {
                notify(observer, value)
            }
        }
    }

    func remove(observer: ObserverType) {
        tokens.removeValue(forKey: ObjectIdentifier(observer as AnyObject))
    }
}
