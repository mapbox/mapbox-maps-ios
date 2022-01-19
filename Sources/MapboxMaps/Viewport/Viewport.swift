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

    // defaults to .idle
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
    // failed for some reason), the status will be set to .idle.
    //
    // transitioning to state x when status equals .state(x) just
    // invokes completion synchronously with `true` and does not modify status
    //
    // transitioning to state x when status equals .transition(_, _, x) just
    // invokes completion synchronously with `false` and does not modify status
    public func transition(to toState: ViewportState,
                           transition: ViewportTransition? = nil,
                           completion: ((Bool) -> Void)? = nil) {
        impl.transition(to: toState, transition: transition, completion: completion)
    }

    // MARK: - Transitions

    // this transition is used unless overridden by one of the registered transitions
    public var defaultTransition: ViewportTransition {
        get { impl.defaultTransition }
        set { impl.defaultTransition = newValue }
    }

    // factory methods

    public func makeFollowPuckViewportState(options: FollowPuckViewportStateOptions = .init()) -> FollowPuckViewportState {
        return FollowPuckViewportState(
            dataSource: FollowPuckViewportStateDataSource(
                options: options,
                locationProducer: locationProducer,
                observableCameraOptions: ObservableCameraOptions()),
            cameraAnimationsManager: cameraAnimationsManager)
    }

    public func makeOverviewViewportState(options: OverviewViewportStateOptions) -> OverviewViewportState {
        return OverviewViewportState(
            options: options,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager,
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
