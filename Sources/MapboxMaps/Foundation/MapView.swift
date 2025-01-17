// swiftlint:disable file_length
@_implementationOnly import MapboxCommon_Private
import UIKit
import os
import MetalKit

// swiftlint:disable:next type_body_length
open class MapView: UIView, SizeTrackingLayerDelegate {

    /// Handles attribution menu customization
    /// Restricted API. Please contact Mapbox to discuss your use case if you intend to use this property.
    @_spi(Restricted)
    public private(set) var attributionMenu: AttributionMenu!

    open override class var layerClass: AnyClass { SizeTrackingLayer.self }

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

    /// The `ornaments`object will be responsible for all ornaments on the map.
    public private(set) var ornaments: OrnamentsManager!

    /// The `camera` object manages a camera's view lifecycle.
    public private(set) var camera: CameraAnimationsManager!
    private var cameraAnimatorsRunner: CameraAnimatorsRunnerProtocol!

    /// The `location`object handles location events of the map.
    public private(set) var location: LocationManager!

    /// Controls the addition/removal of annotations to the map.
    public private(set) var annotations: AnnotationOrchestrator!

    /// Manages the configuration of custom view annotations on the map.
    public private(set) var viewAnnotations: ViewAnnotationManager!

    /// ``ViewportManager`` provides a high-level and extensible API for driving the map camera. It
    /// provides built-in states for following the location puck and showing an overview of
    /// a GeoJSON geometry, and enables the creation of custom states. Transitions
    /// between states can be animated with a built-in default transition and via custom
    /// transitions.
    public private(set) var viewport: ViewportManager!

    /// Controls the display of attribution dialogs
    private var attributionDialogManager: AttributionDialogManager!

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
    @available(*, deprecated, message: "Use presentationTransactionMode instead")
    public var presentsWithTransaction: Bool {
        get { mapPresentation.presentsWithTransaction }
        set { mapPresentation.presentsWithTransaction = newValue }
    }

    /// Defines the map presentation mode.
    ///
    /// This setting determines whether the underlying `CAMetalLayer` presents its content using a CoreAnimation transaction, controlling `CAMetalLayer.presentsWithTransaction` property.
    ///
    /// By default, the value is ``PresentationTransactionMode/automatic``,  meaning the mode will be switched between async and sync depending on the map content, such as view annotations.
    ///
    /// If you use a custom View displayed on top of the map that should appear at specific map coordinates, set presentation mode to ``PresentationTransactionMode/sync`` to avoid jitter.
    /// However, setting ``PresentationTransactionMode/async`` mode can result in faster rendering in some cases.
    ///
    /// For more information please refer to `CAMetalLayer.presentsWithTransaction` and ``PresentationTransactionMode``.
    public var presentationTransactionMode: PresentationTransactionMode {
        get { mapPresentation.mode }
        set { mapPresentation.mode = newValue }
    }

    private let mapPresentation = MapPresentation()

    open override var isOpaque: Bool {
        didSet {
            metalView?.isOpaque = isOpaque
            metalView?.layer.isOpaque = isOpaque
        }
    }

    /// The underlying metal view that is used to render the map
    private(set) var metalView: MetalView?

    private let cameraViewContainerView = UIView()

    /// Holds ViewAnnotation views
    private let viewAnnotationContainerView = ViewAnnotationsContainer()

    private var needsDisplayRefresh: Bool = false
    private var displayLink: DisplayLinkProtocol?

    /// Holding onto this value that comes from `MapOptions` since there is a race condition between
    /// getting a `MetalView`, and intializing a `MapView`
    private var pixelRatio: CGFloat = 0.0

    /// Sample count to control multisample anti-aliasing (MSAA) option for rendering.
    ///
    /// - SeeAlso: ``MapInitOptions/antialiasingSampleCount``
    private let antialiasingSampleCount: Int

    @IBInspectable private var styleURI__: String = ""

    /// Outlet that can be used when initializing a MapView with a Storyboard or
    /// a nib.
    @IBOutlet internal private(set) weak var mapInitOptionsProvider: MapInitOptionsProvider?

