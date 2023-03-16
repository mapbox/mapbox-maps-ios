import UIKit

internal protocol MapViewDependencyProviderProtocol: AnyObject {
    var notificationCenter: NotificationCenterProtocol { get }
    var bundle: BundleProtocol { get }
    var mapboxObservableProvider: (ObservableProtocol) -> MapboxObservableProtocol { get }
    var cameraAnimatorsRunnerEnablable: MutableEnablableProtocol { get }
    func makeMetalView(frame: CGRect, device: MTLDevice?) -> MTKView
    func makeDisplayLink(window: UIWindow, target: Any, selector: Selector) -> DisplayLinkProtocol?
    func makeCameraAnimatorsRunner(mapboxMap: MapboxMapProtocol) -> CameraAnimatorsRunnerProtocol
    func makeCameraAnimationsManagerImpl(cameraViewContainerView: UIView,
                                         mapboxMap: MapboxMapProtocol,
                                         cameraAnimatorsRunner: CameraAnimatorsRunnerProtocol) -> CameraAnimationsManagerProtocol
    func makeGestureManager(view: UIView,
                            mapboxMap: MapboxMapProtocol,
                            cameraAnimationsManager: CameraAnimationsManagerProtocol) -> GestureManager
    func makeLocationProducer(mayRequestWhenInUseAuthorization: Bool,
                              userInterfaceOrientationView: UIView) -> LocationProducerProtocol
    func makeInterpolatedLocationProducer(locationProducer: LocationProducerProtocol,
                                          displayLinkCoordinator: DisplayLinkCoordinator) -> InterpolatedLocationProducerProtocol
    func makeLocationManager(locationProducer: LocationProducerProtocol,
                             interpolatedLocationProducer: InterpolatedLocationProducerProtocol,
                             style: StyleProtocol,
                             mapboxMap: MapboxMapProtocol,
                             displayLinkCoordinator: DisplayLinkCoordinator) -> LocationManager
    func makeViewportImpl(mapboxMap: MapboxMapProtocol,
                          cameraAnimationsManager: CameraAnimationsManagerProtocol,
                          anyTouchGestureRecognizer: UIGestureRecognizer,
                          doubleTapGestureRecognizer: UIGestureRecognizer,
                          doubleTouchGestureRecognizer: UIGestureRecognizer) -> ViewportImplProtocol
    func makeAnnotationOrchestratorImpl(in view: UIView,
                                        mapboxMap: MapboxMapProtocol,
                                        mapFeatureQueryable: MapFeatureQueryable,
                                        style: StyleProtocol,
                                        displayLinkCoordinator: DisplayLinkCoordinator) -> AnnotationOrchestratorImplProtocol

    func makeEventsManager(accessToken: String) -> EventsManagerProtocol
}

// swiftlint:disable:next type_body_length
internal final class MapViewDependencyProvider: MapViewDependencyProviderProtocol {
    internal let notificationCenter: NotificationCenterProtocol = NotificationCenter.default

    internal let bundle: BundleProtocol = Bundle.main

    internal let mapboxObservableProvider: (ObservableProtocol) -> MapboxObservableProtocol = MapboxObservable.init

    internal let cameraAnimatorsRunnerEnablable: MutableEnablableProtocol = Enablable()
    private let mainQueue: MainQueueProtocol = MainQueueWrapper()
    private let interfaceOrientationProvider: InterfaceOrientationProvider

    internal init(interfaceOrientationProvider: InterfaceOrientationProvider) {
        self.interfaceOrientationProvider = interfaceOrientationProvider
    }

    internal func makeMetalView(frame: CGRect, device: MTLDevice?) -> MTKView {
        MTKView(frame: frame, device: device)
    }

    internal func makeDisplayLink(window: UIWindow, target: Any, selector: Selector) -> DisplayLinkProtocol? {
        window.screen.displayLink(withTarget: target, selector: selector)
    }

    internal func makeCameraAnimatorsRunner(mapboxMap: MapboxMapProtocol) -> CameraAnimatorsRunnerProtocol {
        CameraAnimatorsRunner(
            mapboxMap: mapboxMap,
            enablable: cameraAnimatorsRunnerEnablable)
    }

