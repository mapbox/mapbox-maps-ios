#if os(OSX)
import AppKit
#else
import UIKit
#endif

internal protocol MapViewDependencyProviderProtocol: AnyObject {
    var notificationCenter: NotificationCenterProtocol { get }
    var bundle: BundleProtocol { get }
    var mapboxObservableProvider: (ObservableProtocol) -> MapboxObservableProtocol { get }
    var cameraAnimatorsRunnerEnablable: MutableEnablableProtocol { get }
    func makeMetalView(frame: CGRect, device: MTLDevice?) -> MTKView
    #if os(iOS)
    func makeDisplayLink(window: UIWindow, target: Any, selector: Selector) -> DisplayLinkProtocol?
    #endif
    func makeCameraAnimatorsRunner(mapboxMap: MapboxMapProtocol) -> CameraAnimatorsRunnerProtocol
    func makeCameraAnimationsManagerImpl(cameraViewContainerView: View,
                                         mapboxMap: MapboxMapProtocol,
                                         cameraAnimatorsRunner: CameraAnimatorsRunnerProtocol) -> CameraAnimationsManagerProtocol
    func makeGestureManager(view: View,
                            mapboxMap: MapboxMapProtocol,
                            cameraAnimationsManager: CameraAnimationsManagerProtocol) -> GestureManager
    func makeLocationProducer(mayRequestWhenInUseAuthorization: Bool) -> LocationProducerProtocol
    func makeInterpolatedLocationProducer(locationProducer: LocationProducerProtocol,
                                          displayLinkCoordinator: DisplayLinkCoordinator) -> InterpolatedLocationProducerProtocol
    func makeLocationManager(locationProducer: LocationProducerProtocol,
                             interpolatedLocationProducer: InterpolatedLocationProducerProtocol,
                             style: StyleProtocol,
                             mapboxMap: MapboxMapProtocol,
                             displayLinkCoordinator: DisplayLinkCoordinator) -> LocationManager

    func makeViewportImpl(mapboxMap: MapboxMapProtocol,
                          cameraAnimationsManager: CameraAnimationsManagerProtocol,
                          anyTouchGestureRecognizer: GestureRecognizer?,
                          doubleTapGestureRecognizer: GestureRecognizer?,
                          doubleTouchGestureRecognizer: GestureRecognizer?) -> ViewportImplProtocol

}

// swiftlint:disable:next type_body_length
internal final class MapViewDependencyProvider: MapViewDependencyProviderProtocol {
    internal let notificationCenter: NotificationCenterProtocol = NotificationCenter.default

    internal let bundle: BundleProtocol = Bundle.main

    internal let mapboxObservableProvider: (ObservableProtocol) -> MapboxObservableProtocol = MapboxObservable.init

    internal let cameraAnimatorsRunnerEnablable: MutableEnablableProtocol = Enablable()
    private let gesturesCameraAnimatorsRunnerEnablable = Enablable()
    private let mainQueue = MainQueue()

    internal func makeMetalView(frame: CGRect, device: MTLDevice?) -> MTKView {
        MTKView(frame: frame, device: device)
    }

    #if os(iOS)
    internal func makeDisplayLink(window: UIWindow, target: Any, selector: Selector) -> DisplayLinkProtocol? {
        window.screen.displayLink(withTarget: target, selector: selector)
    }
    #endif

    internal func makeCameraAnimatorsRunner(mapboxMap: MapboxMapProtocol) -> CameraAnimatorsRunnerProtocol {
        CameraAnimatorsRunner(
            mapboxMap: mapboxMap,
            enablable: CompositeEnablable(
                enablables: [
                    cameraAnimatorsRunnerEnablable,
                    gesturesCameraAnimatorsRunnerEnablable]))
    }

    internal func makeCameraAnimationsManagerImpl(cameraViewContainerView: View,
                                                  mapboxMap: MapboxMapProtocol,
                                                  cameraAnimatorsRunner: CameraAnimatorsRunnerProtocol) -> CameraAnimationsManagerProtocol {
        let doubleInterpolator = DoubleInterpolator()
        let wrappingInterpolator = WrappingInterpolator()
        let longitudeInterpolator = LongitudeInterpolator(
            wrappingInterpolator: wrappingInterpolator)
        let coordinateInterpolator = CoordinateInterpolator(
            doubleInterpolator: doubleInterpolator,
            longitudeInterpolator: longitudeInterpolator)
        let uiEdgeInsetsInterpolator = UIEdgeInsetsInterpolator(
            doubleInterpolator: doubleInterpolator)
        let directionInterpolator = DirectionInterpolator(
            wrappingInterpolator: wrappingInterpolator)
        let cameraOptionsInterpolator = CameraOptionsInterpolator(
            coordinateInterpolator: coordinateInterpolator,
            uiEdgeInsetsInterpolator: uiEdgeInsetsInterpolator,
            doubleInterpolator: doubleInterpolator,
            directionInterpolator: directionInterpolator)
        return CameraAnimationsManagerImpl(
            factory: CameraAnimatorsFactory(
                cameraViewContainerView: cameraViewContainerView,
                mapboxMap: mapboxMap,
                mainQueue: mainQueue,
                dateProvider: DefaultDateProvider(),
                cameraOptionsInterpolator: cameraOptionsInterpolator),
            runner: cameraAnimatorsRunner)
    }

