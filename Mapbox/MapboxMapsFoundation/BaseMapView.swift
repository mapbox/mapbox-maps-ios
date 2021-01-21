@_exported import MapboxCoreMaps
@_exported import MapboxCommon
import UIKit
import Turf

public enum PreferredFPS: Int, Equatable {
    /// The default frame rate. This can be either 30 FPS or 60 FPS, depending on
    /// device capabilities.
    case normal = -1

    /// A conservative frame rate; typically 30 FPS.
    case lowPower = 30

    /// The maximum supported frame rate; typically 60 FPS.
    case maximum = 0
}

open class ObserverConcrete: Observer {

    public var peer: MBXPeerWrapper?

    /// Map of event types to subscribed event handlers
    internal var eventHandlers: [String: [(MapboxCoreMaps.Event) -> Void]] = [:]

    /// Notify correct handler
    public func notify(for event: MapboxCoreMaps.Event) {
        let handlers = eventHandlers[event.type]
        handlers?.forEach({ (handler) in
            handler(event)
        })
    }
}

open class BaseMapView: UIView, MapClient, MBMMetalViewProvider {

    public var __map: Map!

    /// Resource options for this map view
    internal var resourceOptions: ResourceOptions?

    public var needsDisplayRefresh: Bool = false
    public var dormant: Bool = false
    public var displayCallback: (() -> Void)?
    private var observerConcrete: ObserverConcrete!
//    internal var lastSnapshotImage: UIImage? // JK : Do we need?
    internal var metalSnapshotView: UIImageView?

    /* Whether map rendering should occur during the `UIApplicationStateInactive` state.

     This property is ignored for map views where background rendering is permitted.

     This property should be considered undocumented, and prone to change.
     */
    public var renderingInInactiveStateEnabled: Bool = true

    @objc dynamic internal var displayLink: CADisplayLink?

    @IBInspectable var styleURL__: String = ""
    @IBInspectable var baseURL__: String = ""
    @IBInspectable var accessToken__: String = ""

    /// Returns the camera view managed by this object.
    public var cameraView: CameraView!

    public var preferredFPS: PreferredFPS = .normal {
        didSet {
            self.updateDisplayLinkPreferredFramesPerSecond()
        }
    }

    /// The map's current center coordinate.
    public var centerCoordinate: CLLocationCoordinate2D {
        return cameraView.centerCoordinate
    }

    /// The map's current zoom level.
    public var zoom: CGFloat {
        return cameraView.zoom
    }

    /// The map's current bearing, measured clockwise from 0° north.
    public var bearing: CLLocationDirection {
        return CLLocationDirection(cameraView.bearing)
    }

    /// The map's current pitch, falling within a range of 0 to 60.
    public var pitch: CGFloat {
        return cameraView.pitch
    }

    // MARK: Init
    public init(with frame: CGRect, resourceOptions: ResourceOptions, glyphsRasterizationOptions: GlyphsRasterizationOptions, styleURL: URL?) {
        super.init(frame: frame)
        self.commonInit(resourceOptions: resourceOptions, glyphsRasterizationOptions: glyphsRasterizationOptions, styleURL: styleURL)
    }

    private func commonInit(resourceOptions: ResourceOptions, glyphsRasterizationOptions: GlyphsRasterizationOptions, styleURL: URL?) {

        if MTLCreateSystemDefaultDevice() == nil {
            // Check if we're running on a simulator on iOS 11 or 12
            var loggedWarning = false

            #if targetEnvironment(simulator)
            if !ProcessInfo().isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 13, minorVersion: 0, patchVersion: 0)) {
                try! Log.warning(forMessage: "Metal rendering is not supported on iOS versions < iOS 13. Please test on device or on iOS version >= 13.", category: "MapView")
                loggedWarning = true
            }
            #endif

