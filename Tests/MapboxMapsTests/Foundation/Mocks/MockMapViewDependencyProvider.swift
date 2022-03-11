import Foundation
@testable import MapboxMaps

final class MockMapViewDependencyProvider: MapViewDependencyProviderProtocol {
    let makeNotificationCenterStub = Stub<Void, NotificationCenterProtocol>(defaultReturnValue: MockNotificationCenter())
    func makeNotificationCenter() -> NotificationCenterProtocol {
        makeNotificationCenterStub.call()
    }

    let makeBundleStub = Stub<Void, BundleProtocol>(defaultReturnValue: MockBundle())
    func makeBundle() -> BundleProtocol {
        makeBundleStub.call()
    }

    let makeMapboxObservableProviderStub = Stub<Void, (ObservableProtocol) -> MapboxObservableProtocol>(defaultReturnValue: { _ in MockMapboxObservable() })
    func makeMapboxObservableProvider() -> (ObservableProtocol) -> MapboxObservableProtocol {
        makeMapboxObservableProviderStub.call()
    }

    struct MakeMetalViewParams {
        var frame: CGRect
        var device: MTLDevice?
    }
    let makeMetalViewStub = Stub<MakeMetalViewParams, MockMetalView?>(defaultReturnValue: nil)
    func makeMetalView(frame: CGRect, device: MTLDevice?) -> MTKView {
        makeMetalViewStub.returnValueQueue.append(MockMetalView(frame: frame, device: device))
        return makeMetalViewStub.call(with: MakeMetalViewParams(frame: frame, device: device))!
    }

    struct MakeDisplayLinkParams {
        var window: UIWindow
        var target: Any
        var selector: Selector
    }
    let makeDisplayLinkStub = Stub<MakeDisplayLinkParams, MockDisplayLink?>(
        defaultReturnValue: MockDisplayLink())
    func makeDisplayLink(window: UIWindow,
                         target: Any,
                         selector: Selector) -> DisplayLinkProtocol? {
        makeDisplayLinkStub.call(
            with: MakeDisplayLinkParams(
                window: window,
                target: target,
                selector: selector))
    }

    let makeCameraAnimatorsRunnerStub = Stub<MapboxMapProtocol, CameraAnimatorsRunnerProtocol>(
        defaultReturnValue: MockCameraAnimatorsRunner())
    func makeCameraAnimatorsRunner(mapboxMap: MapboxMapProtocol) -> CameraAnimatorsRunnerProtocol {
        makeCameraAnimatorsRunnerStub.call(with: mapboxMap)
    }

    func makeCameraAnimationsManagerImpl(cameraViewContainerView: UIView,
                                         mapboxMap: MapboxMapProtocol,
                                         cameraAnimatorsRunner: CameraAnimatorsRunnerProtocol) -> CameraAnimationsManagerProtocol {
        MockCameraAnimationsManager()
    }

    func makeGestureManager(
        view: UIView,
        mapboxMap: MapboxMapProtocol,
        cameraAnimationsManager: CameraAnimationsManagerProtocol,
        cameraAnimatorsRunner: CameraAnimatorsRunnerProtocol) -> GestureManager {
        return GestureManager(
            panGestureHandler: MockPanGestureHandler(
                gestureRecognizer: UIGestureRecognizer()),
            pinchGestureHandler: MockPinchGestureHandler(gestureRecognizer: UIGestureRecognizer()),
            pitchGestureHandler: makeGestureHandler(),
            doubleTapToZoomInGestureHandler: MockFocusableGestureHandler(
                gestureRecognizer: UIGestureRecognizer()),
            doubleTouchToZoomOutGestureHandler: MockFocusableGestureHandler(
                gestureRecognizer: UIGestureRecognizer()),
            quickZoomGestureHandler: MockFocusableGestureHandler(gestureRecognizer: UIGestureRecognizer()),
            singleTapGestureHandler: makeGestureHandler(),
            anyTouchGestureHandler: makeGestureHandler(),
            mapboxMap: mapboxMap)
    }

    func makeGestureHandler() -> GestureHandler {
        return GestureHandler(gestureRecognizer: UIGestureRecognizer())
    }

    let makeLocationProducerStub = Stub<Bool, MockLocationProducer>(defaultReturnValue: MockLocationProducer())
    func makeLocationProducer(mayRequestWhenInUseAuthorization: Bool) -> LocationProducerProtocol {
        return makeLocationProducerStub.call(with: mayRequestWhenInUseAuthorization)
    }

    func makeInterpolatedLocationProducer(locationProducer: LocationProducerProtocol,
                                          displayLinkCoordinator: DisplayLinkCoordinator) -> InterpolatedLocationProducerProtocol {
        return MockInterpolatedLocationProducer()
    }

    func makeLocationManager(locationProducer: LocationProducerProtocol,
                             interpolatedLocationProducer: InterpolatedLocationProducerProtocol,
                             style: StyleProtocol) -> LocationManager {
        return LocationManager(locationProducer: locationProducer, puckManager: MockPuckManager())
    }

    struct MakeViewportImplParams {
        var mapboxMap: MapboxMapProtocol
        var cameraAnimationsManager: CameraAnimationsManagerProtocol
        var anyTouchGestureRecognizer: UIGestureRecognizer
        var doubleTapGestureRecognizer: UIGestureRecognizer
        var doubleTouchGestureRecognizer: UIGestureRecognizer
    }
    let makeViewportImplStub = Stub<MakeViewportImplParams, ViewportImplProtocol>(defaultReturnValue: MockViewportImpl())
    func makeViewportImpl(mapboxMap: MapboxMapProtocol,
                          cameraAnimationsManager: CameraAnimationsManagerProtocol,
                          anyTouchGestureRecognizer: UIGestureRecognizer,
                          doubleTapGestureRecognizer: UIGestureRecognizer,
                          doubleTouchGestureRecognizer: UIGestureRecognizer) -> ViewportImplProtocol {
        makeViewportImplStub.call(with: .init(
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager,
            anyTouchGestureRecognizer: anyTouchGestureRecognizer,
            doubleTapGestureRecognizer: doubleTapGestureRecognizer,
            doubleTouchGestureRecognizer: doubleTouchGestureRecognizer))
    }
}
