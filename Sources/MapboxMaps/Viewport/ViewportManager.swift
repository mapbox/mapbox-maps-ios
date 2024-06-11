import UIKit

/// `Viewport` provides a structured approach to organizing camera management logic into states and
/// transitions between them.
///
/// At any given time, the viewport is either:
///
///  - idle (not updating the camera)
///  - in a state (camera is being managed by a ``ViewportState``)
///  - transitioning (camera is being managed by a ``ViewportTransition``)
public final class ViewportManager {

    /// Configuration options for adjusting the viewport's behavior.
    public var options: ViewportOptions {
        get { impl.options }
        set { impl.options = newValue }
    }

    private let impl: ViewportManagerImplProtocol
    private let onPuckRender: Signal<PuckRenderingData>
    private let cameraAnimationsManager: CameraAnimationsManagerProtocol
    private let mapboxMap: MapboxMapProtocol
    private let styleManager: StyleProtocol

    internal init(impl: ViewportManagerImplProtocol,
                  onPuckRender: Signal<PuckRenderingData>,
                  cameraAnimationsManager: CameraAnimationsManagerProtocol,
                  mapboxMap: MapboxMapProtocol,
                  styleManager: StyleProtocol) {
        self.impl = impl
        self.onPuckRender = onPuckRender
        self.cameraAnimationsManager = cameraAnimationsManager
        self.mapboxMap = mapboxMap
        self.styleManager = styleManager
    }

    /// The current ``ViewportStatus``.
    ///
    /// `status` cannot be set directly. Use
    /// ``ViewportManager/transition(to:transition:completion:)`` and ``ViewportManager/idle()`` to
    /// transition to a state or to idle.
    ///
    /// Defaults to ``ViewportStatus/idle``.
    ///
    /// - SeeAlso:
    ///   - ``ViewportManager/addStatusObserver(_:)``
    ///   - ``ViewportManager/removeStatusObserver(_:)``
    public var status: ViewportStatus {
        impl.status
    }

    /// Subscribes a ``ViewportStatusObserver`` to ``ViewportManager/status`` changes.
    ///
    /// Viewport keeps a strong reference to registered observers. Adding the same observer again while it is already subscribed has no effect.
    ///
    /// - Note: Observers are notified of status changes asynchronously on the main queue. This means that by
    /// the time the notification is delivered, the status may have already changed again. This behavior is necessary to allow
    /// observers to trigger further transitions while avoiding out-of-order delivery of status changed notifications.
    /// - Parameter observer: An object that will be notified when the ``ViewportManager/status`` changes.
    /// - SeeAlso: ``ViewportManager/removeStatusObserver(_:)``
    public func addStatusObserver(_ observer: ViewportStatusObserver) {
        impl.addStatusObserver(observer)
    }

    /// Unsubscribes a ``ViewportStatusObserver`` from ``ViewportManager/status`` changes. This causes viewport
    /// to release its strong reference to the observer. Removing an observer that is not subscribed has no effect.
    ///
    /// - Parameter observer: An object that should no longer be notified when the ``ViewportManager/status`` changes.
    /// - SeeAlso: ``ViewportManager/addStatusObserver(_:)``
    public func removeStatusObserver(_ observer: ViewportStatusObserver) {
        impl.removeStatusObserver(observer)
    }

    /// Sets ``ViewportManager/status`` to ``ViewportStatus/idle`` synchronously.
    ///
    /// This cancels any active ``ViewportState`` or ``ViewportTransition``.
    public func idle() {
        impl.idle()
    }