            if !loggedWarning {
                try! Log.error(forMessage: "No suitable Metal device or simulator can be found.", category: "MapView")
            }
        }

        self.resourceOptions = resourceOptions
        observerConcrete = ObserverConcrete()

        let size = MapboxCoreMaps.Size(width: Float(frame.width), height: Float(frame.height))

        let mapOptions = MapboxCoreMaps.MapOptions(__mapMode: nil,
                                                   contextMode: nil,
                                                   constrainMode: nil,
                                                   viewportMode: nil,
                                                   orientation: nil,
                                                   crossSourceCollisions: nil,
                                                   size: size,
                                                   pixelRatio: Float(UIScreen.main.scale),
                                                   glyphsRasterizationOptions: glyphsRasterizationOptions)

        __map = try! Map(client: self, mapOptions: mapOptions, resourceOptions: resourceOptions)

        try! __map?.createRenderer()

        let events = MapEvents.EventKind.allCases.map({ $0.rawValue })
        try! __map.subscribe(for: observerConcrete, events: events)

        self.cameraView = CameraView(frame: frame, map: __map)
        self.addSubview(cameraView)

        NSLayoutConstraint.activate([ self.cameraView.leftAnchor.constraint(equalTo: self.leftAnchor),
                                      self.cameraView.topAnchor.constraint(equalTo: self.topAnchor),
                                      self.cameraView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                                      self.cameraView.rightAnchor.constraint(equalTo: self.rightAnchor)
                                    ])

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willTerminate),
                                               name: UIApplication.willTerminateNotification,
                                               object: nil)

        if let validStyleURL = styleURL {
            try! __map?.setStyleURIForUri(validStyleURL.absoluteString)
        }

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

        guard let accessToken = BaseMapView.parseIBString(ibString: accessToken__) else {
            fatalError("Must provide access token to the MapView in Interface Builder")
        }

        guard let styleURL = BaseMapView.parseIBStringAsURL(ibString: self.styleURL__) else {
            return
        }

        let baseURL = BaseMapView.parseIBString(ibString: self.baseURL__)
        let resourceOptions = ResourceOptions(accessToken: accessToken, baseUrl: baseURL)

        // TODO: Provide suitable default and configuration when setup from IB.
        let localFontFamily = Self.localFontFamilyNameFromMainBundle()
        let rasterizationMode: GlyphsRasterizationMode = localFontFamily != nil ? .ideographsRasterizedLocally
                                                                                : .noGlyphsRasterizedLocally

        let glyphsRasterizationOptions = GlyphsRasterizationOptions(rasterizationMode: rasterizationMode,
                                                                    fontFamily: localFontFamily)

        self.commonInit(resourceOptions: resourceOptions, glyphsRasterizationOptions: glyphsRasterizationOptions, styleURL: styleURL)
    }

    public func on(_ eventType: MapEvents.EventKind, handler: @escaping (MapboxCoreMaps.Event) -> Void) {
        var handlers: [(MapboxCoreMaps.Event) -> Void] = observerConcrete.eventHandlers[eventType.rawValue] ?? []
        handlers.append(handler)
        observerConcrete.eventHandlers[eventType.rawValue] = handlers
    }

    static func localFontFamilyNameFromMainBundle() -> String? {
        let infoDictionaryObject = Bundle.main.object(forInfoDictionaryKey: "MBXIdeographicFontFamilyName")

        if infoDictionaryObject is String {
            return infoDictionaryObject as? String
        } else if infoDictionaryObject is [String],
            let infoDictionaryObjectArray = infoDictionaryObject as? [String] {
            return infoDictionaryObjectArray.joined(separator: "\n")
        }

        return nil
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        let size = MapboxCoreMaps.Size(width: Float(self.bounds.size.width),
                                       height: Float(self.bounds.size.height))
        try! self.__map?.setSizeFor(size)
    }

    // MARK: Display Link
    func createDisplayLink() {
        precondition(self.displayLink == nil)
        precondition(self.windowScreen() != nil)
        let screen = self.windowScreen()
        self.displayLink = screen?.displayLink(withTarget: self, selector: #selector(updateFromDisplayLink(displayLink:)))
        self.displayLink?.isPaused = true
        self.updateDisplayLinkPreferredFramesPerSecond()

        self.displayLink?.add(to: .current, forMode: .common)

        if (self.__map != nil) {
            let _ = try? self.__map.setConstrainModeFor(.heightOnly)
        }
    }

    func validateDisplayLink() {
        if self.superview != nil
            && self.window != nil
            && displayLink == nil {
            displayLink = self.window?.screen.displayLink(withTarget: self, selector: #selector(updateFromDisplayLink))

            self.updateDisplayLinkPreferredFramesPerSecond()
            displayLink?.add(to: .current, forMode: .common)

        }
    }

    @objc func updateFromDisplayLink(displayLink: CADisplayLink) {
        if self.window == nil {
            return
        }

        if needsDisplayRefresh {
            needsDisplayRefresh = false
            self.displayCallback?()
        }
    }

    func startDisplayLink() {
        self.displayLink?.isPaused = false
        self.assertIsMainThread()
        self.needsDisplayRefresh = true
    }

    func updateDisplayLinkPreferredFramesPerSecond() {

        if displayLink == nil {

            var newFrameRate: PreferredFPS = .maximum

            if preferredFPS == .normal {
                // TODO: Check for legacy device
            } else {
                newFrameRate = preferredFPS
            }

            displayLink?.preferredFramesPerSecond = newFrameRate.rawValue
        }
    }

    func stopDisplayLink() {
        self.displayLink?.isPaused = true
        self.needsDisplayRefresh = false
        // Do we need to handle pending blocks?
    }

    func destroyDisplayLink() {
        self.displayLink?.invalidate()
        self.displayLink = nil
        self.needsDisplayRefresh = false
        // Do we need to handle pending blocks?
    }

    open override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow != nil {
            self.validateDisplayLink()
        }
    }

    open override func didMoveToWindow() {
        super.didMoveToWindow()

        if window != nil {
            self.validateDisplayLink()
        }
        else {
            // TODO: Fix this up correctly.
            displayLink?.invalidate()
            displayLink = nil
        }
    }

    open override func didMoveToSuperview() {
        self.validateDisplayLink()
        super.didMoveToSuperview()
    }

    @objc func willTerminate() {
        if !dormant {
            self.validateDisplayLink()
            dormant = true
        }
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: MBXMapClient conformance
    public func scheduleRepaint() {
        needsDisplayRefresh = true
    }

    public var peer: MBXPeerWrapper?

    // MARK: - MBXMetalViewProvider conformance
    public func getMetalView(for metalDevice: MTLDevice?) -> MTKView? {

        let metalView = MTKView(frame: self.frame, device: metalDevice)
        self.displayCallback = {
            metalView.draw()
        }

        metalView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        metalView.autoResizeDrawable = true
        metalView.contentScaleFactor = UIScreen.main.scale
        metalView.contentMode = .center
        metalView.isOpaque = self.isOpaque
        metalView.layer.isOpaque = self.isOpaque
        metalView.isPaused = true
        metalView.enableSetNeedsDisplay = false
        metalView.presentsWithTransaction = false

        self.insertSubview(metalView, at: 0)

        return metalView
    }

    // MARK: Conversion utilities
    /**
      Converts a point in a given view’s coordinate system to a geographic coordinate.

      - Parameter point: The point to convert.
      - Parameter view: An optional view the `point` is relative to.
                        Omitting this value assumes the point is relative to the `MapView`.
      - Returns: A CLLocationCoordinate that represents the geographic location of the point.
      */
    public func coordinate(for point: CGPoint, in view: UIView? = nil) -> CLLocationCoordinate2D {
        let view = view ?? self
        let screenCoordinate = self.convert(point, from: view).screenCoordinate // Transform to view's coordinate space
        return try! self.__map.coordinateForPixel(forPixel: screenCoordinate)
    }

    /**
      Converts a map coordinate to a `CGPoint`, relative to the map view.

      - Parameter coordinate: The coordinate to convert.
      - Parameter view: An optional view the resulting point will be relative to.
                        Omitting this value assumes resulting `CGPoint` will be expressed
                        relative to the `MapView`.
      - Returns: A `CGPoint` relative to the `UIView`.
      */
    public func point(for coordinate: CLLocationCoordinate2D, in view: UIView? = nil) -> CGPoint {
        let view = view ?? self
        let point = try! self.__map.pixelForCoordinate(for: coordinate).point
        let transformedPoint = self.convert(point, to: view)
        return transformedPoint
    }

    /**
     Transforms a view's frame into a set of coordinate bounds.

     - Parameter view: The `UIView` whose bounds will be transformed into a set of map coordinate bounds.
     - Returns: A `CoordinateBounds` object that represents the southwest and northeast corners of the view's bounds.
     */
    public func coordinateBounds(for view: UIView) -> CoordinateBounds {
        let rect = view.bounds

        let topRight = self.coordinate(for: CGPoint(x: rect.maxX, y: rect.minY), in: view).wrap()
        let bottomLeft = self.coordinate(for: CGPoint(x: rect.minX, y: rect.maxY), in: view).wrap()

        let southwest = CLLocationCoordinate2D(latitude: bottomLeft.latitude, longitude: bottomLeft.longitude)
        let northeast = CLLocationCoordinate2D(latitude: topRight.latitude, longitude: topRight.longitude)

        return CoordinateBounds(southwest: southwest, northeast: northeast)
    }

    /**
     Transforms a set of map coordinate bounds to a `CGRect`.

     - Parameter view: An optional `UIView` whose coordinate space the resulting `CGRect` will be relative to.
                       Omitting this value assumes the resulting `CGRect` will be expressed
                       relative to the `MapView`.
     - Returns: A `CGRect` whose corners represent the vertices of a set of `CoordinateBounds`.
     */
    public func rect(for coordinateBounds: CoordinateBounds, in view: UIView? = nil) -> CGRect {
        let view = view ?? self
        let southwest = coordinateBounds.southwest.wrap()
        let northeast = coordinateBounds.northeast.wrap()

        var rect = CGRect.zero

        let swPoint = self.point(for: southwest, in: view)
        let nePoint = self.point(for: northeast, in: view)

        rect = CGRect(origin: swPoint, size: CGSize.zero)

        rect = rect.extend(from: nePoint)

        return rect
    }

    func mapViewSupportsBackgroundRendering() -> Bool {
        // JK: check if this comment from gl-native is out of date

        // If this view targets an external display, such as AirPlay or CarPlay, we
        // can safely continue to render OpenGL content without tripping
        // gpus_ReturnNotPermittedKillClient in libGPUSupportMercury, because the
        // external connection keeps the application from truly receding to the
        // background.
        let screen = self.windowScreen()

        let supportsBackgroundRendering : Bool = (screen != nil && screen != UIScreen.main)
        return supportsBackgroundRendering
    }

    func isVisible() -> Bool {
        let screen = self.windowScreen()
        return (!self.isHidden && screen != nil)
    }

    func windowScreen() -> UIScreen? {
        if #available(iOS 13, *) {
            if let newScreen = self.window?.windowScene?.screen {
                return newScreen
            }
        }

        if let windowScreen = self.window?.screen {
            return windowScreen
        }

        return nil
    }
}

