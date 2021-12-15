internal protocol ViewportFactoryProtocol: AnyObject {
    func makeFollowingViewportState(zoom: CGFloat, pitch: CGFloat) -> FollowingViewportState
    func makeOverviewViewportState(geometry: GeometryConvertible) -> OverviewViewportState
    func makeEaseToViewportTransition(duration: TimeInterval, curve: UIView.AnimationCurve) -> EaseToViewportTransition
    func makeFlyToViewportTransition(duration: TimeInterval?) -> FlyToViewportTransition
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

    internal func makeFollowingViewportState(zoom: CGFloat, pitch: CGFloat) -> FollowingViewportState {
        return FollowingViewportState(
            zoom: zoom,
            pitch: pitch,
            locationProducer: locationProducer,
            cameraAnimationsManager: cameraAnimationsManager)
    }

    internal func makeOverviewViewportState(geometry: GeometryConvertible) -> OverviewViewportState {
        return OverviewViewportState(
            geometry: geometry,
            mapboxMap: mapboxMap)
    }

    internal func makeEaseToViewportTransition(duration: TimeInterval, curve: UIView.AnimationCurve) -> EaseToViewportTransition {
        return EaseToViewportTransition(
            duration: duration,
            curve: curve,
            cameraAnimationsManager: cameraAnimationsManager)
    }

    internal func makeFlyToViewportTransition(duration: TimeInterval?) -> FlyToViewportTransition {
        return FlyToViewportTransition(
            duration: duration,
            cameraAnimationsManager: cameraAnimationsManager)
    }

    internal func makeImmediateViewportTransition() -> ImmediateViewportTransition {
        return ImmediateViewportTransition(mapboxMap: mapboxMap)
    }
}
