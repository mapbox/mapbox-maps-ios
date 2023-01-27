@_exported import MapboxMaps
import SwiftUI

public extension CameraState {
    /// Initializes CameraState with center and zoom.
    init(center: CLLocationCoordinate2D, zoom: CGFloat) {
        self.init(center: center, padding: .zero, zoom: zoom, bearing: 0, pitch: 0)
    }
}

/// The action that is called when the map is loaded.
public typealias MapLoadedAction = (MapboxMap) -> Void

/// View displaying Mapbox Map in SwiftUI.
@_spi(Experimental)
@available(iOS 13.0, *)
public struct MapboxView: UIViewRepresentable {
    public typealias InitialOptionsProvider = () -> MapInitOptions
    public typealias TapAction = (CGPoint) -> Void
    public typealias TapQueryAction = (CGPoint, (Result<[QueriedFeature], Error>)) -> Void

    typealias TapActionWithQueryPair = (options: RenderedQueryOptions?, action: TapQueryAction)
    struct Actions {
        var onMapLoaded: MapLoadedAction?
        var onMapTapGesture: TapAction?
        var tapActionsWithQuery = [TapActionWithQueryPair]()
    }

    @Binding
    var camera: CameraState
    var cameraBounds: CameraBoundsOptions?
    var annotations = [PointAnnotation]()
    var actions = Actions()
    var styleURI = StyleURI.streets
    var getstureOptions: GestureOptions = GestureOptions()

    private let initialOptions: InitialOptionsProvider?

    /// Creates an instance showing scpecisif region.
    ///
    /// - Parameters:
    ///     - camera: The camera state to display.
    ///     - initialOptions: A closure to provide initial map parameters. It gets called only once when `MapboxView` is created.
    public init(camera: Binding<CameraState>, initialOptions: InitialOptionsProvider? = nil) {
        self.initialOptions = initialOptions
        _camera = camera
    }

    public func makeCoordinator() -> SwiftUIMapViewCoordinator {
        SwiftUIMapViewCoordinator(camera: $camera)
    }

    public func makeUIView(context: UIViewRepresentableContext<MapboxView>) -> MapView {
        MapView(frame: .zero, mapInitOptions: initialOptions?() ?? MapInitOptions())
    }

    public func updateUIView(_ mapView: MapView, context: Context) {
        context.environment.mapViewProvider?.mapView = mapView
        context.coordinator.mapView = mapView
        context.coordinator.update(from: self)
    }
}

@_spi(Experimental)
@available(iOS 13.0, *)
extension MapboxView {
    private func set<T>(_ keyPath: WritableKeyPath<MapboxView, T>, _ value: T) -> Self {
        var updated = self
        updated[keyPath: keyPath] = value
        return updated
    }

    /// Sets camera bounds.
    public func cameraBounds(_ cameraBounds: CameraBoundsOptions) -> Self {
        set(\.cameraBounds, cameraBounds)
    }

    /// Adds callback to map loaded event.
    public func onMapLoaded(_ callback: @escaping MapLoadedAction) -> Self {
        set(\.actions.onMapLoaded, callback)
    }

    /// Sets style to the map.
    public func styleURI(_ styleURI: StyleURI) -> Self {
        set(\.styleURI, styleURI)
    }

    /// Configures gestures options.
    public func gestureOptions(_ options: GestureOptions) -> Self {
        set(\.getstureOptions, options)
    }

    /// Adds point annotations to the map.
    public func annotations(_ annotations: [PointAnnotation]) -> Self {
        set(\.annotations, annotations)
    }

    /// Adds tap handler to the map.
    ///
    /// Prefer using this handler instead of `onTapGesture` since it waits for the failure of other map gestures like quick-zoom.
    ///
    /// - Parameters:
    ///  - action: The action to perform.
    public func onMapTapGesture(action: @escaping TapAction) -> Self {
        set(\.actions.onMapTapGesture, action)
    }

    /// Adds tap handler which additionally queries rendered features under the point.
    ///
    /// Prefer using this handler instead of `onTapGesture` since it waits for the failure of other map gestures like quick-zoom.
    /// The queried features can be filtered by `queryOptions`.
    ///
    /// - Parameters:
    ///  - queryOptions: The options used to query features.
    ///  - action: The action to perform.
    public func onMapTapGesture(queryOptions: RenderedQueryOptions? = nil, action: @escaping TapQueryAction) -> Self {
        var updated = self
        updated.actions.tapActionsWithQuery.append((options: queryOptions, action: action))
        return updated
    }
}
