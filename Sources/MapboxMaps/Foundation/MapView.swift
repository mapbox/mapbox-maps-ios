// swiftlint:disable file_length
@_exported import MapboxCoreMaps
@_exported import MapboxCommon
@_exported import MetalKit
@_exported import Turf
@_implementationOnly import MapboxCoreMaps_Private
@_implementationOnly import MapboxCommon_Private
#if os(OSX)
import AppKit
#else
import UIKit
#endif

// swiftlint:disable type_body_length
open class MapView: View {

    // `mapboxMap` depends on `MapInitOptions`, which is not available until
    // awakeFromNib() when instantiating MapView from a xib or storyboard.
    // This is the only reason that it is an implicitly-unwrapped optional var
    // instead of a non-optional let.
    public private(set) var mapboxMap: MapboxMap! {
        didSet {
            assert(oldValue == nil, "mapboxMap should only be set once.")
        }
    }

    /// The `gestures` object will be responsible for all gestures on the map.
    public private(set) var gestures: GestureManager!

    #if os(iOS)
    /// The `ornaments`object will be responsible for all ornaments on the map.
    public private(set) var ornaments: OrnamentsManager!
    #endif

    /// The `camera` object manages a camera's view lifecycle.
    public private(set) var camera: CameraAnimationsManager!
    private var cameraAnimatorsRunner: CameraAnimatorsRunnerProtocol!
    private let cameraAnimatorsRunnerEnablable: MutableEnablableProtocol

    /// The `location`object handles location events of the map.
    public private(set) var location: LocationManager!
    private var locationProducer: LocationProducerProtocol!

    /// Controls the addition/removal of annotations to the map.
    public private(set) var annotations: AnnotationOrchestrator!

    /// Manages the configuration of custom view annotations on the map.
    public private(set) var viewAnnotations: ViewAnnotationManager!

    /// ``Viewport`` is a high-level and extensible API for driving the map camera. It
    /// provides built-in states for following the location puck and showing an overview of
    /// a GeoJSON geometry, and enables the creation of custom states. Transitions
    /// between states can be animated with a built-in default transition and via custom
    /// transitions.
    public private(set) var viewport: Viewport!

#if os(iOS)
    /// Controls the display of attribution dialogs
    private var attributionDialogManager: AttributionDialogManager!
#endif

    /// A Boolean value that indicates whether the underlying `CAMetalLayer` of the `MapView`
    /// presents its content using a CoreAnimation transaction
    ///
    /// By default, this is `false` resulting in the output of a rendering pass being displayed on
    /// the `CAMetalLayer` as quickly as possible (and asynchronously). This typically results
    /// in the fastest rendering performance.
    ///
    /// If, however, the `MapView` is overlaid with a `UIKit` element which must
    /// be pinned to a particular lat-long, then setting this to `true` will
    /// result in better synchronization and less jitter.
    public var presentsWithTransaction: Bool {
        get {
            return metalView?.presentsWithTransaction ?? false
        }
        set {
            metalView?.presentsWithTransaction = newValue
        }
    }

    /// The underlying metal view that is used to render the map
    internal private(set) var metalView: MTKView?

    private let cameraViewContainerView = View()

    /// Holds ViewAnnotation views
    private let viewAnnotationContainerView = SubviewInteractionOnlyView()

    /// Resource options for this map view
    internal private(set) var resourceOptions: ResourceOptions!

    private var needsDisplayRefresh: Bool = false
    private var displayLink: DisplayLinkProtocol?
    private var cvDisplayLink: CVDisplayLink?

    /// Holding onto this value that comes from `MapOptions` since there is a race condition between
    /// getting a `MetalView`, and intializing a `MapView`
    private var pixelRatio: CGFloat = 0.0

    @IBInspectable private var styleURI__: String = ""

    /// Outlet that can be used when initializing a MapView with a Storyboard or
    /// a nib.
    @IBOutlet internal private(set) weak var mapInitOptionsProvider: MapInitOptionsProvider?

    private let dependencyProvider: MapViewDependencyProviderProtocol

