import UIKit

internal protocol MapViewDependencyProviderProtocol: AnyObject {
    func makeMetalView(frame: CGRect, device: MTLDevice?) -> MTKView
    func makeDisplayLink(window: UIWindow, target: Any, selector: Selector) -> DisplayLinkProtocol?
    func makeGestureManager(view: UIView,
                            mapboxMap: MapboxMapProtocol,
                            cameraAnimationsManager: CameraAnimationsManagerProtocol) -> GestureManager
    func makeLocationProducer(mayRequestWhenInUseAuthorization: Bool) -> LocationProducerProtocol
    func makeLocationManager(locationProducer: LocationProducerProtocol, style: StyleProtocol) -> LocationManager
    func makeViewportImpl(mapboxMap: MapboxMapProtocol,
                          cameraAnimationsManager: CameraAnimationsManagerProtocol,
                          anyTouchGestureRecognizer: UIGestureRecognizer,
                          doubleTapGestureRecognizer: UIGestureRecognizer,
                          doubleTouchGestureRecognizer: UIGestureRecognizer) -> ViewportImplProtocol
}

internal final class MapViewDependencyProvider: MapViewDependencyProviderProtocol {
    func makeMetalView(frame: CGRect, device: MTLDevice?) -> MTKView {
        MTKView(frame: frame, device: device)
    }

    func makeDisplayLink(window: UIWindow, target: Any, selector: Selector) -> DisplayLinkProtocol? {
        window.screen.displayLink(withTarget: target, selector: selector)
    }

    func makePanGestureHandler(view: UIView,
                               mapboxMap: MapboxMapProtocol,
                               cameraAnimationsManager: CameraAnimationsManagerProtocol) -> PanGestureHandlerProtocol {
        let gestureRecognizer = UIPanGestureRecognizer()
        view.addGestureRecognizer(gestureRecognizer)
        return PanGestureHandler(
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager,
            dateProvider: DefaultDateProvider())
    }

    func makePinchGestureHandler(view: UIView,
                                 mapboxMap: MapboxMapProtocol) -> PinchGestureHandlerProtocol {
        let gestureRecognizer = UIPinchGestureRecognizer()
        view.addGestureRecognizer(gestureRecognizer)
        return PinchGestureHandler(
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap)
    }

    func makePitchGestureHandler(view: UIView,
                                 mapboxMap: MapboxMapProtocol) -> GestureHandler {
        let gestureRecognizer = UIPanGestureRecognizer()
        view.addGestureRecognizer(gestureRecognizer)
        return PitchGestureHandler(
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap)
    }

