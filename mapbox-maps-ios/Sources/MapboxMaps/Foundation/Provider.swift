import Foundation

/// Stores a value as closure, which is called on every value access.
internal struct Provider<Value> {
    private let closure: () -> Value

    internal var value: Value { closure() }

    internal init(_ closure: @escaping () -> Value) {
        self.closure = closure
    }
}

extension Provider where Value: AnyObject {
    /// Creates a provider that weakly caches the value returned from the original Provider.
    internal func weaklyCached() -> Provider<Value> {
        weak var cache: Value?
        return Provider { [closure] in
            if let cache = cache {
                return cache
            }
            let value = closure()
            cache = value
            return value
        }
    }
}

extension Provider where Value == UIApplication.State {
    @available(iOSApplicationExtension, unavailable)
    static let global = Provider { UIApplication.shared.applicationState }
}