    private let displayLinkParticipants = WeakSet<DisplayLinkParticipant>()

    private let notificationCenter: NotificationCenterProtocol
    private let bundle: BundleProtocol

    /*** The preferred frames per second used for map rendering.
        NOTE: `MapView.preferredFrameRateRange` is available for iOS 15.0 and above.
     */
    @available(iOS, deprecated: 1000000)
    public var preferredFramesPerSecond: Int {
        get {
            return _preferredFramesPerSecond ?? displayLink?.preferredFramesPerSecond ?? 0
        }
        set {
            _preferredFramesPerSecond = newValue
        }
    }

    private var _preferredFramesPerSecond: Int? {
        didSet {
            updateDisplayLinkPreferredFramesPerSecond()
        }
    }

    // Checking Swift version as a proxy for iOS SDK version to enable
    // building with iOS SDKs < 15
    #if swift(>=5.5)
    /// The preferred range of frame refresh rates.
    @available(iOS 15.0, *)
    public var preferredFrameRateRange: CAFrameRateRange {
        get {
            return _preferredFrameRateRange ?? displayLink?.preferredFrameRateRange ?? .default
        }
        set {
            _preferredFrameRateRange = newValue
        }
    }

    // Stored properties cannot be annotated with @available, so we
    // store the value as an `Any` in `_untypedPreferredFrameRateRange` below
    // and make this a computed property.
    @available(iOS 15.0, *)
    private var _preferredFrameRateRange: CAFrameRateRange? {
        get {
            return _untypedPreferredFrameRateRange as? CAFrameRateRange
        }
        set {
            _untypedPreferredFrameRateRange = newValue
            updateDisplayLinkPreferredFramesPerSecond()
        }
    }

    private var _untypedPreferredFrameRateRange: Any?
    #endif

    /// The `timestamp` from the underlying `CADisplayLink` if it exists, otherwise `nil`.
    /// :nodoc:
    /// This property is for internal metrics purposes only and should not be considered part of the public API.
    @_spi(Metrics) public var displayLinkTimestamp: CFTimeInterval? {
        return displayLink?.timestamp
    }

    /// The `duration` from the underlying `CADisplayLink` if it exists, otherwise `nil`
    /// :nodoc:
    /// This property is for internal metrics purposes only and should not be considered part of the public API.
    @_spi(Metrics) public var displayLinkDuration: CFTimeInterval? {
        return displayLink?.duration
    }

    /// The map's current camera
    public var cameraState: CameraState {
        return mapboxMap.cameraState
    }

    /// The map's current anchor, calculated after applying padding (if it exists)
    public var anchor: CGPoint {
        return mapboxMap.anchor
    }

#if os(iOS)
    private let interfaceOrientationProvider: InterfaceOrientationProvider
#endif
    internal let attributionUrlOpener: AttributionURLOpener

    /// Initialize a MapView
    /// - Parameters:
    ///   - frame: frame for the MapView.
    ///   - mapInitOptions: `MapInitOptions`; default uses
    ///    `ResourceOptionsManager.default` to retrieve a shared default resource option, including the access token.
    @available(iOSApplicationExtension, unavailable)
    public init(frame: CGRect, mapInitOptions: MapInitOptions = MapInitOptions()) {
#if os(iOS)
        let orientationProvider: InterfaceOrientationProvider
        if #available(iOS 13, *) {
            orientationProvider = DefaultInterfaceOrientationProvider()
        } else {
            orientationProvider = UIApplicationInterfaceOrientationProvider()
        }
#endif

        self.dependencyProvider = MapViewDependencyProvider()
#if os(iOS)
        self.interfaceOrientationProvider = orientationProvider
#endif
        self.attributionUrlOpener = DefaultAttributionURLOpener()
        notificationCenter = dependencyProvider.notificationCenter
        bundle = dependencyProvider.bundle
        cameraAnimatorsRunnerEnablable = dependencyProvider.cameraAnimatorsRunnerEnablable
        super.init(frame: frame)
        commonInit(mapInitOptions: mapInitOptions, overridingStyleURI: nil)
    }