// MARK: Handle background rendering
extension BaseMapView: UIApplicationDelegate {

    func assertIsMainThread() {
        if !Thread.isMainThread {
            preconditionFailure("applicationWillResignActive must be accessed on the main thread.")
        }
    }

    public func applicationWillResignActive(_ application: UIApplication) {
        self.assertIsMainThread()

        if self.renderingInInactiveStateEnabled || self.mapViewSupportsBackgroundRendering() {
            return
        }

        self.stopDisplayLink()
        // We want to reduce memory usage before the map goes into the background
    }

    public func applicationDidEnterBackground(_ application: UIApplication) {
        self.assertIsMainThread()
        precondition(!self.dormant, "Should not be dormant heading into background.")

        if self.mapViewSupportsBackgroundRendering() { return }

        if self.renderingInInactiveStateEnabled {
            self.stopDisplayLink()
        }

        self.destroyDisplayLink()
        // Do we need to handle pending blocks?
        // how do we delete a metal view?
        guard let metalView = self.subviews.first as? MTKView else { return }
        metalView.delete(nil)

        // Handle non-rendering backgrounding
        // validate location services
        // flush
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        if self.mapViewSupportsBackgroundRendering() { return }

        // what is the equivalent of createViwe?

        if window?.screen != nil {
            self.validateDisplayLink()

            if self.renderingInInactiveStateEnabled && self.isVisible() {
                self.startDisplayLink()
            }
        }

        self.dormant = false

        // Validate location services

        // Reports events
        // Report number of render errors
    }

