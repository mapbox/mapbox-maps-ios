@_exported import MapboxCoreMaps
@_exported import MapboxCommon
@_implementationOnly import MapboxCoreMaps_Private
@_implementationOnly import MapboxCommon_Private
import UIKit
import Turf

internal typealias PendingAnimationCompletion = (completion: AnimationCompletion, animatingPosition: UIViewAnimatingPosition)

open class MapView: UIView {

    // mapbox map depends on MapInitOptions, which is not available until
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

    /// The `camera` object manages a camera's view lifecycle..
    public internal(set) var camera: CameraAnimationsManager!

    /// The `location`object handles location events of the map.
    public internal(set) var location: LocationManager!

    /// Controls the addition/removal of annotations to the map.
    public internal(set) var annotations: AnnotationManager!

    /// A reference to the `EventsManager` used for dispatching telemetry.
    internal var eventsListener: EventsListener!

    /// Offline Manager initialized with the same ResourceOptions as the map view
    ///
    /// - Important: If you use an `OfflineManager` in conjunction with a `MapView`
    /// they must use the same resource options. You can use this convenience
    /// function to ensure this.
    public func makeOfflineManager() -> OfflineManager {
        guard let resourceOptions = resourceOptions else {
            fatalError("resourceOptions not yet initialized")
        }

        return OfflineManager(resourceOptions: resourceOptions)
    }

    private let mapClient = DelegatingMapClient()

    public var options = RenderOptions() {
        didSet {
            let defaultPrefetchZoomDelta: UInt8 = 4
            mapboxMap.__map.setPrefetchZoomDeltaForDelta(options.prefetchesTiles ? defaultPrefetchZoomDelta : 0)
            preferredFPS = options.preferredFramesPerSecond
            metalView?.presentsWithTransaction = options.presentsWithTransaction
        }
    }

    /// The underlying metal view that is used to render the map
    internal private(set) var metalView: MTKView?

    /// Resource options for this map view
    internal private(set) var resourceOptions: ResourceOptions!

    /// List of completion blocks that need to be completed by the displayLink
    internal var pendingAnimatorCompletionBlocks: [PendingAnimationCompletion] = []

    /// Pointer HashTable for holding camera animators
    private var cameraAnimatorsSet = WeakSet<CameraAnimatorInterface>()

    /// List of animators currently alive
    internal var cameraAnimators: [CameraAnimator] {
        return cameraAnimatorsSet.allObjects
    }

    private var needsDisplayRefresh: Bool = false
    private var dormant: Bool = false
    private var displayCallback: (() -> Void)?
    @objc dynamic internal var displayLink: CADisplayLink?

    @IBInspectable private var styleURI__: String = ""

    /// Outlet that can be used when initializing a MapView with a Storyboard or
    /// a nib.
    @IBOutlet internal private(set) weak var mapInitOptionsProvider: MapInitOptionsProvider?

    internal var preferredFPS: PreferredFPS = .maximum {
        didSet {
            updateDisplayLinkPreferredFramesPerSecond()
        }
    }

    /// The map's current camera
    public var cameraState: CameraState {
        return mapboxMap.cameraState
    }

    /// The map's current anchor, calculated after applying padding (if it exists)
    public var anchor: CGPoint {
        let padding = cameraState.padding
        let xAfterPadding = center.x + padding.left - padding.right
        let yAfterPadding = center.y + padding.top - padding.bottom
        return CGPoint(x: xAfterPadding, y: yAfterPadding)
    }