#if os(iOS)
    /// Initialize a MapView
    /// - Parameters:
    ///   - frame: frame for the MapView.
    ///   - mapInitOptions: `MapInitOptions`; default uses
    ///    `ResourceOptionsManager.default` to retrieve a shared default resource option, including the access token.
    ///   - orientationProvider: User interface orientation provider
    ///   - urlOpener: Attribution URL opener
    @available(iOS, deprecated: 13, message: "Use init(frame:mapInitOptions:urlOpener:) instead")
    public init(frame: CGRect,
                mapInitOptions: MapInitOptions = MapInitOptions(),
                orientationProvider: InterfaceOrientationProvider,
                urlOpener: AttributionURLOpener) {
        self.dependencyProvider = MapViewDependencyProvider()
        self.interfaceOrientationProvider = orientationProvider
        self.attributionUrlOpener = urlOpener
        notificationCenter = dependencyProvider.notificationCenter
        bundle = dependencyProvider.bundle
        cameraAnimatorsRunnerEnablable = dependencyProvider.cameraAnimatorsRunnerEnablable
        super.init(frame: frame)
        commonInit(mapInitOptions: mapInitOptions, overridingStyleURI: nil)
    }
#endif

    /// Initialize a MapView
    /// - Parameters:
    ///   - frame: frame for the MapView.
    ///   - mapInitOptions: `MapInitOptions`; default uses
    ///    `ResourceOptionsManager.default` to retrieve a shared default resource option, including the access token.
    ///   - urlOpener: Attribution URL opener
    @available(iOS 13.0, *)
    public init(frame: CGRect,
                mapInitOptions: MapInitOptions = MapInitOptions(),
                urlOpener: AttributionURLOpener) {
        self.dependencyProvider = MapViewDependencyProvider()
#if os(iOS)
        self.interfaceOrientationProvider = DefaultInterfaceOrientationProvider()
#endif
        self.attributionUrlOpener = urlOpener
        notificationCenter = dependencyProvider.notificationCenter
        bundle = dependencyProvider.bundle
        cameraAnimatorsRunnerEnablable = dependencyProvider.cameraAnimatorsRunnerEnablable
        super.init(frame: frame)
        commonInit(mapInitOptions: mapInitOptions, overridingStyleURI: nil)
    }

    @available(iOSApplicationExtension, unavailable)
    required public init?(coder: NSCoder) {
#if os(iOS)
        let orientationProvider: InterfaceOrientationProvider
        if #available(iOS 13, *) {
            orientationProvider = DefaultInterfaceOrientationProvider()
        } else {
            orientationProvider = UIApplicationInterfaceOrientationProvider()
        }
#endif

        dependencyProvider = MapViewDependencyProvider()
        notificationCenter = dependencyProvider.notificationCenter
        bundle = dependencyProvider.bundle
        cameraAnimatorsRunnerEnablable = dependencyProvider.cameraAnimatorsRunnerEnablable
#if os(iOS)
        self.interfaceOrientationProvider = orientationProvider