    private let dependencyProvider: MapViewDependencyProviderProtocol

    private let displayLinkSignalSubject = SignalSubject<Void>()
    private let safeAreaSignalSubject = CurrentValueSignalSubject(UIEdgeInsets())

    private let notificationCenter: NotificationCenterProtocol
    private let bundle: BundleProtocol

    /// The preferred frames per second used for map rendering.
    /// - Note: ``preferredFrameRateRange`` is available for iOS 15.0 and above.
    @available(iOS, deprecated: 15, message: "Use preferredFrameRateRange instead.")
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
    @available(*, deprecated, renamed: "mapboxMap.cameraState")
    public var cameraState: CameraState {
        return mapboxMap.cameraState
    }

    /// The map's current anchor, calculated after applying padding (if it exists)
    @available(*, deprecated, renamed: "mapboxMap.anchor")
    public var anchor: CGPoint {
        return mapboxMap.anchor
    }

    /// Debug options for the current ``MapView`` and it's native ``MapboxMap``.
    public var debugOptions: MapViewDebugOptions = [] {
        didSet {
            mapboxMap._debugOptions = debugOptions.nativeDebugOptions
            ornaments.showCameraDebug = debugOptions.contains(.camera)
            ornaments.showPaddingDebug = debugOptions.contains(.padding)
            viewAnnotationContainerView.subviewDebugFrames = debugOptions.contains(.collision)
        }
    }

    internal let attributionUrlOpener: AttributionURLOpener

    internal let applicationStateProvider: Ref<UIApplication.State>?

    internal let eventsManager: EventsManagerProtocol

    /// Initialize a MapView
    /// - Parameters:
    ///   - frame: frame for the MapView.
    ///   - mapInitOptions: The options to initialize the Maps API with.
    @available(iOSApplicationExtension, unavailable)
    public init(frame: CGRect, mapInitOptions: MapInitOptions = MapInitOptions()) {
        let trace = OSLog.platform.beginInterval("MapView.init")
        defer { trace?.end() }

        dependencyProvider = MapViewDependencyProvider()
        attributionUrlOpener = DefaultAttributionURLOpener()
        applicationStateProvider = .global
        notificationCenter = dependencyProvider.notificationCenter
        bundle = dependencyProvider.bundle
        eventsManager = dependencyProvider.makeEventsManager()
        self.antialiasingSampleCount = mapInitOptions.antialiasingSampleCount
        super.init(frame: frame)
        commonInit(mapInitOptions: mapInitOptions, overridingStyleURI: nil)
    }

    /// Initialize a MapView
    /// - Parameters:
    ///   - frame: frame for the MapView.
    ///   - mapInitOptions: The options to initialize the Maps API with.
    ///   - orientationProvider: User interface orientation provider
    ///   - urlOpener: Attribution URL opener
    @available(iOS, unavailable, message: "Use init(frame:mapInitOptions:urlOpener:) instead")
    public init(frame: CGRect,
                mapInitOptions: MapInitOptions = MapInitOptions(),
                orientationProvider: Void,
                urlOpener: AttributionURLOpener) { fatalError("Shouldn't be called") }

    /// Initialize a MapView
    /// - Parameters:
    ///   - frame: frame for the MapView.
    ///   - mapInitOptions: The options to initialize the Maps API with.
    ///   - urlOpener: Attribution URL opener
    public init(frame: CGRect,
                mapInitOptions: MapInitOptions = MapInitOptions(),
                urlOpener: AttributionURLOpener) {
        let trace = OSLog.platform.beginInterval("MapView.init")
        defer { trace?.end() }
        dependencyProvider = MapViewDependencyProvider()
        attributionUrlOpener = urlOpener
        self.applicationStateProvider = nil
        notificationCenter = dependencyProvider.notificationCenter
        bundle = dependencyProvider.bundle
        eventsManager = dependencyProvider.makeEventsManager()
        antialiasingSampleCount = mapInitOptions.antialiasingSampleCount
        super.init(frame: frame)
        commonInit(mapInitOptions: mapInitOptions, overridingStyleURI: nil)
    }