    /// Initialize a MapView
    /// - Parameters:
    ///   - frame: frame for the MapView.
    ///   - mapInitOptions: `MapInitOptions`; default uses
    ///    `CredentialsManager.default` to retrieve a shared default access token.
    public init(frame: CGRect, mapInitOptions: MapInitOptions = MapInitOptions()) {
        super.init(frame: frame)
        commonInit(mapInitOptions: mapInitOptions, overridingStyleURI: nil)
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
        mapClient.delegate = self
        mapboxMap = MapboxMap(mapClient: mapClient, mapInitOptions: resolvedMapInitOptions)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willTerminate),
                                               name: UIApplication.willTerminateNotification,
                                               object: nil)

        // Use the overriding style URI if provided (currently from IB)
        if let initialStyleURI = overridingStyleURI,
           let styleURI = StyleURI(url: initialStyleURI) {
            mapboxMap.loadStyleURI(styleURI)
        } else if let initialStyleURI = resolvedMapInitOptions.styleURI {
            mapboxMap.loadStyleURI(initialStyleURI)
        }

        if let cameraOptions = resolvedMapInitOptions.cameraOptions {
            mapboxMap.__map.setCameraFor(MapboxCoreMaps.CameraOptions(cameraOptions))
        }

        // Set prefetchZoomDelta
        let defaultPrefetchZoomDelta: UInt8 = 4
        mapboxMap.__map.setPrefetchZoomDeltaForDelta(
            options.prefetchesTiles ? defaultPrefetchZoomDelta : 0)

        // Set preferrredFPS
        preferredFPS = options.preferredFramesPerSecond

        // Setup Telemetry logging
        setUpTelemetryLogging()

        // Set up managers
        setupManagers()
    }

    internal func setupManagers() {

        // Initialize/Configure camera manager first since Gestures needs it as dependency
        camera = CameraAnimationsManager(mapView: self)

        // Initialize/Configure gesture manager
        gestures = GestureManager(for: self, cameraManager: camera)

        // Initialize/Configure ornaments manager
        ornaments = OrnamentsManager(view: self, options: OrnamentOptions())

        // Initialize/Configure location manager
        location = LocationManager(locationSupportableMapView: self, style: mapboxMap.style)

        // Initialize/Configure annotations manager
        annotations = AnnotationManager(for: self,
                                        mapEventsObservable: mapboxMap,
                                        mapFeatureQueryable: mapboxMap,
                                        style: mapboxMap.style)
    }

    private func checkForMetalSupport() {
        guard MTLCreateSystemDefaultDevice() == nil else {
            return
        }

        // Metal is unavailable on older simulators
        #if targetEnvironment(simulator)
        guard ProcessInfo().isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 13, minorVersion: 0, patchVersion: 0)) else {
            Log.warning(forMessage: "Metal rendering is not supported on iOS versions < iOS 13. Please test on device or on iOS version >= 13.", category: "MapView")
            return
        }
        #endif

        // Metal is unavailable for a different reason
        Log.error(forMessage: "No suitable Metal device or simulator can be found.", category: "MapView")
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

    func validateDisplayLink() {
        if superview != nil
            && window != nil
            && displayLink == nil {
            let target = BaseMapViewProxy(mapView: self)
            displayLink = window?.screen.displayLink(withTarget: target, selector: #selector(target.updateFromDisplayLink))

            preferredFPS = options.preferredFramesPerSecond
            updateDisplayLinkPreferredFramesPerSecond()
            displayLink?.add(to: .current, forMode: .common)

        }
    }

    @objc func updateFromDisplayLink(displayLink: CADisplayLink) {
        if window == nil {
            return
        }

        if needsDisplayRefresh {
            needsDisplayRefresh = false

            for animator in cameraAnimatorsSet.allObjects {
                if let cameraOptions = animator.currentCameraOptions {
                    mapboxMap._setCamera(to: cameraOptions)
                }
            }

            /// This executes the series of scheduled animation completion blocks and also removes them from the list
            while !pendingAnimatorCompletionBlocks.isEmpty {
                let pendingCompletion = pendingAnimatorCompletionBlocks.removeFirst()
                let completion = pendingCompletion.completion
                let animatingPosition = pendingCompletion.animatingPosition
                completion(animatingPosition)
            }

            self.displayCallback?()
        }
    }

    // Add an animator to the `cameraAnimatorsSet`
    internal func addCameraAnimator(_ cameraAnimator: CameraAnimatorInterface) {
        cameraAnimatorsSet.add(cameraAnimator)
    }

    func updateDisplayLinkPreferredFramesPerSecond() {
        if let displayLink = displayLink {
            displayLink.preferredFramesPerSecond = preferredFPS.rawValue
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

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension MapView: DelegatingMapClientDelegate {
    internal func scheduleRepaint() {
        needsDisplayRefresh = true
    }

    internal func scheduleTask(forTask task: @escaping Task) {
        fatalError("scheduleTask is not supported")
    }

    internal func getMetalView(for metalDevice: MTLDevice?) -> MTKView? {
        let metalView = MTKView(frame: frame, device: metalDevice)
        displayCallback = {
            metalView.setNeedsDisplay()
        }

        metalView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        metalView.autoResizeDrawable = true
        metalView.contentScaleFactor = UIScreen.main.scale
        metalView.contentMode = .center
        metalView.isOpaque = isOpaque
        metalView.layer.isOpaque = isOpaque
        metalView.isPaused = true
        metalView.enableSetNeedsDisplay = true
        metalView.presentsWithTransaction = options.presentsWithTransaction

        insertSubview(metalView, at: 0)
        self.metalView = metalView

        return metalView
    }
}

private class BaseMapViewProxy: NSObject {
    weak var mapView: MapView?

    init(mapView: MapView) {
        self.mapView = mapView
        super.init()
    }

    @objc func updateFromDisplayLink(displayLink: CADisplayLink) {
        mapView?.updateFromDisplayLink(displayLink: displayLink)
    }
}

// MARK: Telemetry
extension MapView {
    internal func setUpTelemetryLogging() {
        guard let validResourceOptions = resourceOptions else { return }
        eventsListener = EventsManager(accessToken: validResourceOptions.accessToken)

        mapboxMap.onNext(.mapLoaded) { [weak self] _ in
            self?.eventsListener?.push(event: .map(event: .loaded))
        }
    }
}