#endif
        self.attributionUrlOpener = DefaultAttributionURLOpener()
        super.init(coder: coder)
    }

    internal init(frame: CGRect,
                  mapInitOptions: MapInitOptions,
                  dependencyProvider: MapViewDependencyProviderProtocol,
                  orientationProvider: InterfaceOrientationProvider,
                  urlOpener: AttributionURLOpener) {
        self.dependencyProvider = dependencyProvider
        #if os(iOS)
        self.interfaceOrientationProvider = orientationProvider
        #endif
        self.attributionUrlOpener = urlOpener
        notificationCenter = dependencyProvider.notificationCenter
        bundle = dependencyProvider.bundle
        cameraAnimatorsRunnerEnablable = dependencyProvider.cameraAnimatorsRunnerEnablable
        super.init(frame: frame)
        commonInit(mapInitOptions: mapInitOptions, overridingStyleURI: nil)
    }

    /// :nodoc:
    /// See https://developer.apple.com/forums/thread/650054 for context
    @available(*, unavailable)
    internal override init(frame: CGRect) {
        fatalError("This initializer should not be called.")
    }

    private func commonInit(mapInitOptions: MapInitOptions, overridingStyleURI: URL?) {
        checkForMetalSupport()

        self.resourceOptions = mapInitOptions.resourceOptions

        let resolvedMapInitOptions: MapInitOptions
        if mapInitOptions.mapOptions.size == nil {
            // Update using the view's size
            let original = mapInitOptions.mapOptions
            let resolvedMapOptions = MapOptions(
                __contextMode: original.__contextMode,
                constrainMode: original.__constrainMode,
                viewportMode: original.__viewportMode,
                orientation: original.__orientation,
                crossSourceCollisions: original.__crossSourceCollisions,
                optimizeForTerrain: original.__optimizeForTerrain,
                size: Size(width: Float(bounds.width), height: Float(bounds.height)),
                pixelRatio: original.pixelRatio,
                glyphsRasterizationOptions: original.glyphsRasterizationOptions)
            resolvedMapInitOptions = MapInitOptions(
                resourceOptions: mapInitOptions.resourceOptions,
                mapOptions: resolvedMapOptions,
                cameraOptions: mapInitOptions.cameraOptions,
                styleURI: mapInitOptions.styleURI)
        } else {
            resolvedMapInitOptions = mapInitOptions
        }

        self.pixelRatio = CGFloat(resolvedMapInitOptions.mapOptions.pixelRatio)

        let mapClient = DelegatingMapClient()
        mapClient.delegate = self
        mapboxMap = MapboxMap(
            mapClient: mapClient,
            mapInitOptions: resolvedMapInitOptions,
            mapboxObservableProvider: dependencyProvider.mapboxObservableProvider)

        subscribeToLifecycleNotifications()
#if os(iOS)
        notificationCenter.addObserver(self,
                                       selector: #selector(didReceiveMemoryWarning),
                                       name: UIApplication.didReceiveMemoryWarningNotification,
                                       object: nil)
#endif

        // Use the overriding style URI if provided (currently from IB)
        if let initialStyleURI = overridingStyleURI,
           let styleURI = StyleURI(url: initialStyleURI) {
            mapboxMap.loadStyleURI(styleURI)
        } else if let initialStyleURI = resolvedMapInitOptions.styleURI {
            mapboxMap.loadStyleURI(initialStyleURI)
        }

        if let cameraOptions = resolvedMapInitOptions.cameraOptions {
            mapboxMap.setCamera(to: cameraOptions)
        }

        if let metalView = metalView {
#if os(iOS)
            insertSubview(viewAnnotationContainerView, aboveSubview: metalView)
            #else
            addSubview(viewAnnotationContainerView, positioned: .above, relativeTo: metalView)
            #endif
        }

        viewAnnotationContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewAnnotationContainerView.topAnchor.constraint(equalTo: topAnchor),
            viewAnnotationContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            viewAnnotationContainerView.leftAnchor.constraint(equalTo: leftAnchor),
            viewAnnotationContainerView.rightAnchor.constraint(equalTo: rightAnchor)
        ])

        cameraViewContainerView.isHidden = true
        addSubview(cameraViewContainerView)

        // Setup Telemetry logging. Delay initialization by 10 seconds.
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            guard let accessToken = self?.resourceOptions.accessToken else { return }
            let eventsManager = EventsManager.shared(withAccessToken: accessToken)
            eventsManager.sendTurnstile()
            eventsManager.sendMapLoadEvent()
        }

        // false until added to a window and display link is created
        cameraAnimatorsRunnerEnablable.isEnabled = false

        // Set up managers
        setupManagers()
    }

    internal func setupManagers() {
        // Initialize/Configure camera manager first since Gestures needs it as dependency
        cameraAnimatorsRunner = dependencyProvider.makeCameraAnimatorsRunner(
            mapboxMap: mapboxMap)
        let internalCamera = dependencyProvider.makeCameraAnimationsManagerImpl(
            cameraViewContainerView: cameraViewContainerView,
            mapboxMap: mapboxMap,
            cameraAnimatorsRunner: cameraAnimatorsRunner)
        camera = CameraAnimationsManager(impl: internalCamera)

        // Initialize/Configure gesture manager
        gestures = dependencyProvider.makeGestureManager(
            view: self,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: internalCamera)

#if os(iOS)
        // Initialize the attribution manager
        attributionDialogManager = AttributionDialogManager(
            dataSource: mapboxMap,
            delegate: self)

        // Initialize/Configure ornaments manager
        ornaments = OrnamentsManager(
            options: OrnamentOptions(),
            view: self,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: internalCamera,
            infoButtonOrnamentDelegate: attributionDialogManager,
            logoView: LogoView(logoSize: .regular()),
            scaleBarView: MapboxScaleBarOrnamentView(),
            compassView: MapboxCompassOrnamentView(),
            attributionButton: InfoButtonOrnament())
#endif

        // Initialize/Configure location source and location manager
        locationProducer = dependencyProvider.makeLocationProducer(
            mayRequestWhenInUseAuthorization: bundle.infoDictionary?["NSLocationWhenInUseUsageDescription"] != nil)
        let interpolatedLocationProducer = dependencyProvider.makeInterpolatedLocationProducer(
            locationProducer: locationProducer,
            displayLinkCoordinator: self)
        location = dependencyProvider.makeLocationManager(
            locationProducer: locationProducer,
            interpolatedLocationProducer: interpolatedLocationProducer,
            style: mapboxMap.style,
            mapboxMap: mapboxMap,
            displayLinkCoordinator: self)

        // Initialize/Configure annotations orchestrator
        annotations = AnnotationOrchestrator(
            gestureRecognizer: gestures.singleTapGestureRecognizer,
            mapFeatureQueryable: mapboxMap,
            style: mapboxMap.style,
            displayLinkCoordinator: self)

        // Initialize/Configure view annotations manager
        viewAnnotations = ViewAnnotationManager(
            containerView: viewAnnotationContainerView,
            mapboxMap: mapboxMap)

        viewport = Viewport(
            impl: dependencyProvider.makeViewportImpl(
                mapboxMap: mapboxMap,
                cameraAnimationsManager: internalCamera,
                anyTouchGestureRecognizer: gestures.anyTouchGestureRecognizer,
                doubleTapGestureRecognizer: gestures.doubleTapToZoomInGestureRecognizer,
                doubleTouchGestureRecognizer: gestures.doubleTouchToZoomOutGestureRecognizer),
            interpolatedLocationProducer: interpolatedLocationProducer,
            cameraAnimationsManager: internalCamera,
            mapboxMap: mapboxMap)
    }

    deinit {
        cameraAnimatorsRunner.cancelAnimations()
        cameraAnimatorsRunnerEnablable.isEnabled = false
    }


    private func subscribeToLifecycleNotifications() {
#if os(iOS)
        if #available(iOS 13.0, *), bundle.infoDictionary?["UIApplicationSceneManifest"] != nil {
            notificationCenter.addObserver(self,
                                           selector: #selector(sceneDidEnterBackground(_:)),
                                           name: UIScene.didEnterBackgroundNotification,
                                           object: window?.parentScene)
            notificationCenter.addObserver(self,
                                           selector: #selector(sceneWillDeactivate(_:)),
                                           name: UIScene.willDeactivateNotification,
                                           object: window?.parentScene)
            notificationCenter.addObserver(self,
                                           selector: #selector(sceneDidActivate(_:)),
                                           name: UIScene.didActivateNotification,
                                           object: window?.parentScene)
        } else {
            notificationCenter.addObserver(self,
                                           selector: #selector(appDidEnterBackground),
                                           name: UIApplication.didEnterBackgroundNotification,
                                           object: nil)
            notificationCenter.addObserver(self,
                                           selector: #selector(appDidBecomeActive),
                                           name: UIApplication.didBecomeActiveNotification,
                                           object: nil)
            notificationCenter.addObserver(self,
                                           selector: #selector(appWillResignActive),
                                           name: UIApplication.willResignActiveNotification,
                                           object: nil)
        }
