import SwiftUI

/// A SwiftUI view that displays a Mapbox Map.
///
/// The `Map` is an entry point to display Mapbox Map in a SwiftUI Application. Typically, you create a ``Map`` in the `body` variable of your view. Then you can use
/// - ``Viewport`` and ``ViewportAnimation`` to manage map camera state and animations.
/// - `Map`'s modifier functions such as ``Map/mapStyle(_:)``,  ``Map/onTapGesture(count:perform:)``, ``Map/onLayerTapGesture(_:perform:)`` and many others to configure the map appearance and behavior.
/// - Map Content objects, such as ``Puck2D``, ``Puck3D``, ``PointAnnotation``, ``PolylineAnnotation``, ``PolygonAnnotation``, ``MapViewAnnotation`` and others, to display your content on the map.
///
/// In the example below the `ContentView` displays a map with [Mapbox Standard](https://www.mapbox.com/blog/standard-core-style) style in the dusk light preset, shows the user location indicator (Puck), displays a view annotation with a SwiftUI View inside, draws a polygon, and focuses camera on that polygon.
///
/// ```swift
/// struct ContentView: View {
///     static let polygon = Polygon(...)
///
///     // Configures the map camera to overview the given polygon.
///     @State var viewport = Viewport.overview(geometry: Self.polygon)
///
///     var body: some View {
///         Map(viewport: $viewport) {
///             // Displays the user location.
///             Puck2D(heading: bearing)
///
///             // Displays a view annotation.
///             MapViewAnnotation(CLLocationCoordinate(...))
///                 Text("🚀")
///                     .background(Circle().fill(.red))
///             }
///
///             // Displays a polygon annotation.
///             PolygonAnnotation(polygon: Self.polygon)
///                 .fillColor(StyleColor(.systemBlue))
///                 .fillOpacity(0.5)
///                 .fillOutlineColor(StyleColor(.black))
///                 .onTapGesture {
///                     print("Polygon is tapped")
///                 }
///          }
///          // Uses Mapbox Standard style in the dusk light preset.
///          .mapStyle(.standard(lightPreset: .dusk))
///     }
/// }
/// ```
///
/// Check out the <doc:SwiftUI-User-Guide> for more information about ``Map`` capabilities, and the <doc:Map-Content-Gestures-User-Guide> for more information about gesture handling.
public struct Map: UIViewControllerRepresentable {
    var mapDependencies = MapDependencies()
    private var viewport: ConstantOrBinding<Viewport>
    private let urlOpenerProvider: URLOpenerProvider

    @Environment(\.layoutDirection) var layoutDirection

    /// Creates a map that displays annotations.
    ///
    /// - Parameters:
    ///     - viewport: The camera viewport to display.
    ///     - content: A map content building closure.
    @available(iOSApplicationExtension, unavailable)
    public init(
        viewport: Binding<Viewport>,
        @MapContentBuilder content: @escaping () -> some MapContent
    ) {
        self.init(
            _viewport: .binding(viewport),
            urlOpenerProvider: URLOpenerProvider(),
            content: content)
    }

    /// Creates a map that displays annotations.
    ///
    /// - Parameters:
    ///     - initialViewport: The camera viewport to display.
    ///     - content: A map content building closure.
    @available(iOSApplicationExtension, unavailable)
    public init(
        initialViewport: Viewport = .styleDefault,
        @MapContentBuilder content: @escaping () -> some MapContent
    ) {
        self.init(
            _viewport: .constant(initialViewport),
            urlOpenerProvider: URLOpenerProvider(),
            content: content)
    }

    private init(
        _viewport: ConstantOrBinding<Viewport>,
        urlOpenerProvider: URLOpenerProvider,
        content: (() -> any MapContent)? = nil
    ) {
        self.viewport = _viewport
        self.urlOpenerProvider = urlOpenerProvider
        if let makeContent = content {
            mapDependencies.mapContent = makeContent
        }
    }

