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
                            cameraAnimationsManager: CameraAnimationsManagerProtocol) -> GestureManager
    // swiftlint:disable:next function_parameter_count
    func makeViewportManagerImpl(mapboxMap: MapboxMapProtocol,
                                 cameraAnimationsManager: CameraAnimationsManagerProtocol,
                                 safeAreaInsets: Signal<UIEdgeInsets>,
                                 isDefaultCameraInitialized: Signal<Bool>,
                                 anyTouchGestureRecognizer: UIGestureRecognizer,
                                 doubleTapGestureRecognizer: UIGestureRecognizer,
                                 doubleTouchGestureRecognizer: UIGestureRecognizer) -> ViewportManagerImplProtocol

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

    // swiftlint:disable:next function_body_length
    func makeGestureManager(
        view: UIView,
        mapboxMap: MapboxMapProtocol,
        cameraAnimationsManager: CameraAnimationsManagerProtocol
    ) -> GestureManager {
        let singleTap = SingleTapGestureHandler(
            gestureRecognizer: UITapGestureRecognizer(),
            map: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)

        let longPress = LongPressGestureHandler(
            gestureRecognizer: UILongPressGestureRecognizer(),
            map: mapboxMap)

        let pan = PanGestureHandler(
            gestureRecognizer: UIPanGestureRecognizer(),
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager,
            dateProvider: DefaultDateProvider())

        let pinch = PinchGestureHandler(gestureRecognizer: UIPinchGestureRecognizer(), mapboxMap: mapboxMap)
        let rotate = RotateGestureHandler(gestureRecognizer: UIRotationGestureRecognizer(), mapboxMap: mapboxMap)
        let pitch =  PitchGestureHandler(gestureRecognizer: UIPanGestureRecognizer(), mapboxMap: mapboxMap)

        let doubleTouchToZoomIn =  DoubleTapToZoomInGestureHandler(
            gestureRecognizer: UITapGestureRecognizer(),
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)

        let doubleTouchToZoomOut = DoubleTouchToZoomOutGestureHandler(
            gestureRecognizer: UITapGestureRecognizer(),
            mapboxMap: mapboxMap,
            cameraAnimationsManager: cameraAnimationsManager)

        let quickZoom = QuickZoomGestureHandler(
            gestureRecognizer: UILongPressGestureRecognizer(),
            mapboxMap: mapboxMap)

        // Cancel animations and idle viewport when pan gesture begins.
        let anyTouch =  AnyTouchGestureHandler(
            gestureRecognizer: UIPanGestureRecognizer(),
            cameraAnimationsManager: cameraAnimationsManager)

        let interruptDeceleration = InterruptDecelerationGestureHandler(
            gestureRecognizer: {
                let gesture = TouchBeganGestureRecognizer()
                gesture.cancelsTouchesInView = false
                gesture.delaysTouchesEnded = false
                return gesture
            }(),
            cameraAnimationsManager: cameraAnimationsManager)

        for gestureHandler in [singleTap, longPress, pan, pinch, rotate, pitch, doubleTouchToZoomIn, doubleTouchToZoomOut, quickZoom, anyTouch, interruptDeceleration] {
            view.addGestureRecognizer(gestureHandler.gestureRecognizer)
        }

        return GestureManager(
            panGestureHandler: pan,
            pinchGestureHandler: pinch,
            rotateGestureHandler: rotate,
            pitchGestureHandler: pitch,
            doubleTapToZoomInGestureHandler: doubleTouchToZoomIn,
            doubleTouchToZoomOutGestureHandler: doubleTouchToZoomOut,
            quickZoomGestureHandler: quickZoom,
            singleTapGestureHandler: singleTap,
            longPressGestureHandler: longPress,
            anyTouchGestureHandler: anyTouch,
            interruptDecelerationGestureHandler: interruptDeceleration,
            mapboxMap: mapboxMap)
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