#endif
    }

    @objc private func appDidEnterBackground() {
        reduceMemoryUse()
    }

    @objc private func appDidBecomeActive() {
        displayLink?.isPaused = false
    }

    @objc private func appWillResignActive() {
        displayLink?.isPaused = true
    }

#if os(iOS)
    @available(iOS 13.0, *)
    @objc private func sceneDidActivate(_ notification: Notification) {
        guard notification.object as? UIScene == window?.parentScene else { return }

        displayLink?.isPaused = false
    }

    @available(iOS 13, *)
    @objc private func sceneWillDeactivate(_ notification: Notification) {
        guard notification.object as? UIScene == window?.parentScene else { return }

        displayLink?.isPaused = true
    }

    @available(iOS 13, *)
    @objc private func sceneDidEnterBackground(_ notification: Notification) {
        guard notification.object as? UIScene == window?.parentScene else { return }

        reduceMemoryUse()
    }
#endif

    @objc private func didReceiveMemoryWarning() {
        reduceMemoryUse()
    }

    private func reduceMemoryUse() {
        mapboxMap.reduceMemoryUse()
        metalView?.releaseDrawables()
    }

    private func checkForMetalSupport() {
        #if targetEnvironment(simulator)
        guard MTLCreateSystemDefaultDevice() == nil else {
            return
        }

        // Metal is unavailable on older simulators
        guard ProcessInfo().isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 13, minorVersion: 0, patchVersion: 0)) else {
            Log.warning(forMessage: "Metal rendering is not supported on iOS versions < iOS 13. Please test on device or on iOS simulators version >= 13.", category: "MapView")
            return
        }

        // Metal is unavailable for a different reason
        Log.error(forMessage: "No suitable Metal simulator can be found.", category: "MapView")
        #endif
    }

    class internal func parseIBString(ibString: String) -> String? {
        let parsedString = ibString.trimmingCharacters(in: .whitespacesAndNewlines)
        return Array(parsedString).count > 0 ? parsedString : nil
    }

    class internal func parseIBStringAsURL(ibString: String) -> URL? {
        let parsedString = ibString.trimmingCharacters(in: .whitespacesAndNewlines)
        return Array(parsedString).count > 0 ? URL(string: parsedString) : nil
    }

    open override func awakeFromNib() {
        super.awakeFromNib()

        let mapInitOptions = mapInitOptionsProvider?.mapInitOptions() ??
            MapInitOptions()

        let ibStyleURI = MapView.parseIBStringAsURL(ibString: styleURI__)

        commonInit(mapInitOptions: mapInitOptions, overridingStyleURI: ibStyleURI)
    }

