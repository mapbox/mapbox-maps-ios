import SwiftUI

/// An action called when a new location is emitted.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
@_spi(Experimental)
@available(iOS 13.0, *)
public typealias LocationUpdateAction = (Location) -> Void

/// A SwiftUI view that displays Mapbox Map.
///
/// Use `Map` do display Mapbox Map in SwiftUI application.
///
/// ```swift
/// struct ContentView: View {
///     static let polygon = Polygon(...)
///
///     // Configures map camera to overview the given polygon.
///     @State var viewport = Viewport.overview(geometry: Self.polygon)
///
///     var body: some View {
///         Map(viewport: $viewport) {
///             // Displays user location.
///             Puck2D(heading: bearing)
///
///             // Displays view annotation.
///             ViewAnnotation(CLLocationCoordinate(...))
///                 Text("🚀")
///                     .background(Circle().fill(.red))
///             }
///
///             // Displays polygon annotation.
///             PolygonAnnotation(polygon: Self.polygon)
///                 .fillColor(StyleColor(.systemBlue))
///                 .fillOpacity(0.5)
///                 .fillOutlineColor(StyleColor(.black))
///                 .onTapGesture {
///                     print("Polygon is tapped")
///                 }
///          }
///          // Configures Mapbox Standard style to use "Dusk" preset.
///          .mapStyle(.standard(lightPreset: .dusk))
///     }
/// }
/// ```
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
@_spi(Experimental)
@available(iOS 13.0, *)
public struct Map: UIViewControllerRepresentable {
    var viewport: ConstantOrBinding<Viewport>
    var mapDependencies = MapDependencies()
    private var mapContentVisitor = DefaultMapContentVisitor()
    private let urlOpenerProvider: URLOpenerProvider

    @Environment(\.layoutDirection) var layoutDirection

    /// Creates a map that displays annotations.
    ///
    /// - Parameters:
    ///     - viewport: The camera viewport to display.
    ///     - content: A map content building closure.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    @available(iOSApplicationExtension, unavailable)
    public init(
        viewport: Binding<Viewport>,
        @MapContentBuilder content: @escaping () -> MapContent
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
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    @available(iOSApplicationExtension, unavailable)
    public init(
        initialViewport: Viewport = .styleDefault,
        @MapContentBuilder content: @escaping () -> MapContent
    ) {
        self.init(
            _viewport: .constant(initialViewport),
            urlOpenerProvider: URLOpenerProvider(),
            content: content)
    }

    private init(
        _viewport: ConstantOrBinding<Viewport>,
        urlOpenerProvider: URLOpenerProvider,
        content: (() -> MapContent)? = nil
    ) {
        self.viewport = _viewport
        self.urlOpenerProvider = urlOpenerProvider
        content?().visit(mapContentVisitor)
    }

    public func makeCoordinator() -> Coordinator {
        let urlOpener = ClosureURLOpener()
        let mapView = MapView(frame: .zero, urlOpener: urlOpener)
        let vc = MapViewController(mapView: mapView)

        let basicCoordinator = MapBasicCoordinator(
            setViewport: viewport.setter,
            mapView: MapViewFacade(from: mapView))

        let viewAnnotationCoordinator = ViewAnnotationCoordinator(
            viewAnnotationsManager: mapView.viewAnnotations,
            addViewController: { childVC in
                vc.addChild(childVC)
                childVC.didMove(toParent: vc)
            },
            removeViewController: { childVC in
                childVC.willMove(toParent: nil)
                childVC.removeFromParent()
            }
        )

        let layerAnnotationCoordinator = LayerAnnotationCoordinator(annotationOrchestrator: mapView.annotations)

        return Coordinator(
            basic: basicCoordinator,
            viewAnnotation: viewAnnotationCoordinator,
            layerAnnotation: layerAnnotationCoordinator,
            viewController: vc,
            urlOpener: urlOpener,
            mapView: mapView)
    }

    public func makeUIViewController(context: Context) -> UIViewController {
        context.coordinator.urlOpener.openURL = urlOpenerProvider.resolve(in: context.environment)
        context.environment.mapViewProvider?.mapView = context.coordinator.mapView
        return context.coordinator.viewController
    }

    public func updateUIViewController(_ mapController: UIViewController, context: Context) {
        context.coordinator.basic.update(
            viewport: viewport,
            deps: mapDependencies,
            layoutDirection: layoutDirection,
            animationData: context.transaction.viewportAnimationData)
        context.coordinator.viewAnnotation.updateAnnotations(to: mapContentVisitor.visitedViewAnnotations)
        context.coordinator.mapView.location.options = mapContentVisitor.locationOptions
        context.coordinator.layerAnnotation.update(annotations: mapContentVisitor.annotationGroups)
    }
}

@available(iOS 13.0, *)
extension Map {

