import QuartzCore

/// A target object that forwards display link callbacks to a closure-based handler.
///
/// `ForwardingDisplayLinkTarget` acts as a bridge between the Objective-C based
/// `CADisplayLink` callback mechanism and Swift closure-based handlers. This allows
/// for more flexible and testable display link management without requiring
/// Objective-C selectors or target-action patterns.
///
/// The class is designed to be used as a target for `CADisplayLink`, forwarding
/// all update callbacks to the provided closure handler.
internal final class ForwardingDisplayLinkTarget {

    /// The closure that will be called when the display link fires.
    private let handler: (CADisplayLink) -> Void

    /// Creates a new forwarding target with the specified handler.
    ///
    /// - Parameter handler: The closure to call when the display link updates.
    ///   The closure receives the `CADisplayLink` instance that triggered the update.
    internal init(handler: @escaping (CADisplayLink) -> Void) {
        self.handler = handler
    }

    /// Called by the display link when it fires.
    ///
    /// This method is marked with `@objc` to be compatible with the Objective-C
    /// target-action mechanism used by `CADisplayLink`. It forwards the call
    /// to the stored closure handler.
    ///
    /// - Parameter displayLink: The display link that triggered this update.
    @objc internal func update(with displayLink: CADisplayLink) {
        handler(displayLink)
    }
}
