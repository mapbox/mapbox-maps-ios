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

    /// The underlying renderer object responsible for rendering the map
    public var __map: Map!

    /// The underlying metal view that is used to render the map
    internal var metalView: MTKView?

    /// Resource options for this map view
    internal var resourceOptions: ResourceOptions?

    public var needsDisplayRefresh: Bool = false
    public var dormant: Bool = false
    public var displayCallback: (() -> Void)?
    private var observerConcrete: ObserverConcrete!
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
        // cameraView.centerCoordinate is allowed to exceed [-180, 180]
        // so that core animation interpolation works correctly when
        // crossing the antimeridian. We wrap here to hide that implementation
        // detail when accessing centerCoordinate via BaseMapView
        return cameraView.centerCoordinate.wrap()
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
            fatalError("Must provide access token to the MapView in Interface Builder / Storyboard")
        }

        let ibStyleURL = BaseMapView.parseIBStringAsURL(ibString: self.styleURL__)
        let styleURL = ibStyleURL ?? URL(string: "mapbox://styles/mapbox/streets-v11")!

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

    func validateDisplayLink() {
        if self.superview != nil
            && self.window != nil
            && displayLink == nil {
            let target = BaseMapViewProxy(mapView: self)
            displayLink = self.window?.screen.displayLink(withTarget: target, selector: #selector(target.updateFromDisplayLink))

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

    func updateDisplayLinkPreferredFramesPerSecond() {

        if let displayLink = displayLink {

            var newFrameRate: PreferredFPS = .maximum

            if preferredFPS == .normal {
                // TODO: Check for legacy device
            } else {
                newFrameRate = preferredFPS
            }

            displayLink.preferredFramesPerSecond = newFrameRate.rawValue
        }
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
            metalView.setNeedsDisplay()
        }

        metalView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        metalView.autoResizeDrawable = true
        metalView.contentScaleFactor = UIScreen.main.scale
        metalView.contentMode = .center
        metalView.isOpaque = self.isOpaque
        metalView.layer.isOpaque = self.isOpaque
        metalView.isPaused = true
        metalView.enableSetNeedsDisplay = true
        metalView.presentsWithTransaction = false

        self.insertSubview(metalView, at: 0)
        self.metalView = metalView

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
}

private class BaseMapViewProxy: NSObject {
    weak var mapView: BaseMapView?

    init(mapView: BaseMapView) {
        self.mapView = mapView
        super.init()
    }

    @objc func updateFromDisplayLink(displayLink: CADisplayLink) {
        mapView?.updateFromDisplayLink(displayLink: displayLink)
    }
}