    public func makeCoordinator() -> Coordinator {
        let urlOpener = ClosureURLOpener()
        sendTelemetry(\.swiftUI)
        let mapView = MapView(frame: .zero, urlOpener: urlOpener)
        let viewController = MapViewController(mapView: mapView)

        let mapContentDependencies = MapContentDependencies(
            layerAnnotations: Ref.weakRef(mapView, property: \.annotations),
            viewAnnotations: Ref.weakRef(mapView, property: \.viewAnnotations),
            location: Ref.weakRef(mapView, property: \.location),
            mapboxMap: Ref { [weak mapView] in mapView?.mapboxMap },
            addAnnotationViewController: { [weak viewController] childVC in
                guard let viewController else { return }
                viewController.addChild(childVC)
                childVC.didMove(toParent: viewController)
            },
            removeAnnotationViewController: { childVC in
                childVC.willMove(toParent: nil)
                childVC.removeFromParent()
            }
        )

        mapView.mapboxMap.setMapContentDependencies(mapContentDependencies)

        let basicCoordinator = MapBasicCoordinator(
            setViewport: viewport.setter,
            mapView: MapViewFacade(from: mapView)
        )

        return Coordinator(
            basic: basicCoordinator,
            viewController: viewController,
            urlOpener: urlOpener,
            mapView: mapView)
    }

    public func makeUIViewController(context: Context) -> UIViewController {
        context.coordinator.urlOpener.openURL = urlOpenerProvider.resolve(in: context.environment)
        context.environment.mapViewProvider?.mapView = context.coordinator.mapView

        return context.coordinator.viewController
    }

    public func updateUIViewController(_ mapController: UIViewController, context: Context) {
        mapController.additionalSafeAreaInsets = UIEdgeInsets(insets: mapDependencies.additionalSafeArea, layoutDirection: layoutDirection)
        context.coordinator.basic.update(
            viewport: viewport,
            deps: mapDependencies,
            layoutDirection: layoutDirection,
            animationData: context.transaction.viewportAnimationData)
    }
}

extension Map {

    /// Creates a map with a viewport binding.
    ///
    /// - Parameters:
    ///     - viewport: The camera viewport to display.
    @available(iOSApplicationExtension, unavailable)
    public init(viewport: Binding<Viewport>) {
        self.init(
            _viewport: .binding(viewport),
            urlOpenerProvider: URLOpenerProvider()
        )
    }

    /// Creates a map an initial viewport.
    ///
    /// - Parameters:
    ///     - initialViewport: Initial camera viewport.
    @available(iOSApplicationExtension, unavailable)
    public init(initialViewport: Viewport = .styleDefault) {
        self.init(
            _viewport: .constant(initialViewport),
            urlOpenerProvider: URLOpenerProvider()
        )
    }

    /// Creates a map with a viewport binding.
    ///
    /// Use this method to create a map in application extension context, or to override default url opening mechanism on iOS < 15.
    ///
    /// - Note: Starting from iOS 14  ``Map`` will use standard `OpenURLAction` taken from the `Environment`
    ///   to open attribution urls, if `urlOpener` is not set.
    ///
    /// - Parameters:
    ///     - viewport: The camera viewport to display.
    ///     - urlOpener: A closure that handles attribution url opening.
    ///     - content: A map content building closure.
    public init(
        viewport: Binding<Viewport>,
        urlOpener: @escaping MapURLOpener,
        @MapContentBuilder content: @escaping () -> some MapContent
    ) {
        self.init(
            _viewport: .binding(viewport),
            urlOpenerProvider: URLOpenerProvider(userUrlOpener: urlOpener),
            content: content)
    }

    /// Creates a map an initial viewport.
    ///
    /// Use this method to create a map in application extension context, or to override default url opening mechanism on iOS < 15.
    ///
    /// - Note: Starting from iOS 14  ``Map`` will use standard `OpenURLAction` taken from the `Environment`
    ///   to open attribution urls, if `urlOpener` is not set.
    ///
    /// - Parameters:
    ///     - initialViewport: The camera viewport to display.
    ///     - urlOpener: A closure that handles attribution url opening.
    ///     - content: A map content building closure.
    public init(
        initialViewport: Viewport = .styleDefault,
        urlOpener: @escaping MapURLOpener,
        @MapContentBuilder content: @escaping () -> some MapContent
    ) {
        self.init(
            _viewport: .constant(initialViewport),
            urlOpenerProvider: URLOpenerProvider(userUrlOpener: urlOpener),
            content: content)
    }
}

