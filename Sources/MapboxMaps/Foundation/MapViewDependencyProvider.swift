import MetalKit

protocol MapViewDependencyProviderProtocol: AnyObject {
    var notificationCenter: NotificationCenterProtocol { get }
    var bundle: BundleProtocol { get }
    func makeMetalView(frame: CGRect, device: MTLDevice?) -> MetalView
    func makeDisplayLink(window: UIWindow, target: Any, selector: Selector) -> DisplayLinkProtocol?
    func makeCameraAnimatorsRunner(mapboxMap: MapboxMapProtocol) -> CameraAnimatorsRunnerProtocol
    func makeCameraAnimationsManagerImpl(cameraViewContainerView: UIView,
                                         mapboxMap: MapboxMapProtocol,
                                         cameraAnimatorsRunner: CameraAnimatorsRunnerProtocol) -> CameraAnimationsManagerProtocol
    func makeGestureManager(view: UIView,
                            mapboxMap: MapboxMapProtocol,
                            mapFeatureQueryable: MapFeatureQueryable,
                            annotations: AnnotationOrchestratorImplProtocol,
                            cameraAnimationsManager: CameraAnimationsManagerProtocol) -> GestureManager
    // swiftlint:disable:next function_parameter_count
    func makeViewportManagerImpl(mapboxMap: MapboxMapProtocol,
                                 cameraAnimationsManager: CameraAnimationsManagerProtocol,
                                 safeAreaInsets: Signal<UIEdgeInsets>,
                                 isDefaultCameraInitialized: Signal<Bool>,
                                 anyTouchGestureRecognizer: UIGestureRecognizer,
                                 doubleTapGestureRecognizer: UIGestureRecognizer,
                                 doubleTouchGestureRecognizer: UIGestureRecognizer) -> ViewportManagerImplProtocol
    func makeAnnotationOrchestratorImpl(
        in view: UIView,
        mapboxMap: MapboxMapProtocol,
        mapFeatureQueryable: MapFeatureQueryable,
        style: StyleProtocol,
        displayLink: Signal<Void>
    ) -> AnnotationOrchestratorImplProtocol

    func makeEventsManager() -> EventsManagerProtocol
}

final class MapViewDependencyProvider: MapViewDependencyProviderProtocol {
    internal let notificationCenter: NotificationCenterProtocol = NotificationCenter.default

    internal let bundle: BundleProtocol = Bundle.main

    private let mainQueue: MainQueueProtocol = MainQueueWrapper()

    internal func makeMetalView(frame: CGRect, device: MTLDevice?) -> MetalView {
        MetalView(frame: frame, device: device)
    }

    internal func makeDisplayLink(window: UIWindow, target: Any, selector: Selector) -> DisplayLinkProtocol? {
#if swift(>=5.9) && os(visionOS)
        return CADisplayLink(target: target, selector: selector)
#else
        window.screen.displayLink(withTarget: target, selector: selector)
#endif
    }

    internal func makeCameraAnimatorsRunner(mapboxMap: MapboxMapProtocol) -> CameraAnimatorsRunnerProtocol {
        CameraAnimatorsRunner(mapboxMap: mapboxMap)
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
        return PinchGestureHandler(gestureRecognizer: gestureRecognizer, mapboxMap: mapboxMap)
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
                                             cameraAnimationsManager: CameraAnimationsManagerProtocol) -> SingleTapGestureHandler {
        let gestureRecognizer = UITapGestureRecognizer()
        view.addGestureRecognizer(gestureRecognizer)
        return SingleTapGestureHandler(
            gestureRecognizer: gestureRecognizer,
            cameraAnimationsManager: cameraAnimationsManager)
    }

    private func makeAnyTouchGestureHandler(
        view: UIView,
        cameraAnimationsManager: CameraAnimationsManagerProtocol) -> GestureHandler {
        // Cancel animations and idle viewport when pan gesture begins.
        let gestureRecognizer = UIPanGestureRecognizer()
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

    func makeGestureManager(
        view: UIView,
        mapboxMap: MapboxMapProtocol,
        mapFeatureQueryable: MapFeatureQueryable,
        annotations: AnnotationOrchestratorImplProtocol,
        cameraAnimationsManager: CameraAnimationsManagerProtocol
    ) -> GestureManager {
        let singleTap = makeSingleTapGestureHandler(
            view: view,
            cameraAnimationsManager: cameraAnimationsManager)

        let longPress = LongPressGestureHandler()
        view.addGestureRecognizer(longPress.recognizer)

        let mapContentGestureManager = MapContentGestureManager(
            annotations: annotations,
            mapboxMap: mapboxMap,
            mapFeatureQueryable: mapFeatureQueryable,
            onTap: singleTap.onTap,
            onLongPress: longPress.signal.retaining(longPress))

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
            singleTapGestureHandler: singleTap,
            anyTouchGestureHandler: makeAnyTouchGestureHandler(view: view,
                                                               cameraAnimationsManager: cameraAnimationsManager),
            interruptDecelerationGestureHandler: makeInterruptDecelerationGestureHandler(
                view: view,
                cameraAnimationsManager: cameraAnimationsManager),
            mapboxMap: mapboxMap,
            mapContentGestureManager: mapContentGestureManager)
    }

    func makeAnnotationOrchestratorImpl(
        in view: UIView,
        mapboxMap: MapboxMapProtocol,
        mapFeatureQueryable: MapFeatureQueryable,
        style: StyleProtocol,
        displayLink: Signal<Void>
    ) -> AnnotationOrchestratorImplProtocol {
        let offsetPointCalculator = OffsetPointCalculator(mapboxMap: mapboxMap)
        let offsetLineStringCalculator = OffsetLineStringCalculator(mapboxMap: mapboxMap)
        let offsetPolygonCalculator = OffsetPolygonCalculator(mapboxMap: mapboxMap)
        let factory = AnnotationManagerFactory(
            style: style,
            displayLink: displayLink,
            offsetPointCalculator: offsetPointCalculator,
            offsetPolygonCalculator: offsetPolygonCalculator,
            offsetLineStringCalculator: offsetLineStringCalculator,
            mapFeatureQueryable: mapFeatureQueryable)
        return AnnotationOrchestratorImpl(factory: factory)
    }

    // swiftlint:disable:next function_parameter_count
    internal func makeViewportManagerImpl(
        mapboxMap: MapboxMapProtocol,
        cameraAnimationsManager: CameraAnimationsManagerProtocol,
        safeAreaInsets: Signal<UIEdgeInsets>,
        isDefaultCameraInitialized: Signal<Bool>,
        anyTouchGestureRecognizer: UIGestureRecognizer,
        doubleTapGestureRecognizer: UIGestureRecognizer,
        doubleTouchGestureRecognizer: UIGestureRecognizer
    ) -> ViewportManagerImplProtocol {
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
        return ViewportManagerImpl(
            options: .init(),
            mapboxMap: mapboxMap,
            safeAreaInsets: safeAreaInsets,
            isDefaultCameraInitialized: isDefaultCameraInitialized,
            mainQueue: mainQueue,
            defaultTransition: defaultViewportTransition,
            anyTouchGestureRecognizer: anyTouchGestureRecognizer,
            doubleTapGestureRecognizer: doubleTapGestureRecognizer,
            doubleTouchGestureRecognizer: doubleTouchGestureRecognizer)
    }

    func makeEventsManager() -> EventsManagerProtocol {
        return EventsManager()
    }
}
