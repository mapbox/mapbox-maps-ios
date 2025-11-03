import MetalKit

/// A protocol that defines the interface for creating MapView dependencies.
///
/// `MapViewDependencyProviderProtocol` abstracts the creation of various components
/// needed by `MapView`, allowing for dependency injection and improved testability.
/// This protocol enables the use of mock implementations during testing and provides
/// a clean separation between the MapView and its dependencies.
///
/// The protocol covers all major MapView subsystems:
/// - Metal rendering infrastructure
/// - Display link management
/// - Camera animation system
/// - Gesture handling
/// - Viewport management
/// - Event tracking
protocol MapViewDependencyProviderProtocol: AnyObject {
    /// The notification center used for system event notifications.
    var notificationCenter: NotificationCenterProtocol { get }
    
    /// The bundle used for accessing app resources and configuration.
    var bundle: BundleProtocol { get }
    
    /// Creates a Metal view for rendering the map content.
    ///
    /// - Parameters:
    ///   - frame: The frame rectangle for the Metal view.
    ///   - device: The Metal device to use for rendering, or nil to use the default device.
    /// - Returns: A configured Metal view ready for map rendering.
    func makeMetalView(frame: CGRect, device: MTLDevice?) -> MetalView
    
    /// Creates a display link for synchronizing rendering with the display refresh rate.
    ///
    /// - Parameters:
    ///   - window: The window associated with the display link.
    ///   - target: The target object that will receive display link callbacks.
    ///   - selector: The selector to call on the target when the display link fires.
    /// - Returns: A display link instance, or nil if creation fails.
    func makeDisplayLink(window: UIWindow, target: Any, selector: Selector) -> DisplayLinkProtocol?
    
    /// Creates a camera animators runner for managing camera animations.
    ///
    /// - Parameter mapboxMap: The map instance to animate.
    /// - Returns: A camera animators runner configured for the specified map.
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

/// The default implementation of `MapViewDependencyProviderProtocol`.
///
/// `MapViewDependencyProvider` creates real instances of all MapView dependencies
/// using the system's default implementations. This is the production implementation
/// used in normal app usage, providing concrete instances of Metal views, display links,
/// gesture managers, and other components.
///
/// The provider handles the complex initialization of interconnected components,
/// ensuring proper dependency injection and configuration of all subsystems.
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