    /// Creates a map.
    ///
    /// - Parameters:
    ///     - viewport: The camera viewport to display.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    @available(iOSApplicationExtension, unavailable)
    public init(
        viewport: Binding<Viewport>
    ) {
        self.init(
            _viewport: .binding(viewport),
            urlOpenerProvider: URLOpenerProvider(),
            content: nil)
    }

    /// Creates a map.
    ///
    /// - Parameters:
    ///     - initialViewport: Initial camera viewport.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    @available(iOSApplicationExtension, unavailable)
    public init(
        initialViewport: Viewport = .styleDefault
    ) {
        self.init(
            _viewport: .constant(initialViewport),
            urlOpenerProvider: URLOpenerProvider(),
            content: nil)
    }

    /// Creates a map.
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
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public init(
        viewport: Binding<Viewport>,
        urlOpener: @escaping MapURLOpener,
        @MapContentBuilder content: @escaping () -> MapContent
    ) {
        self.init(
            _viewport: .binding(viewport),
            urlOpenerProvider: URLOpenerProvider(userUrlOpener: urlOpener),
            content: content)
    }

    /// Creates a map.
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
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    public init(
        initialViewport: Viewport = .styleDefault,
        urlOpener: @escaping MapURLOpener,
        @MapContentBuilder content: @escaping () -> MapContent
    ) {
        self.init(
            _viewport: .constant(initialViewport),
            urlOpenerProvider: URLOpenerProvider(userUrlOpener: urlOpener),
            content: content)
    }
}

@available(iOS 13.0, *)
extension Map {
    func set<T>(_ keyPath: WritableKeyPath<Map, T>, _ value: T) -> Self {
        with(self, setter(keyPath, value))
    }

    func append<T>(_ keyPath: WritableKeyPath<Map, T>, _ newElement: T.Element) -> Self where T: RangeReplaceableCollection {
        var updated = self
        updated[keyPath: keyPath].append(newElement)
        return updated
    }
}

#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
@available(iOS 13.0, *)
public extension Map {
    /// Sets camera bounds.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    func cameraBounds(_ cameraBounds: CameraBoundsOptions) -> Self {
        set(\.mapDependencies.cameraBounds, cameraBounds)
    }

    /// Sets style to the map.
    ///
    /// - Parameters:
    ///     - mapStyle: A map style configuration.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    func mapStyle(_ mapStyle: MapStyle) -> Self {
        set(\.mapDependencies.mapStyle, mapStyle)
    }

    /// Configures gesture options.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    func gestureOptions(_ options: GestureOptions) -> Self {
        set(\.mapDependencies.gestureOptions, options)
    }

    /// Sets constraint mode to the map. If not set, `heightOnly` will be in use.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    func constrainMode(_ constrainMode: ConstrainMode) -> Self {
        set(\.mapDependencies.constrainMode, constrainMode)
    }

    /// Sets viewport mode to the map.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    func viewportMode(_ viewportMode: ViewportMode) -> Self {
        set(\.mapDependencies.viewportMode, viewportMode)
    }

    /// Sets ``NorthOrientation`` to the map. If not set, `upwards` will be in use.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    func northOrientation(_ northOrientation: NorthOrientation) -> Self {
        set(\.mapDependencies.orientation, northOrientation)
    }

    /// Sets ``OrnamentOptions`` to the map.
#if swift(>=5.8)
    @_documentation(visibility: public)
#endif
    func ornamentOptions(_ options: OrnamentOptions) -> Self {
        set(\.mapDependencies.ornamentOptions, options)
    }
}

@available(iOS 13.0, *)
extension Map {

    /// Map Coordinator.
    public final class Coordinator {
        let basic: MapBasicCoordinator
        let viewAnnotation: ViewAnnotationCoordinator
        let layerAnnotation: LayerAnnotationCoordinator
        let viewController: UIViewController
        let urlOpener: ClosureURLOpener
        let mapView: MapView

        init(
            basic: MapBasicCoordinator,
            viewAnnotation: ViewAnnotationCoordinator,
            layerAnnotation: LayerAnnotationCoordinator,
            viewController: UIViewController,
            urlOpener: ClosureURLOpener,
            mapView: MapView
        ) {
            self.basic = basic
            self.viewAnnotation = viewAnnotation
            self.layerAnnotation = layerAnnotation
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

        override func loadView() {
            view = mapView
        }
    }
}

@available(iOS 13.0, *)
private extension Binding {
    var setter: (Value) -> Void {
        { self.wrappedValue = $0 }
    }
}

@available(iOS 13.0, *)
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