#if os(iOS)
    open override func layoutSubviews() {
        super.layoutSubviews()
        mapboxMap.size = bounds.size
    }
    #endif


    open override func layout() {
        super.layout()
        mapboxMap.size = bounds.size
    }



    func update(displayLink: CVDisplayLink, tm: UnsafePointer<CVTimeStamp>, tm2: UnsafePointer<CVTimeStamp>, options: CVOptionFlags, options2: UnsafeMutablePointer<CVOptionFlags>) -> CVReturn {
        DispatchQueue.main.async {
            self.redraw(displayLink: displayLink)
        }
        return kCVReturnSuccess
    }

    func redraw(displayLink: CVDisplayLink) {
//        print(CVDisplayLinkGetActualOutputVideoRefreshPeriod(displayLink))
        updateHeadingOrientationIfNeeded()

        for participant in displayLinkParticipants.allObjects {
            participant.participate()
        }

        cameraAnimatorsRunner.update()

        if needsDisplayRefresh {
            needsDisplayRefresh = false
            metalView?.draw()
        }
    }


    open override func scrollWheel(with event: NSEvent) {
//        guard event.type == .scrollWheel, event.subtype == .tabletPoint else { return }
        switch (event.type, event.subtype) {
        case (.scrollWheel, _) where event.modifierFlags.contains(.shift):
            startZooming(with: event)
        case (.scrollWheel, .tabletPoint):
            startPanning(with: event)
        case (.scrollWheel, .mouseEvent):
            startZoomingByMouse(with: event)
        default: break
        }
    }


    var initialZoom: CGFloat?
    func startZooming(with event: NSEvent) {
        switch (event.phase, event.momentumPhase) {
        case (.mayBegin, _), (_, .began):
            initialZoom = mapboxMap.cameraState.zoom
        case (.began, _), (.changed, _), (_, .changed):
            guard let initialZoom = initialZoom else {
                return
            }

            let newZoomLevel = initialZoom - event.scrollingDeltaY / 75

            mapboxMap.setCamera(to: CameraOptions(anchor: event.locationInWindow.flippedVerticalValue(height: mapboxMap.size.height),
                                                  zoom: newZoomLevel))
            self.initialZoom = newZoomLevel
        case (.ended, _), (.cancelled, _):
            initialZoom = nil
        default:
            break
        }
    }

    func startZoomingByMouse(with event: NSEvent) {
        let precision = event.hasPreciseScrollingDeltas ? 100.0 : 10.0
        let delta = event.scrollingDeltaY / precision
        guard delta != 0 else { return }

        var scale = 2.0 / (1.0 + exp(-abs(delta)))
        if delta < 0 {
            scale = 1.0 / scale
        }

        let newZoomLevel = mapboxMap.cameraState.zoom + log2(scale)
        mapboxMap.setCamera(to: CameraOptions(anchor: event.locationInWindow.flippedVerticalValue(height: mapboxMap.size.height),
                                              zoom: newZoomLevel))
    }

    var previousDragPointLocation: CGPoint?
    func startPanning(with event: NSEvent) {
        switch (event.phase, event.momentumPhase) {
        case (.mayBegin, _), (_, .began):

            previousDragPointLocation = .zero

            mapboxMap.dragStart(for: previousDragPointLocation!)
        case (.began, _), (.changed, _), (_, .changed):
            guard let previousDragPointLocation = previousDragPointLocation else {
                return
            }
            let newPoint = CGPoint(x: previousDragPointLocation.x + event.scrollingDeltaX,
                                   y: previousDragPointLocation.y - event.scrollingDeltaY)
            let camera = mapboxMap.dragCameraOptions(from: previousDragPointLocation, to: newPoint)
            mapboxMap.setCamera(to: camera)
            self.previousDragPointLocation = newPoint
        case (.ended, _), (.cancelled, _):
            mapboxMap.dragEnd()
            previousDragPointLocation = nil
        default:
            break
        }
    }