    @available(iOSApplicationExtension, unavailable)
    required public init?(coder: NSCoder) {
        let trace = OSLog.platform.beginInterval("MapView.init")
        defer { trace?.end() }

        dependencyProvider = MapViewDependencyProvider()
        notificationCenter = dependencyProvider.notificationCenter
        bundle = dependencyProvider.bundle
        attributionUrlOpener = DefaultAttributionURLOpener()
        applicationStateProvider = .global
        eventsManager = dependencyProvider.makeEventsManager()

        let defaultMapInitOptions = MapInitOptions()
        antialiasingSampleCount = defaultMapInitOptions.antialiasingSampleCount

        super.init(coder: coder)
    }

    internal init(frame: CGRect,
                  mapInitOptions: MapInitOptions,
                  dependencyProvider: MapViewDependencyProviderProtocol,
                  urlOpener: AttributionURLOpener,
                  applicationStateProvider: Ref<UIApplication.State>?) {
        let trace = OSLog.platform.beginInterval("MapView.init")
        defer { trace?.end() }
        self.dependencyProvider = dependencyProvider
        attributionUrlOpener = urlOpener
        self.applicationStateProvider = applicationStateProvider
        notificationCenter = dependencyProvider.notificationCenter
        bundle = dependencyProvider.bundle
        eventsManager = dependencyProvider.makeEventsManager()
        antialiasingSampleCount = mapInitOptions.antialiasingSampleCount
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

        let resolvedMapInitOptions = mapInitOptions.resolved(
            in: bounds,
            overridingStyleURI: overridingStyleURI
        )

        self.pixelRatio = CGFloat(resolvedMapInitOptions.mapOptions.pixelRatio)

        mapboxMap = makeMapboxMap(resolvedMapInitOptions: resolvedMapInitOptions)

        subscribeToLifecycleNotifications()
        notificationCenter.addObserver(
            self,
            selector: #selector(didReceiveMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )

        if let initialStyleJSON = resolvedMapInitOptions.styleJSON {
            mapboxMap.mapStyle = MapStyle(json: initialStyleJSON)
        } else if let initialStyleURI = resolvedMapInitOptions.styleURI {
            mapboxMap.mapStyle = MapStyle(uri: initialStyleURI)
        }

        if let cameraOptions = resolvedMapInitOptions.cameraOptions {
            mapboxMap.setCamera(to: cameraOptions)
        }

        if let metalView = metalView {
            insertSubview(viewAnnotationContainerView, aboveSubview: metalView)
        }

        addConstrained(child: viewAnnotationContainerView, add: false)
        cameraViewContainerView.isHidden = true
        addSubview(cameraViewContainerView)

        sendInitialTelemetryEvents()

        // Set up managers
        setupManagers()
    }

    private func makeMapboxMap(resolvedMapInitOptions: MapInitOptions) -> MapboxMap {
        let mapClient = DelegatingMapClient()
        mapClient.delegate = self
        let map = CoreMap(client: mapClient, mapOptions: resolvedMapInitOptions.mapOptions)

        return MapboxMap(map: map, events: MapEvents(observable: map))
    }

    internal func sendInitialTelemetryEvents() {
        eventsManager.sendTurnstile()
        eventsManager.sendMapLoadEvent(with: traitCollection)
    }

    // swiftlint:disable:next function_body_length
    internal func setupManagers() {

        // Initialize/Configure camera manager first since Gestures needs it as dependency
        cameraAnimatorsRunner = dependencyProvider.makeCameraAnimatorsRunner(
            mapboxMap: mapboxMap)
        let internalCamera = dependencyProvider.makeCameraAnimationsManagerImpl(
            cameraViewContainerView: cameraViewContainerView,
            mapboxMap: mapboxMap,
            cameraAnimatorsRunner: cameraAnimatorsRunner)
        camera = CameraAnimationsManager(impl: internalCamera)

        annotations = AnnotationOrchestrator(
            deps: .from(mapboxMap: mapboxMap, displayLink: displayLinkSignalSubject.signal))

        // Initialize/Configure gesture manager
        gestures = dependencyProvider.makeGestureManager(
            view: self,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: internalCamera)

        // Initialize the attribution manager and menu
        attributionMenu = AttributionMenu(
            urlOpener: attributionUrlOpener,
            feedbackURLRef: Ref { [weak mapboxMap] in mapboxMap?.mapboxFeedbackURL() }
        )
        attributionDialogManager = AttributionDialogManager(
            dataSource: mapboxMap,
            delegate: self,
            attributionMenu: attributionMenu)

        // Initialize/Configure ornaments manager
        ornaments = OrnamentsManager(
            options: OrnamentOptions(),
            view: self,
            onCameraChanged: mapboxMap.onCameraChanged,
            cameraAnimationsManager: internalCamera,
            infoButtonOrnamentDelegate: attributionDialogManager,
            logoView: LogoView(logoSize: .regular()),
            scaleBarView: MapboxScaleBarOrnamentView(),
            compassView: MapboxCompassOrnamentView(),
            attributionButton: InfoButtonOrnament())

        // Initialize/Configure location source and location manager
        location = LocationManager(
            interfaceOrientationView: .weakRef(self),
            displayLink: displayLinkSignalSubject.signal,
            styleManager: mapboxMap,
            mapboxMap: mapboxMap
        )

        // Initialize/Configure view annotations manager
        viewAnnotations = ViewAnnotationManager(
            containerView: viewAnnotationContainerView,
            mapboxMap: mapboxMap,
            displayLink: displayLinkSignalSubject.signal)
        mapPresentation.displaysAnnotations = viewAnnotations.displaysAnnotations.signal

        let safeAreaSignal = safeAreaSignalSubject.signal.skipRepeats()

        viewport = ViewportManager(
            impl: dependencyProvider.makeViewportManagerImpl(
                mapboxMap: mapboxMap,
                cameraAnimationsManager: internalCamera,
                safeAreaInsets: safeAreaSignal,
                isDefaultCameraInitialized: mapboxMap.isDefaultCameraInitialized,
                anyTouchGestureRecognizer: gestures.anyTouchGestureRecognizer,
                doubleTapGestureRecognizer: gestures.doubleTapToZoomInGestureRecognizer,
                doubleTouchGestureRecognizer: gestures.doubleTouchToZoomOutGestureRecognizer),
            onPuckRender: location.onPuckRender,
            cameraAnimationsManager: internalCamera,
            mapboxMap: mapboxMap,
            styleManager: mapboxMap)
    }

    deinit {
        displayLink?.invalidate()
        cameraAnimatorsRunner.isEnabled = false
    }

    private func subscribeToLifecycleNotifications() {
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
        notificationCenter.addObserver(self,
                                       selector: #selector(appDidEnterBackground),
                                       name: UIApplication.didEnterBackgroundNotification,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(appWillResignActive),
                                       name: UIApplication.willResignActiveNotification,
                                       object: nil)
    }

    @objc private func appDidEnterBackground() {
        displayLink?.isPaused = true
        reduceMemoryUse()
    }

    @objc private func appWillResignActive() {
        displayLink?.isPaused = true
    }

    @objc private func sceneDidActivate(_ notification: Notification) {
        guard let scene = notification.object as? UIScene, let window = window, scene.allWindows.contains(window) else { return }

        displayLink?.isPaused = false
    }

    @objc private func sceneWillDeactivate(_ notification: Notification) {
        guard let scene = notification.object as? UIScene, let window = window, scene.allWindows.contains(window) else { return }

        displayLink?.isPaused = true
    }

    @objc private func sceneDidEnterBackground(_ notification: Notification) {
        guard let scene = notification.object as? UIScene, let window = window, scene.allWindows.contains(window) else { return }

        displayLink?.isPaused = true
        reduceMemoryUse()
    }

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
            Log.warning("Metal rendering is not supported on iOS versions < iOS 13. Please test on device or on iOS simulators version >= 13.", category: "MapView")
            return
        }