public extension Map {

    /// Filters attribution menu items
    /// Restricted API. Please contact Mapbox to discuss your use case if you intend to use this property.
    @_spi(Restricted)
    func attributionMenuFilter(_ filter: @escaping (AttributionMenuItem) -> Bool) -> Self {
        copyAssigned(self, \.mapDependencies.attributionMenuFilter, filter)
    }

    /// Sets camera bounds.
    func cameraBounds(_ cameraBounds: CameraBoundsOptions) -> Self {
        copyAssigned(self, \.mapDependencies.cameraBounds, cameraBounds)
    }

    /// Sets style to the map.
    ///
    /// - Parameters:
    ///     - mapStyle: A map style configuration.
    func mapStyle(_ mapStyle: MapStyle) -> Self {
        copyAssigned(self, \.mapDependencies.mapStyle, mapStyle)
    }

    /// Sets constraint mode to the map. If not set, `heightOnly` will be in use.
    func constrainMode(_ constrainMode: ConstrainMode) -> Self {
        copyAssigned(self, \.mapDependencies.constrainMode, constrainMode)
    }
    /// Sets viewport mode to the map.
    func viewportMode(_ viewportMode: ViewportMode) -> Self {
        copyAssigned(self, \.mapDependencies.viewportMode, viewportMode)
    }

    /// Sets ``NorthOrientation`` to the map. If not set, `upwards` will be in use.
    func northOrientation(_ northOrientation: NorthOrientation) -> Self {
        copyAssigned(self, \.mapDependencies.orientation, northOrientation)
    }

    /// Sets ``OrnamentOptions`` to the map.
    func ornamentOptions(_ options: OrnamentOptions) -> Self {
        copyAssigned(self, \.mapDependencies.ornamentOptions, options)
    }

    /// Sets ``MapViewDebugOptions`` to the map.
    func debugOptions(_ debugOptions: MapViewDebugOptions) -> Self {
        copyAssigned(self, \.mapDependencies.debugOptions, debugOptions)
    }

    /// A boolean value that determines whether the view is opaque. Default is true.
    func opaque(_ value: Bool) -> Self {
        copyAssigned(self, \.mapDependencies.isOpaque, value)
    }