#if os(iOS)
    private func updateFromDisplayLink(displayLink: CADisplayLink) {
        if window == nil {
            return
        }

        updateHeadingOrientationIfNeeded()

        for participant in displayLinkParticipants.allObjects {
            participant.participate()
        }

        cameraAnimatorsRunner.update()

        if needsDisplayRefresh {
            needsDisplayRefresh = false
            metalView?.draw()
        }
    }
    #endif

    private func updateDisplayLinkPreferredFramesPerSecond() {
        if let displayLink = displayLink {
            if let _preferredFramesPerSecond = _preferredFramesPerSecond {
                displayLink.preferredFramesPerSecond = _preferredFramesPerSecond
            }
            // Checking Swift version as a proxy for iOS SDK version to enable
            // building with iOS SDKs < 15
            #if swift(>=5.5)
            if #available(iOS 15.0, *) {
                if let _preferredFrameRateRange = _preferredFrameRateRange {
                    displayLink.preferredFrameRateRange = _preferredFrameRateRange
                }
            }
            #endif
        }
    }

#if os(iOS)
    open override func didMoveToWindow() {
        super.didMoveToWindow()
        didMoveWindowFuncContent()
    }
    #else
    open override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        didMoveWindowFuncContent()
    }
    #endif

    func didMoveWindowFuncContent() {
        displayLink?.invalidate()
        displayLink = nil

        guard let window = window else {
            cameraAnimatorsRunner.cancelAnimations()
            cameraAnimatorsRunnerEnablable.isEnabled = false
            return
        }

#if os(iOS)
        displayLink = dependencyProvider.makeDisplayLink(
            window: window,
            target: ForwardingDisplayLinkTarget { [weak self] in
                self?.updateFromDisplayLink(displayLink: $0)
            },
            selector: #selector(ForwardingDisplayLinkTarget.update(with:)))
#elseif os(OSX)
        let error = CVDisplayLinkCreateWithActiveCGDisplays(&cvDisplayLink)
        if error != kCVReturnSuccess {
            fatalError("Cannot create CVDisplayLink")
        }

        CVDisplayLinkSetOutputHandler(cvDisplayLink!, self.update)
        CVDisplayLinkStart(cvDisplayLink!)
#endif

        guard let displayLink = displayLink else {
            cameraAnimatorsRunner.cancelAnimations()
            cameraAnimatorsRunnerEnablable.isEnabled = false
            return
        }

        cameraAnimatorsRunnerEnablable.isEnabled = true

        updateDisplayLinkPreferredFramesPerSecond()
        displayLink.add(to: .current, forMode: .common)

    }

    // MARK: Location

    private func updateHeadingOrientationIfNeeded() {
#if os(iOS)
        guard let headingOrientation = interfaceOrientationProvider.headingOrientation(for: self) else {
            return
        }

        // We check for heading changes during the display link, but setting it
        // causes a heading update, so we only set it when it changes to avoid
        // unnecessary work.
        //
        // It would be more efficient to update this value by observing
        // interface orientation changes, but you need a view controller to do
        // that (via `willTransition(to:with:)`), which is something we don't
        // have, so we poll instead.
        if locationProducer.headingOrientation != headingOrientation {
            locationProducer.headingOrientation = headingOrientation
        }
#endif
    }
}

