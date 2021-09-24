import Foundation
@testable import MapboxMaps

final class MockMapViewDependencyProvider: MapViewDependencyProviderProtocol {
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

    func makeGestureManager(
        view: UIView,
        mapboxMap: MapboxMapProtocol,
        cameraAnimationsManager: CameraAnimationsManagerProtocol) -> GestureManager {
        return GestureManager(
            panGestureHandler: MockPanGestureHandler(
                gestureRecognizer: UIGestureRecognizer(),
                mapboxMap: MockMapboxMap(),
                cameraAnimationsManager: MockCameraAnimationsManager()),
            pinchGestureHandler: makeGestureHandler(),
            pitchGestureHandler: makeGestureHandler(),
            doubleTapToZoomInGestureHandler: makeGestureHandler(),
            doubleTouchToZoomOutGestureHandler: makeGestureHandler(),
            quickZoomGestureHandler: makeGestureHandler(),
            singleTapGestureHandler: makeGestureHandler())
    }

    func makeGestureHandler() -> GestureHandler {
        return GestureHandler(
            gestureRecognizer: UIGestureRecognizer(),
            mapboxMap: MockMapboxMap(),
            cameraAnimationsManager: MockCameraAnimationsManager())
    }
}
