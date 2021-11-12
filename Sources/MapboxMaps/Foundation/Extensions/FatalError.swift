import Foundation

// From https://stackoverflow.com/a/68496755
// Override the Swift `fatalError`. This allows us to unit test code that results in a
// fatal error.
internal func fatalError(_ message: @autoclosure () -> String = String(), file: StaticString = #file, line: UInt = #line) -> Never {
    FatalErrorUtil.fatalErrorClosure(message(), file, line)
}

/// Utility functions that can replace and restore the `fatalError` global function.
internal enum FatalErrorUtil {
    internal typealias FatalErrorClosureType = (String, StaticString, UInt) -> Never
    /// Called by the custom implementation of `fatalError`.
    fileprivate static var fatalErrorClosure: FatalErrorClosureType = defaultFatalErrorClosure

    /// Store the original Swift `fatalError`
    private static let defaultFatalErrorClosure: FatalErrorClosureType = { Swift.fatalError($0, file: $1, line: $2) }

    /// Replace the Swift `fatalError` global function with a closure.
    internal static func replaceFatalError(closure: @escaping FatalErrorClosureType) {
        fatalErrorClosure = closure
    }

    /// Restore the `fatalError` global function back to the original Swift implementation
    internal static func restoreFatalError() {
        fatalErrorClosure = defaultFatalErrorClosure
    }
}