extension MapView: DelegatingMapClientDelegate {
    internal func scheduleRepaint() {
        guard let metalView = metalView, !metalView.bounds.isEmpty else {
            return
        }

        needsDisplayRefresh = true
    }

    internal func scheduleTask(forTask task: @escaping Task) {
        fatalError("scheduleTask is not supported")
    }

    internal func getMetalView(for metalDevice: MTLDevice?) -> MTKView? {
        let minSize = CGRect(x: 0, y: 0, width: 1, height: 1)
        let metalView = dependencyProvider.makeMetalView(frame: minSize.union(bounds), device: metalDevice)

        metalView.translatesAutoresizingMaskIntoConstraints = false
        metalView.autoResizeDrawable = true
#if os(iOS)
        metalView.contentScaleFactor = pixelRatio
        metalView.contentMode = .center
        metalView.layer.isOpaque = isOpaque
        metalView.isOpaque = isOpaque
#endif
        metalView.isPaused = true
        metalView.enableSetNeedsDisplay = false
        metalView.presentsWithTransaction = false

#if os(iOS)
        insertSubview(metalView, at: 0)
        #else
        addSubview(metalView, positioned: .below, relativeTo: nil)
#endif


        let sameHeightConstraint = metalView.heightAnchor.constraint(equalTo: heightAnchor)
        sameHeightConstraint.priority = .defaultHigh

        let minHeightConstraint = metalView.heightAnchor.constraint(greaterThanOrEqualToConstant: minSize.height)
        minHeightConstraint.priority = .required

        let sameWidthConstraint = metalView.widthAnchor.constraint(equalTo: widthAnchor)
        sameWidthConstraint.priority = .defaultHigh

        let minWidthConstraint = metalView.widthAnchor.constraint(greaterThanOrEqualToConstant: minSize.width)
        minWidthConstraint.priority = .required

        NSLayoutConstraint.activate([
            metalView.topAnchor.constraint(equalTo: topAnchor),
            sameHeightConstraint,
            minHeightConstraint,
            metalView.leftAnchor.constraint(equalTo: leftAnchor),
            sameWidthConstraint,
            minWidthConstraint
        ])

        self.metalView = metalView

        return metalView
    }
}

extension MapView: DisplayLinkCoordinator {
    func add(_ participant: DisplayLinkParticipant) {
        displayLinkParticipants.add(participant)
    }

    func remove(_ participant: DisplayLinkParticipant) {
        displayLinkParticipants.remove(participant)
    }
}