    private func makePanGestureHandler(view: View,
                                       mapboxMap: MapboxMapProtocol,
                                       cameraAnimationsManager: CameraAnimationsManagerProtocol) -> PanGestureHandlerProtocol {
        #if os(iOS)
        let gestureRecognizer = UIPanGestureRecognizer()
        view.addGestureRecognizer(gestureRecognizer)
        return PanGestureHandler(
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager,
            dateProvider: DefaultDateProvider())
        #else
        let gestureRecognizer = NSPanGestureRecognizer()
        view.addGestureRecognizer(gestureRecognizer)
        return PanGestureHandler(panGestureRecognizer: gestureRecognizer,
                                 mapboxMap: mapboxMap,
                                 cameraAnimationsManager: cameraAnimationsManager,
                                 dateProvider: DefaultDateProvider())
        #endif
    }

    private func makePinchGestureHandler(view: View,
                                         mapboxMap: MapboxMapProtocol) -> PinchGestureHandlerProtocol {
#if os(iOS)
        let gestureRecognizer = UIPinchGestureRecognizer()
        view.addGestureRecognizer(gestureRecognizer)
        return PinchGestureHandler(
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap,
            pinchBehaviorProvider: PinchBehaviorProvider(
                mapboxMap: mapboxMap))
#else
        let gestureRecognizer = NSMagnificationGestureRecognizer()
        view.addGestureRecognizer(gestureRecognizer)
        return PinchGestureHandler(gestureRecognizer: gestureRecognizer,
                                   mapboxMap: mapboxMap,
                                   pinchBehaviorProvider: PinchBehaviorProvider(mapboxMap: mapboxMap))
#endif
    }

    private func makeRotateGestureHandler(view: View, mapboxMap: MapboxMapProtocol) -> RotateGestureHandler {
#if os(iOS)
        let gestureRecognizer = UIRotationGestureRecognizer()
        view.addGestureRecognizer(gestureRecognizer)
        return RotateGestureHandler(gestureRecognizer: gestureRecognizer, mapboxMap: mapboxMap)
#else
        let gestureRecognizer = NSRotationGestureRecognizer()
        view.addGestureRecognizer(gestureRecognizer)
        return RotateGestureHandler(gestureRecognizer: gestureRecognizer,
                                    mapboxMap: mapboxMap)
#endif
    }

    private func makePitchGestureHandler(view: View,
                                         mapboxMap: MapboxMapProtocol) -> GestureHandler {
#if os(iOS)
        let gestureRecognizer = UIPanGestureRecognizer()
        view.addGestureRecognizer(gestureRecognizer)
        return PitchGestureHandler(
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap)
#else
        return GestureHandler(gestureRecognizer: NSClickGestureRecognizer())
#endif
    }