    func makeDoubleTapToZoomInGestureHandler(view: UIView,
                                             mapboxMap: MapboxMapProtocol,
                                             cameraAnimationsManager: CameraAnimationsManagerProtocol) -> GestureHandler {
        let gestureRecognizer = UITapGestureRecognizer()
        view.addGestureRecognizer(gestureRecognizer)
        return DoubleTapToZoomInGestureHandler(
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
    }

    func makeDoubleTouchToZoomOutGestureHandler(view: UIView,
                                                mapboxMap: MapboxMapProtocol,
                                                cameraAnimationsManager: CameraAnimationsManagerProtocol) -> GestureHandler {
        let gestureRecognizer = UITapGestureRecognizer()
        view.addGestureRecognizer(gestureRecognizer)
        return DoubleTouchToZoomOutGestureHandler(
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
    }

    func makeQuickZoomGestureHandler(view: UIView,
                                     mapboxMap: MapboxMapProtocol) -> GestureHandler {
        let gestureRecognizer = UILongPressGestureRecognizer()
        view.addGestureRecognizer(gestureRecognizer)
        return QuickZoomGestureHandler(
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap)
    }

    func makeSingleTapGestureHandler(view: UIView,
                                     mapboxMap: MapboxMapProtocol) -> GestureHandler {
        let gestureRecognizer = UITapGestureRecognizer()
        view.addGestureRecognizer(gestureRecognizer)
        return SingleTapGestureHandler(gestureRecognizer: gestureRecognizer)
    }

    func makeAnyTouchGestureHandler(view: UIView,
                                    cameraAnimationsManager: CameraAnimationsManagerProtocol) -> GestureHandler {
        // 0.15 seconds is a sufficient delay to avoid interrupting animations
        // in between a rapid succession of double tap or double touch gestures.
        // It's also not so long as to feel unnatural when touching the map to
        // stop an animation. The map continues to animate under the touch
        // briefly, but comes to a stop within a reasonable amount of time. In
        // the future, we may want to expose this as a tunable option.
        let gestureRecognizer = AnyTouchGestureRecognizer(
            minimumPressDuration: 0.15,
            timerProvider: TimerProvider())
        view.addGestureRecognizer(gestureRecognizer)
        return AnyTouchGestureHandler(
            gestureRecognizer: gestureRecognizer,
            cameraAnimationsManager: cameraAnimationsManager)
    }

    func makeGestureManager(view: UIView,
                            mapboxMap: MapboxMapProtocol,
                            cameraAnimationsManager: CameraAnimationsManagerProtocol) -> GestureManager {
        return GestureManager(
            panGestureHandler: makePanGestureHandler(
                view: view,
                mapboxMap: mapboxMap,
                cameraAnimationsManager: cameraAnimationsManager),
            pinchGestureHandler: makePinchGestureHandler(
                view: view,
                mapboxMap: mapboxMap),
            pitchGestureHandler: makePitchGestureHandler(
                view: view,
                mapboxMap: mapboxMap),
            doubleTapToZoomInGestureHandler: makeDoubleTapToZoomInGestureHandler(
                view: view,
                mapboxMap: mapboxMap,
                cameraAnimationsManager: cameraAnimationsManager),
            doubleTouchToZoomOutGestureHandler: makeDoubleTouchToZoomOutGestureHandler(
                view: view,
                mapboxMap: mapboxMap,
                cameraAnimationsManager: cameraAnimationsManager),
            quickZoomGestureHandler: makeQuickZoomGestureHandler(
                view: view,
                mapboxMap: mapboxMap),
            singleTapGestureHandler: makeSingleTapGestureHandler(
                view: view,
                mapboxMap: mapboxMap),
            anyTouchGestureHandler: makeAnyTouchGestureHandler(
                view: view,
                cameraAnimationsManager: cameraAnimationsManager),
            mapboxMap: mapboxMap)
    }

    func makeLocationProducer(mayRequestWhenInUseAuthorization: Bool) -> LocationProducerProtocol {
        let locationProvider = AppleLocationProvider()
        return LocationProducer(
            locationProvider: locationProvider,
            mayRequestWhenInUseAuthorization: mayRequestWhenInUseAuthorization)
    }

    func makeLocationManager(locationProducer: LocationProducerProtocol, style: StyleProtocol) -> LocationManager {
        let puckManager = PuckManager(
            puck2DProvider: { configuration in
                Puck2D(
                    configuration: configuration,
                    style: style,
                    locationProducer: locationProducer)
            },
            puck3DProvider: { configuration in
                Puck3D(
                    configuration: configuration,
                    style: style,
                    locationProducer: locationProducer)
            })

        return LocationManager(
            locationProducer: locationProducer,
            puckManager: puckManager)
    }

    func makeViewportImpl(mapboxMap: MapboxMapProtocol,
                          cameraAnimationsManager: CameraAnimationsManagerProtocol,
                          anyTouchGestureRecognizer: UIGestureRecognizer,
                          doubleTapGestureRecognizer: UIGestureRecognizer,
                          doubleTouchGestureRecognizer: UIGestureRecognizer) -> ViewportImplProtocol {
        return ViewportImpl(
            options: .init(),
            mainQueue: MainQueue(),
            defaultTransition: DefaultViewportTransition(
                options: .init(),
                animationHelper: DefaultViewportTransitionAnimationHelper(
                    mapboxMap: mapboxMap,
                    cameraAnimationsManager: cameraAnimationsManager)),
            anyTouchGestureRecognizer: anyTouchGestureRecognizer,
            doubleTapGestureRecognizer: doubleTapGestureRecognizer,
            doubleTouchGestureRecognizer: doubleTouchGestureRecognizer)
    }
}
