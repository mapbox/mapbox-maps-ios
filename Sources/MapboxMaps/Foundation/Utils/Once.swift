import Foundation

/// ``Once`` ensures that its operation will be executed exactly once until it is reset.
///
/// ```
/// var once = Once()
/// once {
///     // This code will be executed exactly once.
/// }
/// once.reset() // Reset Once will make sure the next operation can be executed.
/// ```
struct Once {
    private(set) var happened: Bool

    init(happened: Bool = false) {
        self.happened = happened
    }

    mutating func reset() {
        happened = false
    }

    mutating func reset(if condition: Bool) {
        if condition {
            happened = false
        }
    }

    mutating func callAsFunction(_ action: () throws -> Void) rethrows {
        guard continueOnce() else { return }

        try action()
    }

    /// Checks if the condition is not happened.
    ///
    /// Use this method with guard:
    ///
    ///    ```swift
    ///    guard once.continueOnce() else { return }
    ///    // code here will be executed only once, or until once is reset.
    ///    ```
    mutating func continueOnce() -> Bool {
        if happened {
            return false
        } else {
            happened = true
            return true
        }
    }
}
