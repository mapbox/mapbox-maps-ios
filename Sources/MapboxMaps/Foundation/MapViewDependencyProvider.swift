internal protocol MapViewDependencyProviderProtocol: AnyObject {
    func makeMetalView(frame: CGRect, device: MTLDevice?) -> MTKView
    func makeDisplayLink(window: UIWindow, target: Any, selector: Selector) -> DisplayLinkProtocol?
    func makeGestureManager(view: UIView,
                            mapboxMap: MapboxMapProtocol,
                            cameraAnimationsManager: CameraAnimationsManagerProtocol) -> GestureManager
    func makeLocationSource(mayRequestWhenInUseAuthorization: Bool) -> LocationSourceProtocol
    func makeLocationManager(locationSource: LocationSourceProtocol, style: StyleProtocol) -> LocationManager
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

    func makeAnimationLockoutGestureHandler(view: UIView,
                                            mapboxMap: MapboxMapProtocol,
                                            cameraAnimationsManager: CameraAnimationsManagerProtocol) -> GestureHandler {
        let gestureRecognizer = AnyTouchGestureRecognizer()
        view.addGestureRecognizer(gestureRecognizer)
        return AnimationLockoutGestureHandler(
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
            animationLockoutGestureHandler: makeAnimationLockoutGestureHandler(
                view: view,
                mapboxMap: mapboxMap,
                cameraAnimationsManager: cameraAnimationsManager),
            mapboxMap: mapboxMap)
    }

    func makeLocationSource(mayRequestWhenInUseAuthorization: Bool) -> LocationSourceProtocol {
        let locationProvider = AppleLocationProvider()
        return LocationSource(
            locationProvider: locationProvider,
            mayRequestWhenInUseAuthorization: mayRequestWhenInUseAuthorization)
    }

    func makeLocationManager(locationSource: LocationSourceProtocol, style: StyleProtocol) -> LocationManager {
        let puckManager = PuckManager(
            puck2DProvider: { configuration in
                Puck2D(
                    configuration: configuration,
                    style: style,
                    locationSource: locationSource)
            },
            puck3DProvider: { configuration in
                Puck3D(
                    configuration: configuration,
                    style: style,
                    locationSource: locationSource)
            })

        return LocationManager(
            locationSource: locationSource,
            puckManager: puckManager)
    }
}
