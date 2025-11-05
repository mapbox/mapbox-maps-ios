import QuartzCore

/// A protocol that abstracts the display link functionality for rendering synchronization.
///
/// `DisplayLinkProtocol` provides a unified interface for display link operations,
/// allowing the map view to work with different display link implementations.
/// This abstraction is particularly useful for testing and dependency injection.
///
/// The protocol wraps the core functionality of `CADisplayLink`, providing:
/// - Frame timing information for smooth animations
/// - Frame rate control for performance optimization
/// - Lifecycle management for rendering loops
///
/// - SeeAlso: `CADisplayLink` for the concrete implementation used in production.
internal protocol DisplayLinkProtocol: AnyObject {

    /// The timestamp of the current frame, measured in seconds since system startup.
    ///
    /// This value is typically used to calculate frame deltas for smooth animations
    /// and to synchronize rendering with the display refresh rate.
    var timestamp: CFTimeInterval { get }

    /// The duration of the previous frame, measured in seconds.
    ///
    /// This value represents the time it took to render the previous frame and can be
    /// used for performance monitoring and adaptive frame rate adjustments.
    var duration: CFTimeInterval { get }

    /// The preferred number of frames per second for the display link.
    ///
    /// Setting this property allows you to control the rendering frequency,
    /// which can help balance performance and visual quality. The actual frame rate
    /// may be lower than the preferred rate depending on system performance.
    var preferredFramesPerSecond: Int { get set }

    /// The preferred frame rate range for the display link.
    ///
    /// This property provides more granular control over frame rate than
    /// `preferredFramesPerSecond`, allowing you to specify both minimum and maximum
    /// frame rates for adaptive performance.
    ///
    /// - Note: Available on iOS 15.0 and later.
    @available(iOS 15.0, *)
    var preferredFrameRateRange: CAFrameRateRange { get set }

    /// A boolean value indicating whether the display link is currently running.
    ///
    /// When `true`, the display link will fire callbacks at the specified frame rate.
    /// When `false`, the display link is paused and no callbacks will be fired.
    /// This property is essential for managing rendering lifecycle and performance.
    var isRunning: Bool { get set }

    /// Adds the display link to the specified run loop and mode.
    ///
    /// This method starts the display link by adding it to the run loop, which will
    /// begin firing callbacks at the specified frame rate.
    ///
    /// - Parameters:
    ///   - runloop: The run loop to add the display link to.
    ///   - mode: The run loop mode for the display link.
    func add(to runloop: RunLoop, forMode mode: RunLoop.Mode)

    /// Invalidates the display link and removes it from the run loop.
    ///
    /// This method stops the display link and cleans up its resources.
    /// After calling this method, the display link cannot be restarted.
    func invalidate()
}

extension CADisplayLink: DisplayLinkProtocol {
    /// A computed property that maps the display link's paused state to a running state.
    ///
    /// This extension provides a more intuitive interface by converting the native
    /// `isPaused` property to a positive `isRunning` boolean. When `isRunning` is
    /// `true`, the display link is active and firing callbacks. When `false`,
    /// the display link is paused and not firing callbacks.
    ///
    /// - Note: This is a convenience wrapper around the native `isPaused` property.
    var isRunning: Bool {
        get { !isPaused }
        set { isPaused = !newValue }
    }
}
