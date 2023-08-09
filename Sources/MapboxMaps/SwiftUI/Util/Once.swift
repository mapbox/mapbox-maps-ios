import Foundation

/// ``Once`` ensures that its operation will be executed exactly once until it is reset.
/// ```
/// var once = Once()
/// once {
///     // This code will be executed exactly once.
/// }
/// once.reset() // Reset Once will make sure the next operation can be executed.
/// ```
struct Once {
    private var happened = false

    mutating func reset() {
        happened = false
    }

    mutating func reset(if condition: Bool) {
        if condition {
            happened = false
        }
    }

    mutating func callAsFunction(_ action: () throws -> Void) rethrows {
        guard !happened else { return }

        happened = true
        try action()
    }
}