        // Metal is unavailable for a different reason
        Log.error("No suitable Metal simulator can be found.", category: "MapView")
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

    open override func layoutSubviews() {
        super.layoutSubviews()

        metalView?.center = CGPoint(x: bounds.midX, y: bounds.midY)
        safeAreaSignalSubject.value = self.safeAreaInsets

        if let metalView, metalView.autoResizeDrawable {
            metalView.frame = bounds
            mapboxMap.size = metalView.bounds.size
        }
    }

#if !os(visionOS)
    /// Control the resizing animation behavior of the map view.
    /// The default value is ``ResizingAnimation-swift.enum/automatic``.
    public enum ResizingAnimation {
        /// Change the default behaviour to have a nice looking resizing animation.
        ///
        /// The map plane would fulfil the MapView sized all the time.
        /// Custom implementation.
        case automatic

        /// Default UIView behaviour. The map plane would be resized immediately leading to gaps renderer when assign higher size values.
        case none

        init?(autoResizeDrawable: Bool?) {
            guard let autoResizeDrawable else { return nil }
            self = autoResizeDrawable ? .none : .automatic
        }

        var autoResizeDrawable: Bool {
            switch self {
            case .automatic: return false
            case .none: return true
            }
        }
    }

    /// Control resizing animation behavior of the map view.
    public var resizingAnimation: ResizingAnimation = .automatic {
        didSet {
            syncResizingAnimation()
        }
    }