    internal func makeCameraAnimationsManagerImpl(cameraViewContainerView: UIView,
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

    private func makePanGestureHandler(view: UIView,
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

    private func makePinchGestureHandler(view: UIView,
                                         mapboxMap: MapboxMapProtocol) -> PinchGestureHandlerProtocol {
        let gestureRecognizer = UIPinchGestureRecognizer()
        view.addGestureRecognizer(gestureRecognizer)
        return PinchGestureHandler(
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap,
            pinchBehaviorProvider: PinchBehaviorProvider(
                mapboxMap: mapboxMap))
    }

    private func makeRotateGestureHandler(view: UIView, mapboxMap: MapboxMapProtocol) -> RotateGestureHandler {
        let gestureRecognizer = UIRotationGestureRecognizer()
        view.addGestureRecognizer(gestureRecognizer)
        return RotateGestureHandler(gestureRecognizer: gestureRecognizer, mapboxMap: mapboxMap)
    }

    private func makePitchGestureHandler(view: UIView,
                                         mapboxMap: MapboxMapProtocol) -> GestureHandler {
        let gestureRecognizer = UIPanGestureRecognizer()
        view.addGestureRecognizer(gestureRecognizer)
        return PitchGestureHandler(
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap)
    }

    private func makeDoubleTapToZoomInGestureHandler(view: UIView,
                                                     mapboxMap: MapboxMapProtocol,
                                                     cameraAnimationsManager: CameraAnimationsManagerProtocol) -> FocusableGestureHandlerProtocol {
        let gestureRecognizer = UITapGestureRecognizer()
        view.addGestureRecognizer(gestureRecognizer)
        return DoubleTapToZoomInGestureHandler(
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
    }

    private func makeDoubleTouchToZoomOutGestureHandler(view: UIView,
                                                        mapboxMap: MapboxMapProtocol,
                                                        cameraAnimationsManager: CameraAnimationsManagerProtocol) -> FocusableGestureHandlerProtocol {
        let gestureRecognizer = UITapGestureRecognizer()
        view.addGestureRecognizer(gestureRecognizer)
        return DoubleTouchToZoomOutGestureHandler(
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)
    }

    private func makeQuickZoomGestureHandler(view: UIView,
                                             mapboxMap: MapboxMapProtocol) -> FocusableGestureHandlerProtocol {
        let gestureRecognizer = UILongPressGestureRecognizer()
        view.addGestureRecognizer(gestureRecognizer)
        return QuickZoomGestureHandler(
            gestureRecognizer: gestureRecognizer,
            mapboxMap: mapboxMap)
    }

    private func makeSingleTapGestureHandler(view: UIView,
                                             cameraAnimationsManager: CameraAnimationsManagerProtocol) -> GestureHandler {
        let gestureRecognizer = UITapGestureRecognizer()
        view.addGestureRecognizer(gestureRecognizer)
        return SingleTapGestureHandler(
            gestureRecognizer: gestureRecognizer,
            cameraAnimationsManager: cameraAnimationsManager)
    }

    private func makeAnyTouchGestureHandler(
        view: UIView,
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

    private func makeInterruptDecelerationGestureHandler(view: UIView,
                                                         cameraAnimationsManager: CameraAnimationsManagerProtocol) -> GestureHandler {
        let gestureRecognizer = TouchBeganGestureRecognizer()
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delaysTouchesEnded = false
        view.addGestureRecognizer(gestureRecognizer)

        return InterruptDecelerationGestureHandler(gestureRecognizer: gestureRecognizer,
                                                   cameraAnimationsManager: cameraAnimationsManager)
    }

    internal func makeGestureManager(view: UIView,
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
            anyTouchGestureHandler: makeAnyTouchGestureHandler(view: view,
                                                               cameraAnimationsManager: cameraAnimationsManager),
            interruptDecelerationGestureHandler: makeInterruptDecelerationGestureHandler(
                view: view,
                cameraAnimationsManager: cameraAnimationsManager),
            mapboxMap: mapboxMap)
    }

    internal func makeAnnotationOrchestratorImpl(in view: UIView,
                                                 mapboxMap: MapboxMapProtocol,
                                                 mapFeatureQueryable: MapFeatureQueryable,
                                                 style: StyleProtocol,
                                                 displayLinkCoordinator: DisplayLinkCoordinator) -> AnnotationOrchestratorImplProtocol {
        let tapGetureRecognizer = UITapGestureRecognizer()
        let longPressGestureRecognizer = MapboxLongPressGestureRecognizer()
        view.addGestureRecognizer(tapGetureRecognizer)
        view.addGestureRecognizer(longPressGestureRecognizer)

        let offsetPointCalculator = OffsetPointCalculator(mapboxMap: mapboxMap)
        let offsetLineStringCalculator = OffsetLineStringCalculator(mapboxMap: mapboxMap)
        let offsetPolygonCalculator = OffsetPolygonCalculator(mapboxMap: mapboxMap)
        let factory = AnnotationManagerFactory(
            style: style,
            displayLinkCoordinator: displayLinkCoordinator,
            offsetPointCalculator: offsetPointCalculator,
            offsetPolygonCalculator: offsetPolygonCalculator,
            offsetLineStringCalculator: offsetLineStringCalculator)
        return AnnotationOrchestratorImpl(
            tapGestureRecognizer: tapGetureRecognizer,
            longPressGestureRecognizer: longPressGestureRecognizer,
            mapFeatureQueryable: mapFeatureQueryable,
            factory: factory)
    }

    internal func makeLocationProducer(mayRequestWhenInUseAuthorization: Bool,
                                       userInterfaceOrientationView: UIView) -> LocationProducerProtocol {
        let locationProvider = AppleLocationProvider()
        return LocationProducer(
            locationProvider: locationProvider,
            interfaceOrientationProvider: interfaceOrientationProvider,
            notificationCenter: notificationCenter,
            userInterfaceOrientationView: userInterfaceOrientationView,
            device: .current,
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
                                   anyTouchGestureRecognizer: UIGestureRecognizer,
                                   doubleTapGestureRecognizer: UIGestureRecognizer,
                                   doubleTouchGestureRecognizer: UIGestureRecognizer) -> ViewportImplProtocol {
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

    func makeEventsManager(accessToken: String) -> EventsManagerProtocol {
        return EventsManager(accessToken: accessToken)
    }
}
