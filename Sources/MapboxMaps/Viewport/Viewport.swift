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

    // the list of states
    public var states: [ViewportState] {
        impl.states
    }

    // adds state to the list of states
    // adding the same state more than once has no effect
    public func addState(_ state: ViewportState) {
        impl.addState(state)
    }

    // removes state from list of states
    // sets current state to nil if it was identical to state
    // attempting to remove a state that was not added has no effect
    // any active transition to that state will also be canceled
    public func removeState(_ state: ViewportState) {
        impl.removeState(state)
    }

    // MARK: - Current State

    // a nil status is known as "idle"; this is the default
    public var status: ViewportStatus? {
        impl.status
    }

    public func idle() {
        impl.idle()
    }

    // set
    // the Bool in the completion block indicates whether the transition ran to
    // completion (true) or was interrupted by another transition (false)
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
