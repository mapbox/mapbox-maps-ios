// swiftlint:disable file_length
@_exported import MapboxCoreMaps
@_exported import MapboxCommon
@_exported import MetalKit
@_exported import Turf
@_implementationOnly import MapboxCoreMaps_Private
@_implementationOnly import MapboxCommon_Private
import UIKit

// swiftlint:disable type_body_length
@available(iOSApplicationExtension, unavailable)
open class MapView: UIView {

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
    public internal(set) var gestures: GestureManager!

    /// The `ornaments`object will be responsible for all ornaments on the map.
    public internal(set) var ornaments: OrnamentsManager!

    /// The `camera` object manages a camera's view lifecycle.
    public internal(set) var camera: CameraAnimationsManager!

    /// The `location`object handles location events of the map.
    public internal(set) var location: LocationManager!
    private var locationProducer: LocationProducerProtocol!

    /// Controls the addition/removal of annotations to the map.
    public internal(set) var annotations: AnnotationOrchestrator!

    /// Manages the configuration of custom view annotations on the map.
    public internal(set) var viewAnnotations: ViewAnnotationManager!

    /// Controls the display of attribution dialogs
    private var attributionDialogManager: AttributionDialogManager!

    /// A reference to the `EventsManager` used for dispatching telemetry.
    private var eventsListener: EventsListener?

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

    private let cameraViewContainerView = UIView()

    /// Holds ViewAnnotation views
    private let viewAnnotationContainerView = SubviewInteractionOnlyView()

    /// Resource options for this map view
    internal private(set) var resourceOptions: ResourceOptions!

    private var needsDisplayRefresh: Bool = false
    private var dormant: Bool = false
    private var displayCallback: (() -> Void)?
    private var displayLink: DisplayLinkProtocol?

    /// Holding onto this value that comes from `MapOptions` since there is a race condition between
    /// getting a `MetalView`, and intializing a `MapView`
    private var pixelRatio: CGFloat = 0.0

    @IBInspectable private var styleURI__: String = ""

    /// Outlet that can be used when initializing a MapView with a Storyboard or
    /// a nib.
    @IBOutlet internal private(set) weak var mapInitOptionsProvider: MapInitOptionsProvider?

    private let dependencyProvider: MapViewDependencyProviderProtocol

    private var displayLinkParticipants = WeakSet<DisplayLinkParticipant>()

    /*** The preferred frames per second used for map rendering.
        NOTE: `MapView.preferredFrameRateRange` is available for iOS 15.0 and above.
     */
    @available(iOS, deprecated: 1000000)
    public var preferredFramesPerSecond: Int {
        get {
            return _preferredFramesPerSecond ?? 0
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
            return _preferredFrameRateRange ?? .default
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

    /// The `timestamp` from the underlying `CADisplayLink` if it exists, otherwise `nil`
    @_spi(Metrics) public var displayLinkTimestamp: CFTimeInterval? {
        return displayLink?.timestamp
    }

    /// The `duration` from the underlying `CADisplayLink` if it exists, otherwise `nil`
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

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// Initialize a MapView
    /// - Parameters:
    ///   - frame: frame for the MapView.
    ///   - mapInitOptions: `MapInitOptions`; default uses
    ///    `ResourceOptionsManager.default` to retrieve a shared default resource option, including the access token.
    public init(frame: CGRect, mapInitOptions: MapInitOptions = MapInitOptions()) {
        dependencyProvider = MapViewDependencyProvider()
        super.init(frame: frame)
        commonInit(mapInitOptions: mapInitOptions, overridingStyleURI: nil)
    }

    required public init?(coder: NSCoder) {
        dependencyProvider = MapViewDependencyProvider()
        super.init(coder: coder)
    }

    internal init(frame: CGRect,
                  mapInitOptions: MapInitOptions,
                  dependencyProvider: MapViewDependencyProviderProtocol) {
        self.dependencyProvider = dependencyProvider
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
        mapboxMap = MapboxMap(mapClient: mapClient, mapInitOptions: resolvedMapInitOptions)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willTerminate),
                                               name: UIApplication.willTerminateNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didReceiveMemoryWarning),
                                               name: UIApplication.didReceiveMemoryWarningNotification,
                                               object: nil)

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

