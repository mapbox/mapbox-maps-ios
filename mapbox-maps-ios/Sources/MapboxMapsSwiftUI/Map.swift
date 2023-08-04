@_exported import MapboxMaps
import SwiftUI

@_spi(Experimental)
@available(iOS 13.0, *)
public extension CameraState {
    /// Initializes CameraState with center and zoom.
    init(center: CLLocationCoordinate2D, zoom: CGFloat) {
        self.init(center: center, padding: .zero, zoom: zoom, bearing: 0, pitch: 0)
    }
}

/// Represents location and rendered feaures of the tap.
@_spi(Experimental)
@available(iOS 13.0, *)
public struct MapLayerTapPayload {
    public var point: CGPoint
    public var coordinate: CLLocationCoordinate2D
    public var features: [QueriedRenderedFeature]
}

/// An action called when the map is tapped.
@_spi(Experimental)
@available(iOS 13.0, *)
public typealias MapTapAction = (CGPoint) -> Void

/// An action called when the specified layer is tapped.
@_spi(Experimental)
@available(iOS 13.0, *)
public typealias MapLayerTapAction = (MapLayerTapPayload) -> Void

/// An action called when a new location is emitted.
@_spi(Experimental)
@available(iOS 13.0, *)
public typealias LocationUpdateAction = (Location) -> Void

/// A view that displays Mapbox Map.
@_spi(Experimental)
@available(iOS 13.0, *)
public struct Map: UIViewControllerRepresentable {
    var viewport: ConstantOrBinding<Viewport>
    var mapDependencies = MapDependencies()
    private var locationDependencies = LocationDependencies()
    private var mapContentVisitor = DefaultMapContentVisitor()

    @Environment(\.layoutDirection) var layoutDirection

    /// Creates a map that displays annotations.
    ///
    /// - Parameters:
    ///     - viewport: The camera viewport to display.
    ///     - locationOptions: The options to configure ``LocationManager``.
    ///     - content: A map content building closure.
    public init(
        viewport: Binding<Viewport>,
        locationOptions: LocationOptions = LocationOptions(),
        @MapContentBuilder content: @escaping () -> MapContent
    ) {
        self.init(
            _viewport: .binding(viewport),
            locationOptions: locationOptions,
            content: content)
    }

    /// Creates a map that displays annotations.
    ///
    /// - Parameters:
    ///     - initialViewport: The camera viewport to display.
    ///     - locationOptions: The options to configure ``LocationManager``.
    ///     - content: A map content building closure.
    public init(
        initialViewport: Viewport = .styleDefault,
        locationOptions: LocationOptions = LocationOptions(),
        @MapContentBuilder content: @escaping () -> MapContent
    ) {
        self.init(
            _viewport: .constant(initialViewport),
            locationOptions: locationOptions,
            content: content)
    }

    private init(
        _viewport: ConstantOrBinding<Viewport>,
        locationOptions: LocationOptions = LocationOptions(),
        content: (() -> MapContent)? = nil
    ) {
        self.viewport = _viewport
        locationDependencies.locationOptions = locationOptions
        content?()._visit(mapContentVisitor)
    }

    public func makeCoordinator() -> Coordinator {
        let mapView = MapView(frame: .zero)
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

        let locationCoordinator = LocationCoordinator(locationManager: mapView.location)

        return Coordinator(
            basic: basicCoordinator,
            viewAnnotation: viewAnnotationCoordinator,
            location: locationCoordinator,
            viewController: vc,
            mapView: mapView)
    }

    public func makeUIViewController(context: Context) -> UIViewController {
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
        context.coordinator.location.update(deps: locationDependencies)
    }
}

@available(iOS 13.0, *)
extension Map {

     /// Creates a map.
     ///
     /// - Parameters:
     ///     - viewport: The camera viewport to display.
     ///     - locationOptions: The options to configure ``LocationManager``.
     public init(
         viewport: Binding<Viewport>,
         locationOptions: LocationOptions = LocationOptions()
     ) {
         self.init(
            _viewport: .binding(viewport),
            locationOptions: locationOptions,
            content: nil)
     }

