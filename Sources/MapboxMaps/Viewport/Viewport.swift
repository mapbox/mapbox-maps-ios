/// `Viewport` provides a structured approach to organizing camera management logic into states and
/// transitions between them.
///
/// At any given time, the viewport is either:
///
///  - idle (not updating the camera)
///  - in a state (camera is being managed by a ``ViewportState``)
///  - transitioning (camera is being managed by a ``ViewportTransition``)
public final class Viewport {

    /// Configuration options for adjusting the viewport's behavior.
    public var options: ViewportOptions {
        get { impl.options }
        set { impl.options = newValue }
    }

    private let impl: ViewportImplProtocol
    private let interpolatedLocationProducer: InterpolatedLocationProducerProtocol
    private let cameraAnimationsManager: CameraAnimationsManagerProtocol
    private let mapboxMap: MapboxMapProtocol

    internal init(impl: ViewportImplProtocol,
                  interpolatedLocationProducer: InterpolatedLocationProducerProtocol,
                  cameraAnimationsManager: CameraAnimationsManagerProtocol,
                  mapboxMap: MapboxMapProtocol) {
        self.impl = impl
        self.interpolatedLocationProducer = interpolatedLocationProducer
        self.cameraAnimationsManager = cameraAnimationsManager
        self.mapboxMap = mapboxMap
    }

    /// The current ``ViewportStatus``.
    ///
    /// `status` cannot be set directly. Use
    /// ``Viewport/transition(to:transition:completion:)`` and ``Viewport/idle()`` to
    /// transition to a state or to idle.
    ///
    /// Defaults to ``ViewportStatus/idle``.
    ///
    /// - SeeAlso:
    ///   - ``Viewport/addStatusObserver(_:)``
    ///   - ``Viewport/removeStatusObserver(_:)``
    public var status: ViewportStatus {
        impl.status
    }

    /// Subscribes a ``ViewportStatusObserver`` to ``Viewport/status`` changes.
    ///
    /// Viewport keeps a strong reference to registered observers. Adding the same observer again while it is already subscribed has no effect.
    ///
    /// - Note: Observers are notified of status changes asynchronously on the main queue. This means that by
    /// the time the notification is delivered, the status may have already changed again. This behavior is necessary to allow
    /// observers to trigger further transitions while avoiding out-of-order delivery of status changed notifications.
    /// - Parameter observer: An object that will be notified when the ``Viewport/status`` changes.
    /// - SeeAlso: ``Viewport/removeStatusObserver(_:)``
    public func addStatusObserver(_ observer: ViewportStatusObserver) {
        impl.addStatusObserver(observer)
    }

    /// Unsubscribes a ``ViewportStatusObserver`` from ``Viewport/status`` changes. This causes viewport
    /// to release its strong reference to the observer. Removing an observer that is not subscribed has no effect.
    ///
    /// - Parameter observer: An object that should no longer be notified when the ``Viewport/status`` changes.
    /// - SeeAlso: ``Viewport/addStatusObserver(_:)``
    public func removeStatusObserver(_ observer: ViewportStatusObserver) {
        impl.removeStatusObserver(observer)
    }

    /// Sets ``Viewport/status`` to ``ViewportStatus/idle`` synchronously.
    ///
    /// This cancels any active ``ViewportState`` or ``ViewportTransition``.
    public func idle() {
        impl.idle()
    }

    /// Executes a transition to the requested state.
    ///
    /// If the transition fails, ``Viewport/status`` is set to ``ViewportStatus/idle``.
    ///
    /// Transitioning to state `x` when the status is `.state(x)` invokes `completion`
    /// synchronously with `true` and does not modify ``Viewport/status``.
    ///
    /// Transitioning to state `x` when the status is `.transition(_, x)` invokes `completion`
    /// synchronously with `false` and does not modify ``Viewport/status``.
    ///
    /// `Viewport` keeps a strong reference to active transitions and states. To reuse states and transitions,
    /// keep strong references to them in the consuming project.
    ///
    /// - Parameters:
    ///   - toState: The target ``ViewportState`` to transition to.
    ///   - transition: The ``ViewportTransition`` that is used to transition to the target state.
    ///                 If `nil`, ``Viewport/defaultTransition`` is used. Defaults to `nil`.
    ///   - completion: A closure that is invoked when the transition ends. Defaults to `nil`.
    ///   - success: Whether the transition ran to completion. Transitions may end early if they fail or
    ///              are interrupted (e.g. by another call to
    ///              `transition(to:transition:completion:)` or ``Viewport/idle()``)
    public func transition(to toState: ViewportState,
                           transition: ViewportTransition? = nil,
                           completion: ((_ success: Bool) -> Void)? = nil) {
        impl.transition(to: toState, transition: transition, completion: completion)
    }