    /// Executes a transition to the requested state.
    ///
    /// If the transition fails, ``ViewportManager/status`` is set to ``ViewportStatus/idle``.
    ///
    /// Transitioning to state `x` when the status is `.state(x)` invokes `completion`
    /// synchronously with `true` and does not modify ``ViewportManager/status``.
    ///
    /// Transitioning to state `x` when the status is `.transition(_, x)` invokes `completion`
    /// synchronously with `false` and does not modify ``ViewportManager/status``.
    ///
    /// `Viewport` keeps a strong reference to active transitions and states. To reuse states and transitions,
    /// keep strong references to them in the consuming project.
    ///
    /// - Parameters:
    ///   - toState: The target ``ViewportState`` to transition to.
    ///   - transition: The ``ViewportTransition`` that is used to transition to the target state.
    ///                 If `nil`, ``ViewportManager/defaultTransition`` is used. Defaults to `nil`.
    ///   - completion: A closure that is invoked when the transition ends. Defaults to `nil`.
    public func transition(to toState: ViewportState,
                           transition: ViewportTransition? = nil,
                           completion: ((_ success: Bool) -> Void)? = nil) {
        sendTelemetry(\.viewportTransition)
        impl.transition(to: toState, transition: transition, completion: completion)
    }

    /// ``ViewportManager/transition(to:transition:completion:)`` uses this transition unless
    /// some non-nil value is passed to its `transition` argument.
    ///
    /// Defaults to ``DefaultViewportTransition`` with default options.
    public var defaultTransition: ViewportTransition {
        get { impl.defaultTransition }
        set { impl.defaultTransition = newValue }
    }

    /// Creates a camera viewport state.
    ///
    /// The camera viewport state sets the specified camera options only once.
    /// Additionally, it maintains the camera padding in sync with safe area insets.
    ///
    /// Use this state to set camera options instead of ``MapboxMap/setCamera(to:)``
    /// if you use experimental ``ViewportOptions/usesSafeAreaInsetsAsPadding``.
    @_documentation(visibility: public)
    @_spi(Experimental)
    public func makeCameraViewportState(camera: CameraOptions) -> ViewportState {
        sendTelemetry(\.viewportCameraState)
        return CameraViewportState(cameraOptions: Signal(just: camera), mapboxMap: mapboxMap, safeAreaPadding: impl.safeAreaPadding)
    }

    func makeDefaultStyleViewportState(padding: UIEdgeInsets) -> ViewportState {
        CameraViewportState
            .defaultStyleViewport(with: padding, styleManager: styleManager, mapboxMap: mapboxMap, safeAreaPadding: impl.safeAreaPadding)
    }

    /// Creates a new instance of ``FollowPuckViewportState`` with the specified options.
    /// - Parameter options: configuration options used when creating ``FollowPuckViewportState``. Defaults to
    ///                      ``FollowPuckViewportStateOptions/init(padding:zoom:bearing:pitch:)``
    ///                      with the default value specified for all parameters.
    /// - Returns: The newly-created ``FollowPuckViewportState``.
    public func makeFollowPuckViewportState(options: FollowPuckViewportStateOptions = .init()) -> FollowPuckViewportState {
        sendTelemetry(\.viewportFollowState)
        return FollowPuckViewportState(
            options: options,
            mapboxMap: mapboxMap,
            onPuckRender: onPuckRender,
            safeAreaPadding: impl.safeAreaPadding)
    }

    /// Creates a new instance of ``OverviewViewportState`` with the specified options.
    /// - Parameter options: configuration options used when creating ``OverviewViewportState``.
    /// - Returns: The newly-created ``OverviewViewportState``.
    public func makeOverviewViewportState(options: OverviewViewportStateOptions) -> OverviewViewportState {
        sendTelemetry(\.viewportOverviewState)
        return OverviewViewportState(
            options: options,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager,
            safeAreaPadding: impl.safeAreaPadding)
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

protocol ViewportManagerProtocol {
    var options: ViewportOptions { get set }
    func addStatusObserver(_ observer: ViewportStatusObserver)
    func removeStatusObserver(_ observer: ViewportStatusObserver)
    func idle()
    func transition(to toState: ViewportState, transition: ViewportTransition?, completion: ((Bool) -> Void)?)
    func makeImmediateViewportTransition() -> ViewportTransition
}

extension ViewportManager: ViewportManagerProtocol {
    func makeImmediateViewportTransition() -> ViewportTransition {
        let transition: ImmediateViewportTransition = makeImmediateViewportTransition()
        return transition
    }
}
