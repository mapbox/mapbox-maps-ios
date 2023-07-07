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
    public typealias InitOptionsProvider = () -> MapInitOptions

    var camera: Binding<CameraState>?
    var mapDependencies = MapDependencies()
    private var mapInitOptions: InitOptionsProvider?
    private var locationDependencies = LocationDependencies()
    private var mapContentVisitor = DefaultMapContentVisitor()

    @Environment(\.colorScheme) var colorScheme

    /// Creates a map that displays annotations.
    ///
    /// - Parameters:
    ///     - camera: The camera state to display. If not specified, the default camera options from style will be used. See [center](https://docs.mapbox.com/mapbox-gl-js/style-spec/#root-center), [zoom](https://docs.mapbox.com/mapbox-gl-js/style-spec/root/#zoom), [bearing](https://docs.mapbox.com/mapbox-gl-js/style-spec/#root-bearing), [pitch](https://docs.mapbox.com/mapbox-gl-js/style-spec/#root-pitch).
    ///     - mapInitOptions: A closure to provide initial map parameters. It gets called only once when `Map` is created.
    ///     - locationOptions: The options to configure ``LocationManager``.
    ///     - annotationItems: The collection of data that the view uses to display annotations.
    ///     - annotationContent: A closure that produces the annotation content.
    public init(
        camera: Binding<CameraState>? = nil,
        mapInitOptions: InitOptionsProvider? = nil,
        locationOptions: LocationOptions = LocationOptions(),
        @MapContentBuilder _ content: () -> MapContent
    ) {
        self.camera = camera
        self.mapInitOptions = mapInitOptions
        locationDependencies.locationOptions = locationOptions
        content()._visit(mapContentVisitor)
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(
            basic: MapBasicCoordinator(setCamera: camera.map(\.setter)),
            viewAnnotation: ViewAnnotationCoordinator(),
            location: LocationCoordinator())
    }

    public func makeUIViewController(context: Context) -> MapViewController {
        let mapView = MapView(frame: .zero, mapInitOptions: mapInitOptions?() ?? MapInitOptions())
        let mapController = MapViewController(mapView: mapView)
        context.environment.mapViewProvider?.mapView = mapView
        context.coordinator.basic.setMapView(MapViewFacade(from: mapView))
        context.coordinator.viewAnnotation.setup(with: ViewAnnotationCoordinator.Deps(
            viewAnnotationsManager: mapView.viewAnnotations,
            addViewController: { view in
                mapController.addChild(view)
                view.didMove(toParent: mapController)
            },
            removeViewController: { view in
                view.willMove(toParent: nil)
                view.removeFromParent()
            }))
        context.coordinator.location.setup(with: mapView.location)
        return mapController
    }

    public func updateUIViewController(_ mapController: MapViewController, context: Context) {
        context.coordinator.basic.update(
            camera: camera?.wrappedValue,
            deps: mapDependencies,
            colorScheme: colorScheme)
        context.coordinator.viewAnnotation.updateAnnotations(to: mapContentVisitor.visitedViewAnnotations)
        context.coordinator.location.update(deps: locationDependencies)
    }
}

@available(iOS 13.0, *)
extension Map {

    /// Creates a map.
    ///
    /// - Parameters:
    ///     - camera: The camera state to display. If not specified, the default camera options from style will be used. See [center](https://docs.mapbox.com/mapbox-gl-js/style-spec/#root-center), [zoom](https://docs.mapbox.com/mapbox-gl-js/style-spec/root/#zoom), [bearing](https://docs.mapbox.com/mapbox-gl-js/style-spec/#root-bearing), [pitch](https://docs.mapbox.com/mapbox-gl-js/style-spec/#root-pitch).
    ///     - mapInitOptions: A closure to provide initial map parameters. It gets called only once when `Map` is created.
    ///     - locationOptions: The options to configure ``LocationManager``.
    public init(
        camera: Binding<CameraState>? = nil,
        mapInitOptions: InitOptionsProvider? = nil,
        locationOptions: LocationOptions = LocationOptions()
    ) {
        self.camera = camera
        self.mapInitOptions = mapInitOptions
        locationDependencies.locationOptions = locationOptions
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
    ///     - default: A Style URI to be used by default.
    ///     - darkMode: A Style URI which will automaticaly be used for dark mode. If not specified,
    ///         the default option will continue to be used.
    func styleURI(_ default: StyleURI, darkMode: StyleURI? = nil) -> Self {
        set(\.mapDependencies.styleURIs, .init(default: `default`, darkMode: darkMode))
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
    /// The action will only be called when at least one of specified layers are at the tap position.
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
}

// MARK: Location

@available(iOS 13.0, *)
public extension Map {
    /// Adds an action to perform when a new location is emitted.
    func onLocationUpdated(perform action: @escaping LocationUpdateAction) -> Self {
        append(\.locationDependencies.locationUpdateHandlers, action)
    }

    /// Adds an action to perform when a new puck location (interpolated) is emitted.
    func onPuckLocationUpdated(perform action: @escaping LocationUpdateAction) -> Self {
        append(\.locationDependencies.puckLocationUpdateHandlers, action)
    }
}

@available(iOS 13.0, *)
extension Map {

    public final class Coordinator {
        let basic: MapBasicCoordinator
        let viewAnnotation: ViewAnnotationCoordinator
        let location: LocationCoordinator

        init(basic: MapBasicCoordinator, viewAnnotation: ViewAnnotationCoordinator, location: LocationCoordinator) {
            self.basic = basic
            self.viewAnnotation = viewAnnotation
            self.location = location
        }
    }

    public final class MapViewController: UIViewController {
        private let mapView: MapView

        public init(mapView: MapView) {
            self.mapView = mapView
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        public override func loadView() {
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