    /// ``Viewport/transition(to:transition:completion:)`` uses this transition unless
    /// some non-nil value is passed to its `transition` argument.
    ///
    /// Defaults to ``DefaultViewportTransition`` with default options.
    public var defaultTransition: ViewportTransition {
        get { impl.defaultTransition }
        set { impl.defaultTransition = newValue }
    }

    /// Creates a new instance of ``FollowPuckViewportState`` with the specified options.
    /// - Parameter options: configuration options used when creating ``FollowPuckViewportState``. Defaults to
    ///                      ``FollowPuckViewportStateOptions/init(padding:zoom:bearing:pitch:animationDuration:)``
    ///                      with the default value specified for all parameters.
    /// - Returns: The newly-created ``FollowPuckViewportState``.
    public func makeFollowPuckViewportState(options: FollowPuckViewportStateOptions = .init()) -> FollowPuckViewportState {
        return FollowPuckViewportState(
            dataSource: FollowPuckViewportStateDataSource(
                options: options,
                interpolatedLocationProducer: interpolatedLocationProducer,
                observableCameraOptions: ObservableCameraOptions()),
            mapboxMap: mapboxMap)
    }

    /// Creates a new instance of ``OverviewViewportState`` with the specified options.
    /// - Parameter options: configuration options used when creating ``OverviewViewportState``.
    /// - Returns: The newly-created ``OverviewViewportState``.
    public func makeOverviewViewportState(options: OverviewViewportStateOptions) -> OverviewViewportState {
        return OverviewViewportState(
            options: options,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager,
            observableCameraOptions: ObservableCameraOptions())
    }

    /// Creates a new instance of ``DefaultViewportTransition``.
    /// - Parameter options: configuration options used when creating ``DefaultViewportTransition``. Defaults to
    ///                      ``DefaultViewportTransitionOptions/init(maxDuration:)`` with the default value specified for all parameters
    /// - Returns: The newly-created ``DefaultViewportTransition``.
    public func makeDefaultViewportTransition(options: DefaultViewportTransitionOptions = .init()) -> DefaultViewportTransition {
        let lowZoomToHighZoomAnimationSpecProvider = LowZoomToHighZoomAnimationSpecProvider(
            mapboxMap: mapboxMap)
        let highZoomToLowZoomAnimationSpecProvider = HighZoomToLowZoomAnimationSpecProvider()
        let animationSpecProvider = DefaultViewportTransitionAnimationSpecProvider(
            mapboxMap: mapboxMap,
            lowZoomToHighZoomAnimationSpecProvider: lowZoomToHighZoomAnimationSpecProvider,
            highZoomToLowZoomAnimationSpecProvider: highZoomToLowZoomAnimationSpecProvider)
        let animationFactory = DefaultViewportTransitionAnimationFactory(
            mapboxMap: mapboxMap)
        let animationHelper = DefaultViewportTransitionAnimationHelper(
            mapboxMap: mapboxMap,
            animationSpecProvider: animationSpecProvider,
            cameraAnimationsManager: cameraAnimationsManager,
            animationFactory: animationFactory)
        return DefaultViewportTransition(
            options: options,
            animationHelper: animationHelper)
    }

    /// Creates a new instance of ``ImmediateViewportTransition``.
    /// - Returns: The newly-created ``ImmediateViewportTransition``.
    public func makeImmediateViewportTransition() -> ImmediateViewportTransition {
        return ImmediateViewportTransition(mapboxMap: mapboxMap)
    }
}
