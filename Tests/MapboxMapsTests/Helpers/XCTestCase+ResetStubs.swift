import XCTest

extension XCTestCase {
    /// Reset all stubs in inner properties
    ///
    /// Interates through reflection of current `XCTestCase` and lookup
    /// for `StubProtocol` properties. Then call `reset()` for each of them.
    func resetAllStubs() {
        Mirror(reflecting: self).children
            .flatMap { (_, value) -> Mirror.Children in
                // If value is Optional, carefully unwrap it to get a Wrapped type
                let innerValue = (value as? OptionalProtocol)?.anyValue ?? value
                assert(!(innerValue is OptionalProtocol))
                return Mirror(reflecting: innerValue).children
            }
            .compactMap { $0.value as? StubProtocol }
            .forEach { $0.reset() }
    }
}

/// Protocol to enable non-typed access to detect Optionals
protocol OptionalProtocol {
    var anyValue: Any? { get }
}

extension Optional: OptionalProtocol {
    var anyValue: Any? { return self }
}