    func enableSnapshotView() {
        if self.metalSnapshotView == nil {
            self.metalSnapshotView = UIImageView(frame: self.getMetalView(for: nil)?.frame ?? self.frame)
            self.metalSnapshotView?.autoresizingMask = self.autoresizingMask
            let options = MapSnapshotOptions(size: self.frame.size, resourceOptions: self.resourceOptions ?? ResourceOptions())
            let snapshotter = Snapshotter(options: options)
            snapshotter.camera = self.cameraView.camera

            snapshotter.start(overlayHandler: nil) { [weak self] (result) in
                guard let self = self else { return }
                self.metalSnapshotView?.image = try? result.get()
            }
        }

        self.metalSnapshotView?.isHidden = false
        self.metalSnapshotView?.alpha = 1
        self.metalSnapshotView?.isOpaque = false

        // Handle a debug mask if applicable
    }

    public func applicationDidBecomeActive(_ application: UIApplication) {
        let applicationState : UIApplication.State = UIApplication.shared.applicationState

        if self.dormant == true {
            // create a view
            self.dormant = false
        }

        if self.displayLink != nil {
            if self.windowScreen() != nil {
                self.createDisplayLink()
            }
        }

        if applicationState == .active || (applicationState == .inactive && self.renderingInInactiveStateEnabled) {
            let mapViewVisible = self.isVisible()
            if self.displayLink != nil {
                if mapViewVisible && self.displayLink?.isPaused == true  {
                    self.startDisplayLink()
                }
                else if !mapViewVisible && self.displayLink?.isPaused != true {
                    // Unlikely scenario
                    self.stopDisplayLink()
                }
            }
        }

        if self.metalSnapshotView != nil && self.metalSnapshotView?.isHidden != true {
            UIView .transition(with: self, duration: 0.25, options: .transitionCrossDissolve) { [weak self] in
                guard let self = self else { return }
                self.metalSnapshotView?.isHidden = true
            } completion: { [weak self] (finished) in
                guard let self = self else { return }
                let subviews = self.metalSnapshotView?.subviews
                subviews?.forEach { $0.removeFromSuperview() }
            }

        }
    }
}
