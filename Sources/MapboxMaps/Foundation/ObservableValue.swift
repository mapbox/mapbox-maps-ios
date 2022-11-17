import Foundation

/// Wrapper for ``ObservableValue`` to throttle its value updates.
/// Republishes only the latest event received during the time window interval.
internal final class Throttle<Value> where Value: Equatable {
    internal var value: Value?

    private var subscriptions = [BlockSubscription<Value>]()
    private var latestValue: Value? { observableValue.value }

    private let observableValue: ObservableValue<Value>
    private let dispatchQueue: DispatchQueueProtocol
    private let windowDuration: TimeInterval
    private var cancelToken: Cancelable?
    private var item: DispatchWorkItem?

    deinit {
        cancelToken?.cancel()
    }

    internal init(
        value: ObservableValue<Value> = .init(),
        windowDuration: TimeInterval,
        dispatchQueue: DispatchQueueProtocol = DispatchQueue.main
    ) {
        self.observableValue = value
        self.dispatchQueue = dispatchQueue
        self.windowDuration = windowDuration

        cancelToken = observableValue.observe { [weak self] newValue in
            if self?.value == nil { // first update
                self?.notifyImmediately(with: newValue)
            } else {
                self?.onValueUpdated(newValue: newValue)
            }
            return true
        }
    }

    internal func notify(with newValue: Value) {
        observableValue.notify(with: newValue)
    }

    internal func notifyImmediately(with newValue: Value) {
        guard value != newValue else { return }

        item?.cancel()
        item = nil

        self.value = newValue
        self.subscriptions.forEach { subscription in
            subscription.invokeHandler(with: self.value!)
        }
    }

    internal func flush() {
        guard let latestValue = latestValue, value != latestValue else { return }

        notifyImmediately(with: latestValue)
    }

    internal func observe(with handler: @escaping (Value) -> Void) -> Cancelable {
        let observer = BlockSubscription<Value> { _, value in
            handler(value)
        }
        subscriptions.append(observer)

        return BlockCancelable { [weak self] in
            self?.subscriptions.removeAll { $0 === observer }
        }
    }

    private func onValueUpdated(newValue: Value) {
        guard item == nil else { return }

        let item = DispatchWorkItem { [weak self] in
            guard let self = self else { return }

            self.value = self.latestValue
            self.subscriptions.forEach { subscription in
                subscription.invokeHandler(with: self.value!)
            }
            self.item = nil
        }

        self.item = item
        dispatchQueue.asyncAfter(deadline: .now() + windowDuration, execute: item)
    }
}

internal final class ObservableValue<Value> where Value: Equatable {
    private var subscriptions = [BlockSubscription<Value>]() {
        didSet {
            if !subscriptions.isEmpty, oldValue.isEmpty {
                onFirstSubscribe?()
            } else if subscriptions.isEmpty, !oldValue.isEmpty {
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
        subscriptions.forEach { (observer) in
            observer.invokeHandler(with: newValue)
        }
    }

    internal func observe(with handler: @escaping (Value) -> Bool) -> Cancelable {
        let observer = BlockSubscription<Value> { [weak self] (observer, value) in
            // handler returns false if it wants to stop receiving updates
            if !handler(value) {
                self?.subscriptions.removeAll { $0 === observer }
            }
        }
        subscriptions.append(observer)
        if let value = value {
            observer.invokeHandler(with: value)
        }
        return BlockCancelable { [weak self] in
            self?.subscriptions.removeAll { $0 === observer }
        }
    }

    internal var onFirstSubscribe: (() -> Void)?

    internal var onLastUnsubscribe: (() -> Void)?
}

fileprivate final class BlockSubscription<Value> where Value: Equatable {
    private let handler: (BlockSubscription, Value) -> Void

    internal init(handler: @escaping (BlockSubscription, Value) -> Void) {
        self.handler = handler
    }

    internal func invokeHandler(with value: Value) {
        handler(self, value)
    }
}
