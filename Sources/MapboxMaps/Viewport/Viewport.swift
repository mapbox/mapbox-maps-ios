// provides a structured approach to organizing
// camera management logic into states and transitions between them
//
// at any given time, the viewport is either:
//
//  - idle (not updating the camera)
//  - in a state (camera is being managed by a ViewportState)
//  - transitioning (camera is being managed by a ViewportTransition)
//
public final class Viewport {

    public var options: ViewportOptions {
        get { impl.options }
        set { impl.options = newValue }
    }

    private let impl: ViewportImplProtocol
    private let locationProducer: LocationProducerProtocol
    private let cameraAnimationsManager: CameraAnimationsManagerProtocol
    private let mapboxMap: MapboxMapProtocol

    internal init(impl: ViewportImplProtocol,
                  locationProducer: LocationProducerProtocol,
                  cameraAnimationsManager: CameraAnimationsManagerProtocol,
                  mapboxMap: MapboxMapProtocol) {
        self.impl = impl
        self.locationProducer = locationProducer
        self.cameraAnimationsManager = cameraAnimationsManager
        self.mapboxMap = mapboxMap
    }

    // MARK: - Current State

    // the status .state(nil) is known as "idle"; this is the default
    public var status: ViewportStatus {
        impl.status
    }

    public func addStatusObserver(_ observer: ViewportStatusObserver) {
        impl.addStatusObserver(observer)
    }

    public func removeStatusObserver(_ observer: ViewportStatusObserver) {
        impl.removeStatusObserver(observer)
    }

    public func idle() {
        impl.idle()
    }

    // the Bool in the completion block indicates whether the transition ran to
    // completion (true) or was interrupted in some way (false). if the source
    // of the interruption was because transition(to:completion:) or idle() was
    // invoked, the next status is determined by those interrupting calls. if
    // the source of the interruption was external (e.g. the ViewportTransition
    // failed for some reason), the status will be set to idle (.state(nil)).
    //
    // transitioning to state x when status equals .state(x) just
    // invokes completion synchronously with `true` and does not modify status
    //
    // transitioning to state x when status equals .transition(_, _, x) just
    // invokes completion synchronously with `false` and does not modify status
    public func transition(to toState: ViewportState, completion: ((Bool) -> Void)? = nil) {
        impl.transition(to: toState, completion: completion)
    }

    // MARK: - Transitions

    // this transition is used unless overridden by one of the registered transitions
    public var defaultTransition: ViewportTransition {
        get { impl.defaultTransition }
        set { impl.defaultTransition = newValue }
    }

    // set
    // we allow setting a custom transition from idle (nil) to a state, but
    // there's never a transition when going from some non-nil state to idle.
    public func setTransition(_ transition: ViewportTransition,
                              from fromState: ViewportState?,
                              to toState: ViewportState) {
        impl.setTransition(transition, from: fromState, to: toState)
    }

    // get
    public func getTransition(from fromState: ViewportState?,
                              to toState: ViewportState) -> ViewportTransition? {
        impl.getTransition(from: fromState, to: toState)
    }

    // delete
    public func removeTransition(from fromState: ViewportState?,
                                 to toState: ViewportState) {
        impl.removeTransition(from: fromState, to: toState)
    }

    // factory methods

    public func makeFollowingViewportState(options: FollowingViewportStateOptions = .init()) -> FollowingViewportState {
        return FollowingViewportState(
            dataSource: FollowingViewportStateDataSource(
                options: options,
                locationProducer: locationProducer,
                observableCameraOptions: ObservableCameraOptions()),
            cameraAnimationsManager: cameraAnimationsManager)
    }

    public func makeOverviewViewportState(options: OverviewViewportStateOptions) -> OverviewViewportState {
        return OverviewViewportState(
            options: options,
            mapboxMap: mapboxMap,
            observableCameraOptions: ObservableCameraOptions())
    }

    public func makeDefaultViewportTransition(options: DefaultViewportTransitionOptions = .init()) -> DefaultViewportTransition {
        return DefaultViewportTransition(
            options: options,
            animationHelper: DefaultViewportTransitionAnimationHelper(
                mapboxMap: mapboxMap,
                cameraAnimationsManager: cameraAnimationsManager))
    }

    public func makeImmediateViewportTransition() -> ImmediateViewportTransition {
        return ImmediateViewportTransition(mapboxMap: mapboxMap)
    }
}