    private func syncResizingAnimation() {
        // VisionOS doesn't support autoResizeDrawable
        metalView?.autoResizeDrawable = resizingAnimation.autoResizeDrawable
    }
#endif

    /// Synchronize size updates with GL-Native and UIKit
    ///
    /// To provide nice custom resizing behavior SDK rely on custom `drawableSize` updates
    /// That values is measured in pixels (not points) and has impact on the framebufferSize in GL-Native context.
    /// The method would make a convertion to pixels based on the `pixelRatio` parameter
    ///
    /// - Important: Size argument can be bigger than MapView bounds. That might happen when we are increase map size and
    /// to have a smooth transition we need to draw map in final sizes before animation begins.
    /// - Parameter size: new size in points (as reported by `bounds.size`)
    func updateDrawableSize(to size: CGSize) {
        guard let metalView, !metalView.autoResizeDrawable else { return }

        metalView.bounds.size = size
        mapboxMap.size = size

        metalView.drawableSize = CGSize(width: size.width * pixelRatio, height: size.height * pixelRatio)
        if metalView.contentScaleFactor != pixelRatio {
            // DrawableSize setter will recalculate `contentScaleFactor` if the new drawableSize doesn't fit into
            // the current bounds.size and scale.
            Log.error("MetalView content scale factor \(metalView.contentScaleFactor) is not equal to pixel ratio \(pixelRatio)")
        }

        // GL-Native will trigger update on `mapboxMap.size` update but it will come in the next frame.
        // To reduce glitches we can schedule repaint in the next frame to resize map texture.
        scheduleRepaint()
    }

    @_spi(Metrics) public var metricsReporter: MapViewMetricsReporter?
    private func updateFromDisplayLink(displayLink: CADisplayLink) {
        let displayLinkTrace = OSLog.platform.beginInterval(SignpostName.mapViewDisplayLink,
                                                            beginMessage: "CADisplayLink update")
        defer {
            displayLinkTrace?.end()
        }

        metricsReporter?.beforeDisplayLinkCallback(displayLink: displayLink)
        defer { metricsReporter?.afterDisplayLinkCallback(displayLink: displayLink) }

        if window == nil {
            return
        }

        OSLog.platform.withIntervalSignpost(SignpostName.mapViewDisplayLink, "DisplayLink participants") {
            displayLinkSignalSubject.send()
        }

        OSLog.platform.withIntervalSignpost(SignpostName.mapViewDisplayLink, "Camera animator runner") {
            cameraAnimatorsRunner.update()
        }

        if needsDisplayRefresh {
            needsDisplayRefresh = false
            let drawTrace = OSLog.platform.beginInterval(SignpostName.mapViewDisplayLink,
                                                         beginMessage: "Draw")
            defer {
                drawTrace?.end()
            }
            metricsReporter?.beforeMetalViewDrawCallback()
            metalView?.draw()
            metricsReporter?.afterMetalViewDrawCallback()
        }
    }

