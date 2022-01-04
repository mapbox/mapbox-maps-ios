internal protocol ViewportFactoryProtocol: AnyObject {
    func makeFollowingViewportState(options: FollowingViewportStateOptions) -> FollowingViewportState
    func makeOverviewViewportState(options: OverviewViewportStateOptions) -> OverviewViewportState
    func makeDefaultViewportTransition(options: DefaultViewportTransitionOptions) -> DefaultViewportTransition
    func makeImmediateViewportTransition() -> ImmediateViewportTransition
}

internal final class ViewportFactory: ViewportFactoryProtocol {

    private let locationProducer: LocationProducerProtocol
    private let cameraAnimationsManager: CameraAnimationsManagerProtocol
    private let mapboxMap: MapboxMapProtocol

    internal init(locationProducer: LocationProducerProtocol,
                  cameraAnimationsManager: CameraAnimationsManagerProtocol,
                  mapboxMap: MapboxMapProtocol) {
        self.locationProducer = locationProducer
        self.cameraAnimationsManager = cameraAnimationsManager
        self.mapboxMap = mapboxMap
    }

    internal func makeFollowingViewportState(options: FollowingViewportStateOptions) -> FollowingViewportState {
        return FollowingViewportState(
            options: options,
            locationProducer: locationProducer,
            cameraAnimationsManager: cameraAnimationsManager)
    }

    internal func makeOverviewViewportState(options: OverviewViewportStateOptions) -> OverviewViewportState {
        return OverviewViewportState(
            options: options,
            mapboxMap: mapboxMap)
    }

    internal func makeDefaultViewportTransition(options: DefaultViewportTransitionOptions) -> DefaultViewportTransition {
        return DefaultViewportTransition(
            options: options,
            cameraAnimationsManager: cameraAnimationsManager)
    }

    internal func makeImmediateViewportTransition() -> ImmediateViewportTransition {
        return ImmediateViewportTransition(mapboxMap: mapboxMap)
    }
}