    /// The preferred frames per second used for map rendering.
    /// The system can change the available range of frame rates because of factors in system policies and a person’s preferences.
    /// Changing this setting maybe beneficial to get smoother experience on devices which support 120 FPS.
    ///
    /// - Note: `range` values  have effect only on iOS 15.0 and newer. Value`nil` in any of the parameters is interpreted as using system default value.
    ///
    /// - Parameters:
    ///    - range: Allowed frame rate range. Negative and values less than 1 will be clamped to 1.
    ///    - preferred: Preferred frame rate.  Negative and values less than 1 will be clamped to 1, while too large values will be clamped to Int.max.
    func frameRate(range: ClosedRange<Float>? = nil, preferred: Float? = nil) -> Self {
        copyAssigned(
            self, \.mapDependencies.frameRate, FrameRate(range: range, preferred: preferred))
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
    func presentationTransactionMode(_ value: PresentationTransactionMode) -> Self {
        copyAssigned(self, \.mapDependencies.presentationTransactionMode, value)
    }

    /// :nodoc:
    @available(*, unavailable, message: "Transaction mode is managed automatically, see presentationTransactionMode")
    func presentsWithTransaction(_: Bool) {}

    /// Indicates whether the ``Viewport`` should idle when map receives pan touch input.
    ///
    /// Defaults to `true`.
    func transitionsToIdleUponUserInteraction(_ value: Bool) -> Self {
        copyAssigned(self, \.mapDependencies.viewportOptions.transitionsToIdleUponUserInteraction, value)
    }

    /// When `true`, all viewport states increase the camera padding by the amount of the safe area insets.
    ///
    /// The following formula is used to calculate the camera padding:
    /// ```
    /// safe area insets = view safe area insets + additional safe area insets
    /// camera padding = viewport padding + safe area insets
    /// ```
    ///
    /// If your view has some UI elements on top of the map and you want them to be padded,
    /// use ``Map/additionalSafeAreaInsets(_:)`` to specify an additional amount of safe area insets.
    ///
    /// - Note: ``MapViewAnnotation`` will respect the padding area and will be placed outside of it.
    ///
    /// Defaults to `true`.
    func usesSafeAreaInsetsAsPadding(_ value: Bool) -> Self {
        copyAssigned(self, \.mapDependencies.viewportOptions.usesSafeAreaInsetsAsPadding, value)
    }

    /// Amount of additional safe area insets.
    ///
    /// If called multiple times, the last call wins. This property behaves identically to the
    /// `UIViewController.additionalSafeAreaInsets`.
    ///
    /// - Note: This property cannot be animated.
    func additionalSafeAreaInsets(_ insets: SwiftUI.EdgeInsets) -> Self {
        copyAssigned(self, \.mapDependencies.additionalSafeArea, insets)
    }

    /// Collects CPU, GPU resource usage and timings of layers and rendering groups over a user-configurable sampling duration.
    /// Use the collected information to find which layers or rendering groups might be performing poorly.
    ///
    /// Use ``PerformanceStatisticsOptions`` to configure the following collection behaviours:
    ///     - Which types of sampling to perform, whether cumulative, per-frame, or both.
    ///     - Duration of sampling in milliseconds. Value 0 forces the collection of performance statistics every frame.
    ///
    /// Utilize ``PerformanceStatisticsCallback`` to observe the collected performance statistics. The callback function is invoked
    /// after the configured sampling duration has elapsed. The callback is invoked on the main thread. The collection process is
    /// continuous; without user-input, it restarts after each callback invocation.
    /// - Note: Specifying a negative sampling duration or omitting the callback function will result in no operation, which will be logged for visibility.
    /// - Note: The statistics collection can be canceled by setting `nil` to the options parameter.
    /// The callback function will be called every time the configured sampling duration ``PerformanceStatisticsOptions/sasamplingDurationMillis has elapsed.
    ///
    /// - Parameters:
    ///   - options The statistics collection options to collect.
    ///   - callback The callback to be invoked when performance statistics are available.
    /// - Returns:  An ``AnyCancelable`` object that can be used to cancel performance statistics collection.
    func collectPerformanceStatistics(_ options: PerformanceStatisticsOptions?, callback: @escaping (PerformanceStatistics) -> Void) -> Self {
        copyAssigned(self, \.mapDependencies.performanceStatisticsParameters, options.map { PerformanceStatisticsParameters(options: $0, callback: callback) })
    }

    /// Sets the amount of additional safe area insets for the given edges.
    ///
    /// If called multiple times, the last call wins. This property behaves identically to the
    /// `UIViewController.additionalSafeAreaInsets`.
    ///
    /// - Note: This property cannot be animated.
    func additionalSafeAreaInsets(_ edges: Edge.Set = .all, _ length: CGFloat) -> Self {
        var copy = self
        copy.mapDependencies.additionalSafeArea.updateEdges(edges, length)
        return copy
    }
}

extension Map {

    /// Map Coordinator.
    public final class Coordinator {
        let basic: MapBasicCoordinator
        let viewController: UIViewController
        let urlOpener: ClosureURLOpener
        let mapView: MapView

        init(
            basic: MapBasicCoordinator,
            viewController: UIViewController,
            urlOpener: ClosureURLOpener,
            mapView: MapView
        ) {
            self.basic = basic
            self.viewController = viewController
            self.urlOpener = urlOpener
            self.mapView = mapView
        }
    }

    private final class MapViewController: UIViewController {
        private let mapView: MapView

        init(mapView: MapView) {
            self.mapView = mapView
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            view.addConstrained(child: mapView)
            mapView.mapboxMap.size = view.bounds.size
        }
    }
}

private extension Binding {
    var setter: (Value) -> Void {
        { self.wrappedValue = $0 }
    }
}

private extension ConstantOrBinding {
    var setter: ((T) -> Void)? {
        switch self {
        case .constant:
            return nil
        case .binding(let binding):
            return binding.setter
        }
    }
}