    private func updateDisplayLinkPreferredFramesPerSecond() {
        guard let displayLink = displayLink else {
            return
        }

        if let _preferredFramesPerSecond = _preferredFramesPerSecond {
            displayLink.preferredFramesPerSecond = _preferredFramesPerSecond
        }

        if #available(iOS 15.0, *) {
            if let _preferredFrameRateRange = _preferredFrameRateRange {
                displayLink.preferredFrameRateRange = _preferredFrameRateRange
            }
        }
    }

    private(set) var didMoveToCarPlayWindow = false

    open override func didMoveToWindow() {
        super.didMoveToWindow()

        displayLink?.invalidate()
        displayLink = nil

        guard let window = window else {
            cameraAnimatorsRunner.isEnabled = false
            return
        }

        if window.isCarPlay, !didMoveToCarPlayWindow {
            didMoveToCarPlayWindow = true
            sendTelemetry(\.carPlay)
        }

        displayLink = dependencyProvider.makeDisplayLink(
            window: window,
            target: ForwardingDisplayLinkTarget { [weak self] in
                self?.updateFromDisplayLink(displayLink: $0)
            },
            selector: #selector(ForwardingDisplayLinkTarget.update(with:)))

        guard let displayLink = displayLink else {
            cameraAnimatorsRunner.isEnabled = false
            return
        }

        cameraAnimatorsRunner.isEnabled = true

        updateDisplayLinkPreferredFramesPerSecond()

        // this will make sure that display link is only running on an active scene in foreground,
        // preventing metal view drawing on background if the view is added to window not on foreground
        if shouldDisplayLinkBePaused(window: window) {
            displayLink.isPaused = true
        }

        displayLink.add(to: .current, forMode: .common)
    }

    private func shouldDisplayLinkBePaused(window: UIWindow) -> Bool {
        if let state = applicationStateProvider?.value, state != .active {
            return true
        }

        if let scene = window.parentScene, scene.activationState != .foregroundActive {
            return true
        }

        return false
    }

    // MARK: SizeTrackingLayerDelegate

    func sizeTrackingLayer(layer: SizeTrackingLayer, willAnimateResizingFrom from: CGSize, to: CGSize) {
        updateDrawableSize(to: CGSize(width: max(from.width, to.width),
                                  height: max(from.height, to.height)))
    }
    func sizeTrackingLayer(layer: SizeTrackingLayer, completeResizingFrom: CGSize, to: CGSize) {
        updateDrawableSize(to: to)
    }
}

extension MapView: DelegatingMapClientDelegate {
    internal func scheduleRepaint() {
        guard let metalView = metalView, !metalView.bounds.isEmpty else {
            return
        }

        needsDisplayRefresh = true
        OSLog.platform.signpostEvent("Set needs redraw")
    }

    func getMetalView(for metalDevice: MTLDevice?) -> MetalView? {
        let minSize = CGRect(x: 0, y: 0, width: 1, height: 1)
        let metalView = dependencyProvider.makeMetalView(frame: minSize.union(bounds), device: metalDevice)

        metalView.translatesAutoresizingMaskIntoConstraints = false
        metalView.contentScaleFactor = pixelRatio
        metalView.contentMode = .center
        metalView.isOpaque = isOpaque
        metalView.layer.isOpaque = isOpaque
        metalView.sampleCount = antialiasingSampleCount
        mapPresentation.metalView = metalView

        // MapView should clip bounds to hide MTKView oversizing during the expand resizing animations
        clipsToBounds = true
        insertSubview(metalView, at: 0)

        self.metalView = metalView

#if !os(visionOS)
        syncResizingAnimation()
#endif

        return metalView
    }
}

extension MapView {
    var __displayLinkSignalForTests: Signal<Void> { displayLinkSignalSubject.signal }
}
