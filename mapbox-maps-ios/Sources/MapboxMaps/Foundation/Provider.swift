import Foundation

internal struct Provider<Value> {
    private let closure: () -> Value

    internal var value: Value { closure() }

    internal init(_ closure: @autoclosure @escaping () -> Value) {
        self.closure = closure
    }
}

extension Provider where Value == UIApplication.State {
    @available(iOSApplicationExtension, unavailable)
    static let global = Provider(UIApplication.shared.applicationState)
}