     /// Creates a map.
     ///
     /// - Parameters:
     ///     - initialViewport: Initial camera viewport.
     ///     - locationOptions: The options to configure ``LocationManager``.
     public init(
         initialViewport: Viewport = .styleDefault,
         locationOptions: LocationOptions = LocationOptions()
     ) {
         self.init(
            _viewport: .constant(initialViewport),
            locationOptions: locationOptions,
            content: nil)
     }
}

@available(iOS 13.0, *)
extension Map {
    func set<T>(_ keyPath: WritableKeyPath<Map, T>, _ value: T) -> Self {
        var updated = self
        updated[keyPath: keyPath] = value
        return updated
    }

    func append<T>(_ keyPath: WritableKeyPath<Map, T>, _ newElement: T.Element) -> Self where T: RangeReplaceableCollection {
        var updated = self
        updated[keyPath: keyPath].append(newElement)
        return updated
    }
}

@available(iOS 13.0, *)
public extension Map {
    /// Sets camera bounds.
    func cameraBounds(_ cameraBounds: CameraBoundsOptions) -> Self {
        set(\.mapDependencies.cameraBounds, cameraBounds)
    }

    /// Sets style to the map.
    ///
    /// - Parameters:
    ///     - uri: An URI of a style.
    func styleURI(_ uri: StyleURI) -> Self {
        set(\.mapDependencies.styleURI, uri)
    }

    /// Configures gestures options.
    func gestureOptions(_ options: GestureOptions) -> Self {
        set(\.mapDependencies.gestureOptions, options)
    }

    /// Adds tap handler to the map.
    ///
    /// Prefer using this handler instead of `onTapGesture` since it waits for the failure of other map gestures like quick-zoom.
    ///
    /// - Parameters:
    ///  - action: The action to perform.
    func onMapTapGesture(perform action: @escaping MapTapAction) -> Self {
        set(\.mapDependencies.actions.onMapTapGesture, action)
    }

    /// Adds tap action to layers with specified `layerIds`.
    ///
    /// The action will only be called when at least one of specified layers are at the tap viewport.
    ///
    /// - Parameters:
    ///  - layerIds: The identifiers of layers where to perform features lookup.
    ///  - action: The action to perform.
    func onLayerTapGesture(_ layerIds: String..., perform action: @escaping MapLayerTapAction) -> Self {
        var updated = self
        updated.mapDependencies.actions.layerTapActions.append((layerIds, action))
        return updated
    }

    /// Sets constraint mode to the map. If not set, `heightOnly` wil be in use.
    func constrainMode(_ constrainMode: ConstrainMode) -> Self {
        set(\.mapDependencies.constrainMode, constrainMode)
    }

    /// Sets viewport mode to the map
    func viewportMode(_ viewportMode: ViewportMode) -> Self {
        set(\.mapDependencies.viewportMode, viewportMode)
    }

    /// Sets ``NorthOrientation`` to the map. If not set, `upwards` will be in use.
    func northOrientation(_ northOrientation: NorthOrientation) -> Self {
        set(\.mapDependencies.orientation, northOrientation)
    }

    /// Sets ``OrnamentOptions`` to the map.
    func ornamentOptions(_ options: OrnamentOptions) -> Self {
        set(\.mapDependencies.ornamentOptions, options)
    }
}

@available(iOS 13.0, *)
extension Map {

    public final class Coordinator {
        let basic: MapBasicCoordinator
        let viewAnnotation: ViewAnnotationCoordinator
        let location: LocationCoordinator
        let viewController: UIViewController
        let mapView: MapView

        init(
            basic: MapBasicCoordinator,
            viewAnnotation: ViewAnnotationCoordinator,
            location: LocationCoordinator,
            viewController: UIViewController,
            mapView: MapView
        ) {
            self.basic = basic
            self.viewAnnotation = viewAnnotation
            self.location = location
            self.viewController = viewController
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