    private func makeDoubleTapToZoomInGestureHandler(view: View,
                                                     mapboxMap: MapboxMapProtocol,
                                                     cameraAnimationsManager: CameraAnimationsManagerProtocol) -> FocusableGestureHandlerProtocol? {
#if os(iOS)
        let gestureRecognizer = UITapGestureRecognizer()
        view.addGestureRecognizer(gestureRecognizer)
        return DoubleTapToZoomInGestureHandler(
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
#else
        return nil
#endif
    }

    private func makeDoubleTouchToZoomOutGestureHandler(view: View,
                                                        mapboxMap: MapboxMapProtocol,
                                                        cameraAnimationsManager: CameraAnimationsManagerProtocol) -> FocusableGestureHandlerProtocol? {
#if os(iOS)
        let gestureRecognizer = UITapGestureRecognizer()
        view.addGestureRecognizer(gestureRecognizer)
        return DoubleTouchToZoomOutGestureHandler(
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
#else
        return nil
#endif
    }

    private func makeQuickZoomGestureHandler(view: View,
                                             mapboxMap: MapboxMapProtocol) -> FocusableGestureHandlerProtocol? {
#if os(iOS)
        let gestureRecognizer = UILongPressGestureRecognizer()
        view.addGestureRecognizer(gestureRecognizer)
        return QuickZoomGestureHandler(
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap)
#else
        return nil
#endif
    }

    private func makeSingleTapGestureHandler(view: View,
                                             cameraAnimationsManager: CameraAnimationsManagerProtocol) -> GestureHandler {
#if os(iOS)
        let gestureRecognizer = UITapGestureRecognizer()
        view.addGestureRecognizer(gestureRecognizer)
        return SingleTapGestureHandler(
            gestureRecognizer: gestureRecognizer,
            cameraAnimationsManager: cameraAnimationsManager)
#else
        return GestureHandler(gestureRecognizer: NSClickGestureRecognizer())
#endif
    }


    private func makeAnyTouchGestureHandler(view: View) -> GestureHandler {
#if os(iOS)

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
            cameraAnimatorsRunnerEnablable: gesturesCameraAnimatorsRunnerEnablable)
#else
        return GestureHandler(gestureRecognizer: NSClickGestureRecognizer())
#endif
    }

    internal func makeGestureManager(view: View,
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
            rotateGestureHandler: makeRotateGestureHandler(view: view, mapboxMap: mapboxMap),
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
                cameraAnimationsManager: cameraAnimationsManager),
            anyTouchGestureHandler: makeAnyTouchGestureHandler(view: view),
            mapboxMap: mapboxMap)
    }

    internal func makeLocationProducer(mayRequestWhenInUseAuthorization: Bool) -> LocationProducerProtocol {
        let locationProvider = AppleLocationProvider()
        return LocationProducer(
            locationProvider: locationProvider,
            mayRequestWhenInUseAuthorization: mayRequestWhenInUseAuthorization)
    }

    internal func makeInterpolatedLocationProducer(locationProducer: LocationProducerProtocol,
                                                   displayLinkCoordinator: DisplayLinkCoordinator) -> InterpolatedLocationProducerProtocol {
        let doubleInterpolator = DoubleInterpolator()
        let wrappingInterpolator = WrappingInterpolator()
        let directionInterpolator = DirectionInterpolator(
            wrappingInterpolator: wrappingInterpolator)
        let longitudeInterpolator = LongitudeInterpolator(
            wrappingInterpolator: wrappingInterpolator)
        let coordinateInterpolator = CoordinateInterpolator(
            doubleInterpolator: doubleInterpolator,
            longitudeInterpolator: longitudeInterpolator)
        let locationInterpolator = LocationInterpolator(
            doubleInterpolator: doubleInterpolator,
            directionInterpolator: directionInterpolator,
            coordinateInterpolator: coordinateInterpolator)
        return InterpolatedLocationProducer(
            observableInterpolatedLocation: ObservableInterpolatedLocation(),
            locationInterpolator: locationInterpolator,
            dateProvider: DefaultDateProvider(),
            locationProducer: locationProducer,
            displayLinkCoordinator: displayLinkCoordinator)
    }

    internal func makeLocationManager(locationProducer: LocationProducerProtocol,
                                      interpolatedLocationProducer: InterpolatedLocationProducerProtocol,
                                      style: StyleProtocol,
                                      mapboxMap: MapboxMapProtocol,
                                      displayLinkCoordinator: DisplayLinkCoordinator) -> LocationManager {
        let puckManager = PuckManager(
            puck2DProvider: { [weak displayLinkCoordinator] configuration in
                guard let displayLinkCoordinator = displayLinkCoordinator else {
                    fatalError("DisplayLinkCoordinator must be present when creating a 2D puck")
                }
                return Puck2D(
                    configuration: configuration,
                    style: style,
                    interpolatedLocationProducer: interpolatedLocationProducer,
                    mapboxMap: mapboxMap,
                    displayLinkCoordinator: displayLinkCoordinator,
                    timeProvider: DefaultTimeProvider())
            },
            puck3DProvider: { configuration in
                Puck3D(
                    configuration: configuration,
                    style: style,
                    interpolatedLocationProducer: interpolatedLocationProducer)
            })
        return LocationManager(
            locationProducer: locationProducer,
            interpolatedLocationProducer: interpolatedLocationProducer,
            puckManager: puckManager)
    }

    internal func makeViewportImpl(mapboxMap: MapboxMapProtocol,
                                   cameraAnimationsManager: CameraAnimationsManagerProtocol,
                                   anyTouchGestureRecognizer: GestureRecognizer?,
                                   doubleTapGestureRecognizer: GestureRecognizer?,
                                   doubleTouchGestureRecognizer: GestureRecognizer?) -> ViewportImplProtocol {
        let lowZoomToHighZoomAnimationSpecProvider = LowZoomToHighZoomAnimationSpecProvider(
            mapboxMap: mapboxMap)
        let highZoomToLowZoomAnimationSpecProvider = HighZoomToLowZoomAnimationSpecProvider()
        let animationSpecProvider = DefaultViewportTransitionAnimationSpecProvider(
            mapboxMap: mapboxMap,
            lowZoomToHighZoomAnimationSpecProvider: lowZoomToHighZoomAnimationSpecProvider,
            highZoomToLowZoomAnimationSpecProvider: highZoomToLowZoomAnimationSpecProvider)
        let animationFactory = DefaultViewportTransitionAnimationFactory(
            mapboxMap: mapboxMap)
        let animationHelper = DefaultViewportTransitionAnimationHelper(
            mapboxMap: mapboxMap,
            animationSpecProvider: animationSpecProvider,
            cameraAnimationsManager: cameraAnimationsManager,
            animationFactory: animationFactory)
        let defaultViewportTransition = DefaultViewportTransition(
            options: .init(),
            animationHelper: animationHelper)
        return ViewportImpl(
            options: .init(),
            mainQueue: mainQueue,
            defaultTransition: defaultViewportTransition,
            anyTouchGestureRecognizer: anyTouchGestureRecognizer,
            doubleTapGestureRecognizer: doubleTapGestureRecognizer,
            doubleTouchGestureRecognizer: doubleTouchGestureRecognizer)
    }
}
