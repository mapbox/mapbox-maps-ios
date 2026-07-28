/// Proxies values from the `proxied` signals.
///
/// Like `CurrentValueSignalSubject`, the proxy maintains the latest seen value cache. If it exists,
/// every new observer will get it right upon observing.
internal class CurrentValueSignalProxy<T> {
    let signal: Signal<T>
    var proxied: Signal<T>? {
        didSet { updateProxiedOserving() }
    }

    private let passthrough = SignalSubject<T>()
    // `value` is written on the emitting thread and read on the subscribing thread (`.subscribe(on:)`).
    private let valueLock = NSLock()
    private var value: T?
    private var token: AnyCancelable?
    private var observed: Bool = false {
        didSet { updateProxiedOserving() }
    }

    init() {
        weak var weakSelf: CurrentValueSignalProxy?
        signal = Signal(observeImpl: { handler in
            weakSelf?.observeImpl(handler) ?? .empty
        })
        passthrough.onObserved = { weakSelf?.observed = $0 }
        weakSelf = self
    }

    private func observeImpl(_ handler: @escaping Signal<T>.Handler) -> AnyCancelable {
        if let value = valueLock.withLock({ value }) {
            handler(value)
        }
        return passthrough.signal.observe { [weak self] payload in
            self?.valueLock.withLock { self?.value = payload }
            handler(payload)
        }
    }

    private func updateProxiedOserving() {
        assert(Thread.isMainThread)
        token = observed ? proxied?.observe(passthrough.send(_:)) : nil
    }
}