        insertSubview(viewAnnotationContainerView, at: 1)
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
            guard let self = self else { return }
            self.setUpTelemetryLogging()
        }

        // Set up managers
        setupManagers()
    }

    internal func setupManagers() {

        // Initialize/Configure camera manager first since Gestures needs it as dependency
        camera = CameraAnimationsManager(
            cameraViewContainerView: cameraViewContainerView,
            mapboxMap: mapboxMap)

        // Initialize/Configure gesture manager
        gestures = dependencyProvider.makeGestureManager(view: self, mapboxMap: mapboxMap, cameraAnimationsManager: camera)

        // Initialize the attribution manager
        attributionDialogManager = AttributionDialogManager(dataSource: mapboxMap, delegate: self)

        // Initialize/Configure ornaments manager
        ornaments = OrnamentsManager(
            options: OrnamentOptions(),
            view: self,
            mapboxMap: mapboxMap,
            cameraAnimationsManager: camera,
            infoButtonOrnamentDelegate: attributionDialogManager)

        // Initialize/Configure location source and location manager
        locationProducer = dependencyProvider.makeLocationProducer(
            mayRequestWhenInUseAuthorization: Bundle.main.infoDictionary?["NSLocationWhenInUseUsageDescription"] != nil)
        location = dependencyProvider.makeLocationManager(
            locationProducer: locationProducer,
            style: mapboxMap.style)

        // Initialize/Configure annotations orchestrator
        annotations = AnnotationOrchestrator(
            gestureRecognizer: gestures.singleTapGestureRecognizer,
            mapFeatureQueryable: mapboxMap,
            style: mapboxMap.style,
            displayLinkCoordinator: self)

        // Initialize/Configure view annotations manager
        viewAnnotations = ViewAnnotationManager(containerView: viewAnnotationContainerView, mapboxMap: mapboxMap)
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

    public override func layoutSubviews() {
        super.layoutSubviews()
        mapboxMap.size = bounds.size
    }

    private func validateDisplayLink() {
        if let window = window, displayLink == nil {
            displayLink = dependencyProvider.makeDisplayLink(
                window: window,
                target: ForwardingDisplayLinkTarget { [weak self] in
                    self?.updateFromDisplayLink(displayLink: $0)
                },
                selector: #selector(ForwardingDisplayLinkTarget.update(with:)))
            updateDisplayLinkPreferredFramesPerSecond()
            displayLink?.add(to: .current, forMode: .common)
        }
    }

    private func updateFromDisplayLink(displayLink: CADisplayLink) {
        if window == nil {
            return
        }

        updateHeadingOrientationIfNeeded()

        for participant in displayLinkParticipants.allObjects {
            participant.participate()
        }

        camera.update()

        if needsDisplayRefresh {
            needsDisplayRefresh = false
            displayCallback?()
        }
    }

    func updateDisplayLinkPreferredFramesPerSecond() {
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

    open override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow != nil {
            validateDisplayLink()
        }
    }

    open override func didMoveToWindow() {
        super.didMoveToWindow()

        if window != nil {
            validateDisplayLink()
        } else {
            // TODO: Fix this up correctly.
            displayLink?.invalidate()
            displayLink = nil
        }
    }

    open override func didMoveToSuperview() {
        validateDisplayLink()
        super.didMoveToSuperview()
    }

    @objc func willTerminate() {
        if !dormant {
            validateDisplayLink()
            dormant = true
        }
    }

    @objc func didReceiveMemoryWarning() {
        mapboxMap.reduceMemoryUse()
    }

    // MARK: Telemetry

    private func setUpTelemetryLogging() {
        guard let validResourceOptions = resourceOptions else { return }
        eventsListener = EventsManager(accessToken: validResourceOptions.accessToken)
        eventsListener?.push(event: .map(event: .loaded))
    }

    // MARK: Location

    private func updateHeadingOrientationIfNeeded() {
        // locationProvider.headingOrientation should be adjusted based on the
        // current UIInterfaceOrientation of the containing window, not the
        // device orientation
        let optionalInterfaceOrientation: UIInterfaceOrientation?
        if #available(iOS 13.0, *) {
            optionalInterfaceOrientation = window?.windowScene?.interfaceOrientation
        } else {
            optionalInterfaceOrientation =  UIApplication.shared.statusBarOrientation
        }

        guard let interfaceOrientation = optionalInterfaceOrientation else {
            return
        }

        // UIInterfaceOrientation.landscape{Right,Left} correspond to
        // CLDeviceOrientation.landscape{Left,Right}, respectively. The reason
        // for this, according to the UIInterfaceOrientation docs is that
        //
        //    > …rotating the device requires rotating the content in the
        //    > opposite direction.
        var headingOrientation: CLDeviceOrientation
        switch interfaceOrientation {
        case .landscapeLeft:
            headingOrientation = .landscapeRight
        case .landscapeRight:
            headingOrientation = .landscapeLeft
        case .portraitUpsideDown:
            headingOrientation = .portraitUpsideDown
        default:
            headingOrientation = .portrait
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
    }
}

@available(iOSApplicationExtension, unavailable)
extension MapView: DelegatingMapClientDelegate {
    internal func scheduleRepaint() {
        needsDisplayRefresh = true
    }

    internal func scheduleTask(forTask task: @escaping Task) {
        fatalError("scheduleTask is not supported")
    }

    internal func getMetalView(for metalDevice: MTLDevice?) -> MTKView? {
        let metalView = dependencyProvider.makeMetalView(frame: bounds, device: metalDevice)
        displayCallback = {
            metalView.setNeedsDisplay()
        }

        metalView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        metalView.autoResizeDrawable = true
        metalView.contentScaleFactor = pixelRatio
        metalView.contentMode = .center
        metalView.isOpaque = isOpaque
        metalView.layer.isOpaque = isOpaque
        metalView.isPaused = true
        metalView.enableSetNeedsDisplay = true
        metalView.presentsWithTransaction = false

        insertSubview(metalView, at: 0)
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
