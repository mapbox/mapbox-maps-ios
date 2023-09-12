import Foundation
import MetalKit
@_spi(Package) @testable import MapboxMaps

final class MockMapViewDependencyProvider: MapViewDependencyProviderProtocol {
    @Stubbed var notificationCenter: NotificationCenterProtocol = MockNotificationCenter()

    @Stubbed var bundle: BundleProtocol = MockBundle()

    // MARK: - Metal view
    struct MakeMetalViewParams {
        var frame: CGRect
        var device: MTLDevice?
    }
    let makeMetalViewStub = Stub<MakeMetalViewParams, MockMetalView?>(defaultReturnValue: nil)
    func makeMetalView(frame: CGRect, device: MTLDevice?) -> MTKView {
        makeMetalViewStub.returnValueQueue.append(MockMetalView(frame: frame, device: device))
        return makeMetalViewStub.call(with: MakeMetalViewParams(frame: frame, device: device))!
    }

    // MARK: - DispayLink
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

    // MARK: - Camera Animators
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

    // MARK: - Gestures
    func makeGestureManager(
        view: UIView,
        mapboxMap: MapboxMapProtocol,
        cameraAnimationsManager: CameraAnimationsManagerProtocol) -> GestureManager {
        return GestureManager(
            panGestureHandler: MockPanGestureHandler(
                gestureRecognizer: UIGestureRecognizer()),
            pinchGestureHandler: MockPinchGestureHandler(gestureRecognizer: UIGestureRecognizer()),
            rotateGestureHandler: MockRotateGestureHandler(gestureRecognizer: UIGestureRecognizer()),
            pitchGestureHandler: makeGestureHandler(),
            doubleTapToZoomInGestureHandler: MockFocusableGestureHandler(
                gestureRecognizer: UIGestureRecognizer()),
            doubleTouchToZoomOutGestureHandler: MockFocusableGestureHandler(
                gestureRecognizer: UIGestureRecognizer()),
            quickZoomGestureHandler: MockFocusableGestureHandler(gestureRecognizer: UIGestureRecognizer()),
            singleTapGestureHandler: makeGestureHandler(),
            anyTouchGestureHandler: makeGestureHandler(),
            interruptDecelerationGestureHandler: makeGestureHandler(),
            mapboxMap: mapboxMap)
    }

    func makeGestureHandler() -> GestureHandler {
        return GestureHandler(gestureRecognizer: UIGestureRecognizer())
    }

    // MARK: - Viewport
    struct MakeViewportManagerImplParams {
        var mapboxMap: MapboxMapProtocol
        var cameraAnimationsManager: CameraAnimationsManagerProtocol
        var anyTouchGestureRecognizer: UIGestureRecognizer
        var doubleTapGestureRecognizer: UIGestureRecognizer
        var doubleTouchGestureRecognizer: UIGestureRecognizer
    }
    let makeViewportManagerImplStub = Stub<MakeViewportManagerImplParams, ViewportManagerImplProtocol>(defaultReturnValue: MockViewportManagerImpl())
    func makeViewportManagerImpl(
        mapboxMap: MapboxMapProtocol,
        cameraAnimationsManager: CameraAnimationsManagerProtocol,
        anyTouchGestureRecognizer: UIGestureRecognizer,
        doubleTapGestureRecognizer: UIGestureRecognizer,
        doubleTouchGestureRecognizer: UIGestureRecognizer
    ) -> ViewportManagerImplProtocol {
        makeViewportManagerImplStub.call(with: .init(
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager,
            anyTouchGestureRecognizer: anyTouchGestureRecognizer,
            doubleTapGestureRecognizer: doubleTapGestureRecognizer,
            doubleTouchGestureRecognizer: doubleTouchGestureRecognizer))
    }

    // MARK: - Annotations
    struct MakeAnnotationOrchestratorImplParams {
        let view: UIView
        let mapboxMap: MapboxMapProtocol
        let mapFeatureQueryable: MapFeatureQueryable
        let style: StyleProtocol
        let displayLink: Signal<Void>
    }
    let makeAnnotationOrchestratorStub = Stub<MakeAnnotationOrchestratorImplParams, AnnotationOrchestratorImplProtocol>(defaultReturnValue: MockAnnotationOrchestatorImpl())
    func makeAnnotationOrchestratorImpl(in view: UIView,
                                        mapboxMap: MapboxMapProtocol,
                                        mapFeatureQueryable: MapFeatureQueryable,
                                        style: StyleProtocol,
                                        displayLink: Signal<Void>) -> AnnotationOrchestratorImplProtocol {
        makeAnnotationOrchestratorStub.call(with: .init(
            view: view,
            mapboxMap: mapboxMap,
            mapFeatureQueryable: mapFeatureQueryable,
            style: style,
            displayLink: displayLink))
    }

    // MARK: - Events Manager
    let makeEventsManagerStub = Stub<Void, EventsManagerProtocol>(defaultReturnValue: EventsManagerMock())
    func makeEventsManager() -> EventsManagerProtocol {
        makeEventsManagerStub.call()
    }
}
