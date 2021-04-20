@_exported import MapboxCoreMaps
@_exported import MapboxCommon
import UIKit
import Turf

// swiftlint:disable file_length
internal typealias PendingAnimationCompletion = (completion: AnimationCompletion, animatingPosition: UIViewAnimatingPosition)

open class BaseMapView: UIView {

    /// The underlying renderer object responsible for rendering the map
    public private(set) var __map: Map!

    private let mapClient = DelegatingMapClient()
    private let observer = DelegatingObserver()

    /// The underlying metal view that is used to render the map
    internal private(set) var metalView: MTKView?

    /// Resource options for this map view
    internal private(set) var resourceOptions: ResourceOptions?

    /// List of completion blocks that need to be completed by the displayLink
    internal var pendingAnimatorCompletionBlocks: [PendingAnimationCompletion] = []

    /// Pointer HashTable for holding camera animators
    internal var cameraAnimatorsHashTable = NSHashTable<CameraAnimatorProtocol>.weakObjects()

    /// List of animators currently alive
    public var cameraAnimators: [CameraAnimator] {

        var animators: [CameraAnimator] = []
        cameraAnimatorsHashTable.allObjects.forEach { (animator) in
            if let animator = animator as? CameraAnimator {
                animators.append(animator)
            }
        }

        return animators
    }

    /// Map of event types to subscribed event handlers
    private var eventHandlers: [String: [(MapboxCoreMaps.Event) -> Void]] = [:]

    private var needsDisplayRefresh: Bool = false
    private var dormant: Bool = false
    private var displayCallback: (() -> Void)?
    @objc dynamic internal var displayLink: CADisplayLink?

    @IBInspectable private var styleURI__: String = ""

    /// Outlet that can be used when initializing a MapView with a Storyboard or
    /// a nib.
    @IBOutlet internal private(set) weak var mapInitOptionsProvider: MapInitOptionsProvider?

    internal var preferredFPS: PreferredFPS = .normal {
        didSet {
            updateDisplayLinkPreferredFramesPerSecond()
        }
    }

    /// The map's current camera
    public var camera: CameraOptions {
        return __map.getCameraOptions(forPadding: nil)
    }

    /// The map's current center coordinate.
    public var centerCoordinate: CLLocationCoordinate2D {
        guard let center = camera.center else {
            fatalError("Center is nil in camera options")
        }
        return center
    }

    /// The map's  zoom level.
    public var zoom: CGFloat {
        guard let zoom = camera.zoom else {
            fatalError("Zoom is nil in camera options")
        }
        return CGFloat(zoom)
    }

    /// The map's bearing, measured clockwise from 0° north.
    public var bearing: CLLocationDirection {
        guard let bearing = camera.bearing else {
            fatalError("Bearing is nil in camera options")
        }
        return CLLocationDirection(bearing)
    }

    /// The map's pitch, falling within a range of 0 to 60.
    public var pitch: CGFloat {
        guard let pitch = camera.pitch else {
            fatalError("Pitch is nil in camera options")
        }

        return pitch
    }

    /// The map's camera padding
    public var padding: UIEdgeInsets {
        return camera.padding ?? .zero
    }

    // MARK: Init
    public init(frame: CGRect, mapInitOptions: MapInitOptions, styleURI: URL?) {
        super.init(frame: frame)
        self.commonInit(mapInitOptions: mapInitOptions,
                        styleURI: styleURI)
    }

    private func commonInit(mapInitOptions: MapInitOptions, styleURI: URL?) {
        checkForMetalSupport()

        self.resourceOptions = mapInitOptions.resourceOptions

        let resolvedMapOptions: MapOptions

        if mapInitOptions.mapOptions.size == nil {
            // Update using the view's size
            let other = mapInitOptions.mapOptions
            resolvedMapOptions = MapOptions(__contextMode: other.__contextMode,
                                            constrainMode: other.__constrainMode,
                                            viewportMode: other.__viewportMode,
                                            orientation: other.__orientation,
                                            crossSourceCollisions: other.__crossSourceCollisions,
                                            size: Size(width: Float(bounds.width), height: Float(bounds.height)),
                                            pixelRatio: other.pixelRatio,
                                            glyphsRasterizationOptions: other.glyphsRasterizationOptions)
        } else {
            resolvedMapOptions = mapInitOptions.mapOptions
        }
        mapClient.delegate = self
        __map = Map(client: mapClient, mapOptions: resolvedMapOptions, resourceOptions: mapInitOptions.resourceOptions)

        __map?.createRenderer()

        observer.delegate = self
        let events = MapEvents.EventKind.allCases.map({ $0.rawValue })
        __map.subscribe(for: observer, events: events)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willTerminate),
                                               name: UIApplication.willTerminateNotification,
                                               object: nil)

        if let validStyleURI = styleURI {
            __map?.setStyleURIForUri(validStyleURI.absoluteString)
        }
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

        let ibStyleURI = BaseMapView.parseIBStringAsURL(ibString: styleURI__)
        let styleURI = ibStyleURI ?? StyleURI.streets.rawValue

        commonInit(mapInitOptions: mapInitOptions, styleURI: styleURI)
    }

    public func on(_ eventType: MapEvents.EventKind, handler: @escaping (MapboxCoreMaps.Event) -> Void) {
        var handlers = eventHandlers[eventType.rawValue] ?? []
        handlers.append(handler)
        eventHandlers[eventType.rawValue] = handlers
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        let size = MapboxCoreMaps.Size(width: Float(bounds.size.width),
                                       height: Float(bounds.size.height))
        __map?.setSizeFor(size)
    }

    func validateDisplayLink() {
        if superview != nil
            && window != nil
            && displayLink == nil {
            let target = BaseMapViewProxy(mapView: self)
            displayLink = window?.screen.displayLink(withTarget: target, selector: #selector(target.updateFromDisplayLink))

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

            for animator in cameraAnimatorsHashTable.allObjects {
                animator.update()
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
        let screenCoordinate = convert(point, from: view).screenCoordinate // Transform to view's coordinate space
        return __map.coordinateForPixel(forPixel: screenCoordinate)
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
        let point = __map.pixelForCoordinate(for: coordinate).point
        let transformedPoint = convert(point, to: view)
        return transformedPoint
    }

    /**
     Transforms a view's frame into a set of coordinate bounds.

     - Parameter view: The `UIView` whose bounds will be transformed into a set of map coordinate bounds.
     - Returns: A `CoordinateBounds` object that represents the southwest and northeast corners of the view's bounds.
     */
    public func coordinateBounds(for view: UIView) -> CoordinateBounds {
        let rect = view.bounds

        let topRight = coordinate(for: CGPoint(x: rect.maxX, y: rect.minY), in: view).wrap()
        let bottomLeft = coordinate(for: CGPoint(x: rect.minX, y: rect.maxY), in: view).wrap()

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

        let swPoint = point(for: southwest, in: view)
        let nePoint = point(for: northeast, in: view)

        rect = CGRect(origin: swPoint, size: CGSize.zero)

        rect = rect.extend(from: nePoint)

        return rect
    }
}

extension BaseMapView: DelegatingObserverDelegate {
    /// Notify correct handler
    internal func notify(for event: MapboxCoreMaps.Event) {
        let handlers = eventHandlers[event.type]
        handlers?.forEach { (handler) in
            handler(event)
        }
    }
}

extension BaseMapView: DelegatingMapClientDelegate {
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
        metalView.presentsWithTransaction = true

        insertSubview(metalView, at: 0)
        self.metalView = metalView

        return metalView
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
